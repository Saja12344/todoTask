//
//  TaskGenerator.swift
//  todoTask
//

import Foundation

extension GoalSettings {
    /// User-chosen deadline, or a short horizon when none was picked (avoids 100+ auto sessions).
    func scheduleEnd(calendar: Calendar = .current) -> Date {
        if let deadline {
            return calendar.startOfDay(for: deadline)
        }
        return calendar.date(byAdding: .day, value: 28, to: calendar.startOfDay(for: Date()))!
    }

    /// Max sessions to generate when the user did not set a deadline.
    var sessionCapWithoutDeadline: Int {
        max(1, min(targetNumber, 30))
    }
}

struct TaskGenerator {

    /// Combines a calendar day with the user's chosen preferred (start) time,
    /// so every task carries a real time-of-day (used by the calendar & reminders).
    private static func atPreferredTime(_ day: Date, _ settings: GoalSettings, _ calendar: Calendar = .current) -> Date {
        let h = calendar.component(.hour, from: settings.startTime)
        let m = calendar.component(.minute, from: settings.startTime)
        return calendar.date(bySettingHour: h, minute: m, second: 0, of: day) ?? day
    }

    private static func unitSuffix(_ unit: String) -> String {
        let u = unit.trimmingCharacters(in: .whitespaces)
        return u.isEmpty ? "" : " \(u)"
    }

    private static func incrementLabel(amount: Int, unit: String) -> String {
        "+\(max(1, amount))\(unitSuffix(unit))"
    }

    private static func stepLabel(index: Int, total: Int, prefix: String, unit: String = "") -> String {
        let u = unitSuffix(unit)
        return "\(prefix) \(index + 1) of \(total)\(u)"
    }

    static func generate(
        from settings: GoalSettings,
        goalID: UUID,
        goalTitle: String,
        energyFactor: Double = 1.0
    ) -> [GoalTask] {
        
        let factor = max(0.3, min(1.0, energyFactor))
        
        switch settings.goalType {
        case .reachTarget:
            if settings.isMilestoneMode {
                return generateMilestones(settings: settings, goalID: goalID, title: goalTitle, factor: factor)
            } else {
                return generateFinishTotal(settings: settings, goalID: goalID, title: goalTitle, factor: factor)
            }
        case .buildHabit:
            if settings.isStreakMode {
                return generateBuildStreak(settings: settings, goalID: goalID, title: goalTitle, factor: factor)
            } else {
                return generateRepeatSchedule(settings: settings, goalID: goalID, title: goalTitle, factor: factor)
            }
        case .levelUp:
            return generateLevelUp(settings: settings, goalID: goalID, title: goalTitle, factor: factor)
        case .reduce:
            return generateReduce(settings: settings, goalID: goalID, title: goalTitle, factor: factor)
        }
    }
    
