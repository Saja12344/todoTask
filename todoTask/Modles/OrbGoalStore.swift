//
//  OrbGoalStore.swift
//  todoTask
//
// Observable Store: حفظ/قراءة من UserDefaults، إدارة CRUD، توليد المهام.


import SwiftUI
import Combine

final class OrbGoalStore: ObservableObject {
    @Published private(set) var goals: [OrbGoal] = []

    private let persistence = OrbGoalPersistence()
    private var activeUserId = "logged_out"
    private var cloudSyncTask: Task<Void, Never>?

    init() {
        goals = []
        GoalTaskNotificationScheduler.reschedule(goals: goals)
    }

    // MARK: - Account binding

    /// Load/save goals for the signed-in user. Call on login, logout, and app launch.
    @MainActor
    func switchUser(to userId: String?, myId: String? = nil) {
        cloudSyncTask?.cancel()

        if activeUserId != "logged_out" {
            persistence.save(goals, userId: activeUserId)
            scheduleCloudSave()
        }

        guard let userId, !userId.isEmpty else {
            activeUserId = "logged_out"
            goals = []
            GoalTaskNotificationScheduler.reschedule(goals: [])
            return
        }

        activeUserId = userId
        persistence.migrateLegacyGlobalStore(to: userId)

        let local = persistence.load(userId: userId)
        goals = local
        migratePartialTaskAmounts()
        GoalTaskNotificationScheduler.reschedule(goals: goals)
        reattachChallengeListeners(myId: myId ?? userId)

        guard OrbGoalsCloudSync.isSyncable(userId) else { return }

        cloudSyncTask = Task { @MainActor in
            guard let cloud = await OrbGoalsCloudSync.shared.load(userId: userId) else { return }
            guard !Task.isCancelled else { return }
            let merged = Self.mergeGoals(local: persistence.load(userId: userId), cloud: cloud)
            guard merged != goals else { return }
            goals = merged
            migratePartialTaskAmounts()
            persistence.save(goals, userId: userId)
            GoalTaskNotificationScheduler.reschedule(goals: goals)
            reattachChallengeListeners(myId: myId ?? userId)
            await OrbGoalsCloudSync.shared.save(userId: userId, goals: goals)
        }
    }

    private func reattachChallengeListeners(myId: String) {
        ChallengeOrbsManager.shared.attach(store: self)
        for goal in goals where goal.isChallenge {
            guard let roomId = goal.challengeInfo?.challengeID else { continue }
            ChallengeOrbsManager.shared.track(roomId: roomId, goalId: goal.id, myId: myId, store: self)
        }
    }

    private static func mergeGoals(local: [OrbGoal], cloud: [OrbGoal]) -> [OrbGoal] {
        var merged = Dictionary(uniqueKeysWithValues: cloud.map { ($0.id, $0) })
        for goal in local { merged[goal.id] = goal }
        return merged.values.sorted { $0.createdAt < $1.createdAt }
    }

    // MARK: - Load / Save
    private func load() { goals = persistence.load(userId: activeUserId) }

    /// Backfill targetAmount from titles; sync completedAmount with legacy isDone.
    private func migratePartialTaskAmounts() {
        var changed = false
        for i in goals.indices {
            for j in goals[i].tasks.indices {
                var task = goals[i].tasks[j]
                let before = task
                if task.targetAmount <= 1, let inferred = inferredTargetAmount(for: task, in: goals[i]), inferred > 1 {
                    task.targetAmount = inferred
                }
                if task.isDone, task.completedAmount == 0 {
                    task.completedAmount = max(1, task.targetAmount)
                }
                task.syncDoneFlag()
                if task != before {
                    goals[i].tasks[j] = task
                    changed = true
                }
            }
        }
        if changed { save() }
    }

    private func inferredTargetAmount(for task: GoalTask, in goal: OrbGoal) -> Int? {
        if let n = parsePlusAmount(from: task.title) { return n }
        guard let settings = goal.settings, settings.goalType == .reachTarget, !settings.isMilestoneMode else {
            return nil
        }
        let ordered = goal.tasks.sorted { $0.scheduledDate < $1.scheduledDate }
        let count = max(1, ordered.count)
        return max(1, Int(ceil(Double(settings.targetNumber) / Double(count))))
    }

