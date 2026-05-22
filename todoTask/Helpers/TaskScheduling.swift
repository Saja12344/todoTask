//
//  TaskScheduling.swift
//  todoTask
//

import Foundation

struct TodayTaskItem: Identifiable {
    let id: UUID
    let goal: OrbGoal
    let task: GoalTask
    let isLate: Bool
    let deferredByEnergy: Bool

    init(goal: OrbGoal, task: GoalTask, isLate: Bool = false, deferredByEnergy: Bool = false) {
        self.id = task.id
        self.goal = goal
        self.task = task
        self.isLate = isLate
        self.deferredByEnergy = deferredByEnergy
    }
}

enum TaskScheduling {
    static let lateThresholdHours: Int = 24

    /// Rolls overdue tasks forward and applies energy-based deferral. Mutates goals in place.
    static func refreshSchedule(goals: inout [OrbGoal], referenceDate: Date = Date(), energy: DailyEnergyEntry?) {
        let cal = Calendar.current
        let now = referenceDate
        let todayStart = cal.startOfDay(for: now)

        if let energy, energy.value == "1", cal.isDateInToday(now) {
            applyEnergyBreak(goals: &goals, todayStart: todayStart, calendar: cal)
        }

        for i in goals.indices {
            var lateFlags: [UUID: Bool] = [:]
            for j in goals[i].tasks.indices {
                var task = goals[i].tasks[j]
                guard !task.isDone, task.completedAmount < max(1, task.targetAmount) else { continue }

                let scheduledStart = cal.startOfDay(for: task.scheduledDate)
                let hours = cal.dateComponents([.hour], from: scheduledStart, to: now).hour ?? 0
                guard hours >= lateThresholdHours else { continue }

                let next = nextActiveDay(after: scheduledStart, settings: goals[i].settings, calendar: cal)
                if !cal.isDate(task.scheduledDate, inSameDayAs: next) {
                    task.scheduledDate = cal.date(bySettingHour: 8, minute: 0, second: 0, of: next) ?? next
                    goals[i].tasks[j] = task
                    lateFlags[task.id] = true
                }
            }
            goals[i].lateTaskIDs = lateFlags
        }
    }

    static func itemsForDate(
        goals: [OrbGoal],
        date: Date,
        calendar: Calendar = .current
    ) -> [TodayTaskItem] {
        var result: [TodayTaskItem] = []
        for goal in goals {
            for task in goal.tasks(for: date) {
                let isLate = goal.lateTaskIDs[task.id] == true
                    && calendar.isDate(task.scheduledDate, inSameDayAs: date)
                result.append(TodayTaskItem(goal: goal, task: task, isLate: isLate))
            }
        }
        return result.sorted { $0.task.scheduledDate < $1.task.scheduledDate }
    }

    // MARK: - Energy break → move part of today's load to tomorrow

    private static func applyEnergyBreak(
        goals: inout [OrbGoal],
        todayStart: Date,
        calendar: Calendar
    ) {
        let deferKey = "energy.deferred.\(LoginTracker.dateKey(for: todayStart))"
        guard !UserDefaults.standard.bool(forKey: deferKey) else { return }

        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: todayStart) else { return }

        var todayPool: [(Int, Int)] = []
        for (gi, goal) in goals.enumerated() {
            for (ti, task) in goal.tasks.enumerated() where !task.isDone {
                if calendar.isDate(task.scheduledDate, inSameDayAs: todayStart) {
                    todayPool.append((gi, ti))
                }
            }
        }

        let deferCount = max(1, todayPool.count / 2)
        for index in todayPool.prefix(deferCount) {
            let gi = index.0
            let ti = index.1
            let next = nextActiveDay(after: todayStart, settings: goals[gi].settings, calendar: calendar)
            let target = calendar.isDate(next, inSameDayAs: todayStart) ? tomorrow : next
            var task = goals[gi].tasks[ti]
            task.scheduledDate = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: target) ?? target
            goals[gi].tasks[ti] = task
        }

        UserDefaults.standard.set(true, forKey: deferKey)
    }

    private static func nextActiveDay(
        after day: Date,
        settings: GoalSettings?,
        calendar: Calendar
    ) -> Date {
        var cursor = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: day)) ?? day
        let active = settings?.selectedDays ?? Set(1...7)
        let deadline = settings?.deadline ?? calendar.date(byAdding: .year, value: 1, to: Date())!

        for _ in 0..<14 {
            if cursor > deadline { return cursor }
            let w = calendar.component(.weekday, from: cursor)
            if active.isEmpty || active.contains(w) { return cursor }
            cursor = calendar.date(byAdding: .day, value: 1, to: cursor) ?? cursor
        }
        return cursor
    }
}