    // MARK: - Finish Total
    private static func generateFinishTotal(settings: GoalSettings, goalID: UUID, title: String, factor: Double) -> [GoalTask] {
        let target = Double(settings.targetNumber)
        let unit = settings.unit.isEmpty ? "units" : settings.unit
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let deadline = settings.scheduleEnd(calendar: calendar)
        let selectedDays = settings.selectedDays.isEmpty ? Set(1...7) : settings.selectedDays
        var validExecutionDates: [Date] = []
        var currentDate = today
        while currentDate <= deadline {
            let weekday = calendar.component(.weekday, from: currentDate)
            if selectedDays.contains(weekday) {
                validExecutionDates.append(currentDate)
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        let executionDaysCount = max(1, validExecutionDates.count)
        let perStep = max(1, Int(ceil(target / Double(executionDaysCount))))
        return validExecutionDates.map { date in
            GoalTask(
                goalID: goalID,
                title: incrementLabel(amount: perStep, unit: unit),
                scheduledDate: atPreferredTime(date, settings, calendar),
                targetAmount: perStep,
                completedAmount: 0
            )
        }
    }

    // MARK: - Repeat on Schedule
    private static func generateRepeatSchedule(settings: GoalSettings, goalID: UUID, title: String, factor: Double) -> [GoalTask] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let deadline = settings.scheduleEnd(calendar: calendar)
        let selectedDays = settings.selectedDays.isEmpty ? Set(1...7) : settings.selectedDays
        let cap = settings.deadline == nil ? settings.sessionCapWithoutDeadline : Int.max
        var scheduledDates: [Date] = []
        var currentDate = today
        while currentDate <= deadline, scheduledDates.count < cap {
            let weekday = calendar.component(.weekday, from: currentDate)
            if selectedDays.contains(weekday) {
                scheduledDates.append(currentDate)
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        let total = max(1, scheduledDates.count)
        let unit = settings.unit.isEmpty ? nil : settings.unit
        return scheduledDates.enumerated().map { index, date in
            GoalTask(
                goalID: goalID,
                title: stepLabel(index: index, total: total, prefix: "Session", unit: settings.unit),
                scheduledDate: atPreferredTime(date, settings, calendar)
            )
        }
    }

    // MARK: - Build Streak
    private static func generateBuildStreak(settings: GoalSettings, goalID: UUID, title: String, factor: Double) -> [GoalTask] {
        let target = settings.targetNumber
        let unit = settings.unit.isEmpty ? "days" : settings.unit
        let adjTarget = max(3, Int(Double(target) * factor))
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return (0..<adjTarget).compactMap { i -> GoalTask? in
            guard let date = cal.date(byAdding: .day, value: i, to: today) else { return nil }
            return GoalTask(
                goalID: goalID,
                title: stepLabel(index: i, total: adjTarget, prefix: "Day", unit: unit),
                scheduledDate: atPreferredTime(date, settings, cal)
            )
        }
    }

    // MARK: - Level Up
    private static func generateLevelUp(settings: GoalSettings, goalID: UUID, title: String, factor: Double) -> [GoalTask] {
        let paceWeeks = max(1, settings.stepUpPaceWeeks)
        let unit = settings.unit.isEmpty ? nil : settings.unit
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let deadline = settings.scheduleEnd(calendar: calendar)
        var steps = max(1, calendar.dateComponents([.weekOfYear], from: today, to: deadline).weekOfYear ?? 1)
        if settings.deadline == nil {
            steps = min(steps, settings.sessionCapWithoutDeadline)
        }
        return (0..<steps).compactMap { i -> GoalTask? in
            let weekOffset = i * paceWeeks
            guard let date = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: today) else { return nil }
            let u = settings.unit.isEmpty ? "" : settings.unit
            return GoalTask(
                goalID: goalID,
                title: stepLabel(index: i, total: steps, prefix: "Week", unit: u),
                scheduledDate: atPreferredTime(date, settings, calendar)
            )
        }
    }

    // MARK: - Milestones
    private static func generateMilestones(settings: GoalSettings, goalID: UUID, title: String, factor: Double) -> [GoalTask] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let deadline = settings.scheduleEnd(calendar: calendar)
        let totalDays = max(1, calendar.dateComponents([.day], from: today, to: deadline).day ?? 30)
        let activeDays = settings.selectedDays.isEmpty ? Set(1...7) : settings.selectedDays
        let activeDaysPerWeek = max(1, activeDays.count)
        let effectiveDays = max(1, Int(Double(totalDays) / 7.0 * Double(activeDaysPerWeek)))
        let rawCount = max(3, Int(Double(effectiveDays) * 0.3 * factor))
        let count = min(rawCount, 10)
        var tasks: [GoalTask] = []
        for i in 0..<count {
            let progressRatio = Double(i) / Double(max(1, count - 1))
            let dayOffset = Int(Double(totalDays) * progressRatio)
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: today) else { continue }
            let weekday = calendar.component(.weekday, from: date)
            if !activeDays.contains(weekday) { continue }
            tasks.append(GoalTask(goalID: goalID, title: "", scheduledDate: atPreferredTime(date, settings, calendar)))
        }
        let total = max(1, tasks.count)
        return tasks.enumerated().map { index, task in
            GoalTask(
                goalID: task.goalID,
                title: stepLabel(index: index, total: total, prefix: "Milestone"),
                scheduledDate: task.scheduledDate
            )
        }
    }

    // MARK: - Reduce
    private static func generateReduce(settings: GoalSettings, goalID: UUID, title: String, factor: Double) -> [GoalTask] {
        let baseline = settings.baselineNumber
        let target = settings.targetNumber
        let unit = settings.unit.isEmpty ? nil : settings.unit
        let diff = max(1, baseline - target)
        let steps = min(max(3, diff), 10)
        let stepSize = max(1, diff / steps)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<steps).map { i in
            let current = max(target, baseline - (stepSize * i))
            let date = calendar.date(byAdding: .day, value: i, to: today)!
            let label = "Stay at \(current)\(unitSuffix(settings.unit)) or less"
            return GoalTask(goalID: goalID, title: label, scheduledDate: atPreferredTime(date, settings, calendar))
        }
    }
}

// MARK: - Energy helpers
extension Energytoday {
    var taskFactor: Double {
        switch value {
        case "3": return 1.0
        case "2": return 0.7
        case "1": return 0.5
        default:  return 0.7
        }
    }
}