    private func parsePlusAmount(from title: String) -> Int? {
        let t = title.trimmingCharacters(in: .whitespaces)
        guard t.hasPrefix("+") else { return nil }
        let rest = String(t.dropFirst())
        let digits = rest.prefix(while: { $0.isNumber })
        return Int(digits)
    }
    private func save() {
        guard activeUserId != "logged_out" else { return }
        persistence.save(goals, userId: activeUserId)
        GoalTaskNotificationScheduler.reschedule(goals: goals)
        scheduleCloudSave()
    }

    private func scheduleCloudSave() {
        guard OrbGoalsCloudSync.isSyncable(activeUserId) else { return }
        let userId = activeUserId
        let snapshot = goals
        Task {
            await OrbGoalsCloudSync.shared.save(userId: userId, goals: snapshot)
        }
    }

    // MARK: - Add Goal
    func add(_ goal: OrbGoal) {
        goals.append(goal)
        save()
    }

    func addChallengeOrb(_ goal: OrbGoal, myId: String) {
        guard let roomId = goal.challengeInfo?.challengeID else {
            add(goal)
            return
        }
        let goalId: UUID
        if let existing = goals.first(where: { $0.challengeInfo?.challengeID == roomId }) {
            goalId = existing.id
        } else {
            goals.append(goal)
            save()
            goalId = goal.id
        }
        ChallengeOrbsManager.shared.track(roomId: roomId, goalId: goalId, myId: myId, store: self)
    }

    // MARK: - Delete Goal
    func delete(goalID: UUID) {
        if let roomId = goals.first(where: { $0.id == goalID })?.challengeInfo?.challengeID {
            ChallengeOrbsManager.shared.untrack(roomId: roomId)
        }
        goals.removeAll { $0.id == goalID }
        save()
    }

    // MARK: - Lookup
    func goal(with id: UUID) -> OrbGoal? {
        goals.first { $0.id == id }
    }

    func reflectionContext(goalID: UUID, taskID: UUID) -> TaskReflectionContext? {
        guard let goal = goal(with: goalID),
              let task = goal.tasks.first(where: { $0.id == taskID }) else { return nil }
        return TaskReflectionContext(
            goalID: goalID,
            taskID: taskID,
            taskTitle: task.title,
            goalTitle: goal.title,
            accent: goal.accentColor
        )
    }

    // MARK: - Task CRUD
//    func addTask(goalID: UUID, title: String, scheduledDate: Date? = nil) {
//        guard let i = goals.firstIndex(where: { $0.id == goalID }) else { return }
//        goals[i].tasks.append(GoalTask(title: title, scheduledDate: scheduledDate))
//        save()
//    }
    func addTask(goalID: UUID, title: String, scheduledDate: Date, targetAmount: Int = 1) {
        guard let i = goals.firstIndex(where: { $0.id == goalID }) else { return }

        let task = GoalTask(
            goalID: goalID,
            title: title,
            scheduledDate: scheduledDate,
            targetAmount: max(1, targetAmount),
            completedAmount: 0
        )

        goals[i].tasks.append(task)
        save()
    }
    func insertGeneratedTasks(goalID: UUID, tasks: [GoalTask]) {
        guard let index = goals.firstIndex(where: { $0.id == goalID }) else { return }

        goals[index].tasks = tasks
        goals[index].tasks.sort { $0.scheduledDate < $1.scheduledDate }

        save()
    }

    func deleteTask(goalID: UUID, taskID: UUID) {
        guard let i = goals.firstIndex(where: { $0.id == goalID }) else { return }
        goals[i].tasks.removeAll { $0.id == taskID }
        save()
    }

