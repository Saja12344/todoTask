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

    init() { load()
        debugPrintGoalsAndTasks()
    }

    // MARK: - Load / Save
    func load() { goals = persistence.load() }
    private func save() { persistence.save(goals) }

    // MARK: - Add Goal
    func add(_ goal: OrbGoal) {
        goals.append(goal)
        save()
    }

    // MARK: - Delete Goal
    func delete(goalID: UUID) {
        goals.removeAll { $0.id == goalID }
        save()
    }

    // MARK: - Lookup
    func goal(with id: UUID) -> OrbGoal? {
        goals.first { $0.id == id }
    }

    // MARK: - Task CRUD
//    func addTask(goalID: UUID, title: String, scheduledDate: Date? = nil) {
//        guard let i = goals.firstIndex(where: { $0.id == goalID }) else { return }
//        goals[i].tasks.append(GoalTask(title: title, scheduledDate: scheduledDate))
//        save()
//    }
    func addTask(goalID: UUID, title: String, scheduledDate: Date) {
        guard let i = goals.firstIndex(where: { $0.id == goalID }) else { return }

        let task = GoalTask(
            goalID: goalID,
            title: title,
            scheduledDate: scheduledDate
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
        goals[i].tasks[j].isDone.toggle()
        save()
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

            while currentDate <= settings.deadline {

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

    
    // MARK: - Today's Tasks (للهوم)
    /// جميع المهام المجدولة لليوم من كل الأهداف
    func todayTasks(for date: Date = Date()) -> [(goal: OrbGoal, task: GoalTask)] {
        var result: [(OrbGoal, GoalTask)] = []
        for goal in goals {
            for task in goal.tasks(for: date) {
                result.append((goal, task))
            }
        }
        return result
    }


    // MARK: - Toggle Today Task
    func toggleTodayTask(goalID: UUID, taskID: UUID) {
        toggleTask(goalID: goalID, taskID: taskID)
    }

    // MARK: - Legacy
    func clearAll() {
        goals.removeAll()
        save()
    }

    func updateProgress(goalID: UUID, done: Int, total: Int) {
        // kept for backward compat — no longer needed since progress is computed
    }
}
