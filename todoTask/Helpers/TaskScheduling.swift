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
    ///
    /// Overdue (incomplete, scheduled before today) tasks are redistributed one-per-day
    /// across upcoming active days starting today — instead of all piling onto a single day.
    static func refreshSchedule(goals: inout [OrbGoal], referenceDate: Date = Date(), energy: DailyEnergyEntry?) {
        let cal = Calendar.current
        let now = referenceDate
        let todayStart = cal.startOfDay(for: now)

        if let energy, energy.value == "1", cal.isDateInToday(now) {
            applyEnergyBreak(goals: &goals, todayStart: todayStart, calendar: cal)
        }

        for i in goals.indices {
            var lateFlags: [UUID: Bool] = [:]
            let settings = goals[i].settings

            // Collect overdue incomplete tasks, and remember which future days are already taken.
            var overdueIndices: [Int] = []
            var occupiedDays = Set<Date>()
            for j in goals[i].tasks.indices {
                let task = goals[i].tasks[j]
                let incomplete = !task.isDone && task.completedAmount < max(1, task.targetAmount)
                let dayStart = cal.startOfDay(for: task.scheduledDate)
                if incomplete && dayStart < todayStart {
                    overdueIndices.append(j)
                } else if dayStart >= todayStart {
                    occupiedDays.insert(dayStart)
                }
            }

            guard !overdueIndices.isEmpty else {
                goals[i].lateTaskIDs = [:]
                continue
            }

            // Keep original sequence order (Day 1, Day 2, …).
            overdueIndices.sort { goals[i].tasks[$0].scheduledDate < goals[i].tasks[$1].scheduledDate }

            var cursor = todayStart
            for j in overdueIndices {
                let target = nextFreeActiveDay(from: cursor, settings: settings, occupied: occupiedDays, calendar: cal)
                occupiedDays.insert(target)

                var task = goals[i].tasks[j]
                task.scheduledDate = applyTime(of: task.scheduledDate, to: target, settings: settings, calendar: cal)
                goals[i].tasks[j] = task
                lateFlags[task.id] = true

                cursor = cal.date(byAdding: .day, value: 1, to: target) ?? target
            }
            goals[i].lateTaskIDs = lateFlags
        }
    }

    /// Preferred time to place a rescheduled task at (falls back to its original time, then 8am).
    private static func applyTime(of original: Date, to day: Date, settings: GoalSettings?, calendar: Calendar) -> Date {
        let hour: Int
        let minute: Int
        if let settings {
            hour = calendar.component(.hour, from: settings.startTime)
            minute = calendar.component(.minute, from: settings.startTime)
        } else {
            let comps = calendar.dateComponents([.hour, .minute], from: original)
            hour = comps.hour ?? 8
            minute = comps.minute ?? 0
        }
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day) ?? day
    }

    /// First active weekday on/after `from` that isn't already occupied by another task.
    private static func nextFreeActiveDay(
        from: Date,
        settings: GoalSettings?,
        occupied: Set<Date>,
        calendar: Calendar
    ) -> Date {
        var cursor = calendar.startOfDay(for: from)
        let active = settings?.selectedDays ?? Set(1...7)
        for _ in 0..<400 {
            let weekday = calendar.component(.weekday, from: cursor)
            let isActive = active.isEmpty || active.contains(weekday)
            if isActive && !occupied.contains(cursor) { return cursor }
            cursor = calendar.date(byAdding: .day, value: 1, to: cursor) ?? cursor
        }
        return cursor
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