    func toggleTask(goalID: UUID, taskID: UUID) {
        guard let i = goals.firstIndex(where: { $0.id == goalID }) else { return }
        guard let j = goals[i].tasks.firstIndex(where: { $0.id == taskID }) else { return }
        var task = goals[i].tasks[j]
        let wasComplete = task.isFullyComplete
        if task.targetAmount > 1 {
            let cap = task.targetAmount
            task.completedAmount = (task.completedAmount + 1) % (cap + 1)
        } else {
            task.isDone.toggle()
            task.completedAmount = task.isDone ? 1 : 0
        }
        task.syncDoneFlag()
        if task.isFullyComplete, !wasComplete {
            task.completedAt = Date()
        } else if !task.isFullyComplete {
            task.completedAt = nil
            task.reflectionNote = nil
            task.reflectionPromptKey = nil
        }
        goals[i].tasks[j] = task
        save()
    }

    func setTaskCompletedAmount(goalID: UUID, taskID: UUID, amount: Int) {
        guard let i = goals.firstIndex(where: { $0.id == goalID }) else { return }
        guard let j = goals[i].tasks.firstIndex(where: { $0.id == taskID }) else { return }
        var task = goals[i].tasks[j]
        let wasComplete = task.isFullyComplete
        let cap = max(1, task.targetAmount)
        task.completedAmount = min(max(0, amount), cap)
        task.syncDoneFlag()
        if task.isFullyComplete, !wasComplete {
            task.completedAt = Date()
        } else if !task.isFullyComplete {
            task.completedAt = nil
        }
        goals[i].tasks[j] = task
        save()
    }

    func saveTaskReflection(goalID: UUID, taskID: UUID, note: String, promptKey: String) {
        guard let i = goals.firstIndex(where: { $0.id == goalID }) else { return }
        guard let j = goals[i].tasks.firstIndex(where: { $0.id == taskID }) else { return }
        var task = goals[i].tasks[j]
        task.reflectionNote = note
        task.reflectionPromptKey = promptKey
        if task.completedAt == nil, task.isFullyComplete {
            task.completedAt = Date()
        }
        goals[i].tasks[j] = task
        save()
    }

    func bumpTaskCompletedAmount(goalID: UUID, taskID: UUID, delta: Int) {
        guard let i = goals.firstIndex(where: { $0.id == goalID }) else { return }
        guard let j = goals[i].tasks.firstIndex(where: { $0.id == taskID }) else { return }
        var task = goals[i].tasks[j]
        setTaskCompletedAmount(goalID: goalID, taskID: taskID, amount: task.completedAmount + delta)
    }

    func replaceTasks(goalID: UUID, tasks: [GoalTask]) {
        guard let i = goals.firstIndex(where: { $0.id == goalID }) else { return }
        goals[i].tasks = tasks
        save()
    }

    // أضيفي هذه الدالة داخل OrbGoalStore بعد دالة replaceTasks

    func updateGoal(_ goal: OrbGoal) {
        guard let i = goals.firstIndex(where: { $0.id == goal.id }) else { return }
        goals[i] = goal
        save()
    }

    // أضيفي هذه الدالة لتحديث progress الصديق (تُستدعى من CloudKit لاحقاً)
    func updateFriendProgress(goalID: UUID, friendProgress: Double) {
        guard let i = goals.firstIndex(where: { $0.id == goalID }) else { return }
        goals[i].challengeInfo?.friendProgress = friendProgress
        save()
    }
    // MARK: - Generate Tasks from Settings + Energy
//    struct TaskGenerator {
//
//        static func generate(from settings: GoalSettings, goalTitle: String, energyFactor: Double = 0.7) -> [GoalTask] {
//            var tasks: [GoalTask] = []
//
//            let totalTasks = settings.targetNumber
//            var tasksToAssign = (1...totalTasks).map { i in
//                GoalTask(title: "\(goalTitle) — Task \(i)")
//            }
//
//            let cal = Calendar.current
//            var currentDate = Date()
//
//            while currentDate <= settings.deadline {
//                let weekday = cal.component(.weekday, from: currentDate) - 1  // 0=Sun ... 6=Sat
//
//                if settings.selectedDays.contains(weekday), !tasksToAssign.isEmpty {
//                    // المهمة اليومية: نسخة من المهمة الأصلية
//                    var task = tasksToAssign.removeFirst()
//                    let original = UUID()           // ID للمهمة الأصلية
////                    task.originalID = original      // اربط النسخة بالنسخة الأصلية
//                    task.id = UUID()                // نسخة جديدة لكل يوم
//                    task.scheduledDate = currentDate
//                    tasks.append(task)
//                }
//
//                currentDate = cal.date(byAdding: .day, value: 1, to: currentDate)!
//            }
//
//            return tasks
//        }
//        
//    }
    struct TaskGenerator {

        static func generate(
            from settings: GoalSettings,
            goalID: UUID,
            goalTitle: String,
            scheduledDate: Date
        ) -> [GoalTask] {

            var tasks: [GoalTask] = []

            let totalTasks = settings.targetNumber
            var tasksToAssign = (1...totalTasks).map {
                GoalTask(
                    goalID: goalID,
                    title: "\(goalTitle) — Task \($0)",
                    scheduledDate: scheduledDate
                )
            }

            let cal = Calendar.current
            var currentDate = Date()

            while currentDate <= settings.scheduleEnd(calendar: cal) {

                let weekday = cal.component(.weekday, from: currentDate)
//                - 1

                if settings.selectedDays.contains(weekday),
                   !tasksToAssign.isEmpty {

                    var task = tasksToAssign.removeFirst()
                    
                    task.scheduledDate = currentDate

                    tasks.append(task)
                }

                currentDate = cal.date(byAdding: .day, value: 1, to: currentDate)!
            }
            

            return tasks
        }
    }
    func debugPrintGoalsAndTasks() {
        for goal in goals {
            print("\n🎯 Goal ID: \(goal.id) - \(goal.title)")

            for task in goal.tasks {
                print("   ✅ Task ID: \(task.id)")
                print("   🔗 Task GoalID: \(task.goalID)")
                print("   📅 Date: \(String(describing: task.scheduledDate))")
            }

            print("----------------------")
        }
    }

    
    // MARK: - Scheduling (late rollover + energy break)
    func refreshScheduling(for date: Date = Date(), energy: DailyEnergyEntry? = nil) {
        var updated = goals
        let useEnergy = Calendar.current.isDate(date, inSameDayAs: Date()) ? energy : nil
        TaskScheduling.refreshSchedule(goals: &updated, referenceDate: date, energy: useEnergy)
        guard updated != goals else { return }
        goals = updated
        save()
    }

    // MARK: - Today's Tasks (للهوم)
    func todayTasks(for date: Date = Date(), energy: DailyEnergyEntry? = nil) -> [TodayTaskItem] {
        refreshScheduling(for: date, energy: energy)
        return TaskScheduling.itemsForDate(goals: goals, date: date)
    }


    // MARK: - Toggle Today Task
    func toggleTodayTask(goalID: UUID, taskID: UUID) {
        toggleTask(goalID: goalID, taskID: taskID)
    }

    // MARK: - Legacy
    func clearAll() {
        goals.removeAll()
        UserProgressStore.resetAll()
        GoalTaskNotificationScheduler.reschedule(goals: [])
        if activeUserId != "logged_out" {
            persistence.save(goals, userId: activeUserId)
            if OrbGoalsCloudSync.isSyncable(activeUserId) {
                let userId = activeUserId
                Task { await OrbGoalsCloudSync.shared.save(userId: userId, goals: []) }
            }
        }
    }

    /// Removes all orb data for the current account (delete account).
    func clearAllForCurrentUser() async {
        let userId = activeUserId
        clearAll()
        guard userId != "logged_out" else { return }
        persistence.delete(userId: userId)
        await OrbGoalsCloudSync.shared.delete(userId: userId)
    }

    func updateProgress(goalID: UUID, done: Int, total: Int) {
        // kept for backward compat — no longer needed since progress is computed
    }
}
