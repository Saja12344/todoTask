//
//  GoalTaskDisplay.swift
//  todoTask
//

import Foundation

/// Human-friendly task labels (increment per step, not confusing running totals).
enum GoalTaskDisplay {

    static func label(for task: GoalTask, in goal: OrbGoal, lang: LanguageManager) -> String {
        guard let settings = goal.settings else {
            return simplifyLegacyTitle(task.title, goalTitle: goal.title)
        }

        let ordered = goal.tasks.sorted { $0.scheduledDate < $1.scheduledDate }
        guard let index = ordered.firstIndex(where: { $0.id == task.id }) else {
            return simplifyLegacyTitle(task.title, goalTitle: goal.title)
        }

        let step = incrementPerStep(target: settings.targetNumber, stepCount: ordered.count)

        switch settings.goalType {
        case .reachTarget:
            if settings.isMilestoneMode {
                return lang.milestoneLabel(index: index + 1, total: ordered.count)
            }
            let perStep = task.targetAmount > 1 ? task.targetAmount : step
            return "+\(perStep)\(formattedUnit(settings.unit, count: perStep))"

        case .buildHabit:
            if settings.isStreakMode {
                return lang.dayLabel(index: index + 1, total: ordered.count)
            }
            return lang.sessionLabel(index: index + 1, total: ordered.count)
                + formattedUnit(settings.unit, count: 1)

        case .levelUp:
            let unit = settings.unit.trimmingCharacters(in: .whitespaces)
            return lang.weekLabel(index: index + 1, total: ordered.count, unit: unit)

        case .reduce:
            let baseline = settings.baselineNumber
            let target = settings.targetNumber
            let steps = max(1, ordered.count)
            let stepSize = max(1, (baseline - target) / steps)
            let level = max(target, baseline - stepSize * index)
            return lang.stayAtOrLess(level: level, unitSuffix: formattedUnit(settings.unit, count: level))
        }
    }

    static func todayPrimary(for task: GoalTask, in goal: OrbGoal, lang: LanguageManager) -> String {
        if let partial = partialProgressLine(for: task, in: goal) {
            return partial
        }
        return label(for: task, in: goal, lang: lang)
    }

    static func partialProgressLine(for task: GoalTask, in goal: OrbGoal) -> String? {
        guard task.targetAmount > 1 else { return nil }
        let unit = goal.settings?.unit.trimmingCharacters(in: .whitespaces) ?? ""
        if task.completedAmount > 0 {
            return "\(task.completedAmount)/\(task.targetAmount)\(formattedUnit(unit, count: task.completedAmount))"
        }
        return nil
    }

    static func formattedUnit(_ unit: String, count: Int) -> String {
        let u = unit.trimmingCharacters(in: .whitespaces)
        guard !u.isEmpty else { return "" }
        if count == 1, u.lowercased().hasSuffix("s"), u.count > 2 {
            return " \(String(u.dropLast()))"
        }
        return " \(u)"
    }

    private static func incrementPerStep(target: Int, stepCount: Int) -> Int {
        let count = max(1, stepCount)
        return max(1, Int(ceil(Double(target) / Double(count))))
    }

    private static func simplifyLegacyTitle(_ title: String, goalTitle: String) -> String {
        var t = title.trimmingCharacters(in: .whitespaces)
        if t.hasPrefix("+") { return t }

        let pattern = #"^(\d+)\s*/\s*(\d+)\s*(.*)$"#
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: t, range: NSRange(t.startIndex..., in: t)),
           let currentRange = Range(match.range(at: 1), in: t),
           let totalRange = Range(match.range(at: 2), in: t),
           let current = Int(t[currentRange]),
           let total = Int(t[totalRange]),
           total > 0 {
            let unitPart = match.numberOfRanges > 3 ? Range(match.range(at: 3), in: t).map { String(t[$0]).trimmingCharacters(in: .whitespaces) } ?? "" : ""
            let perStep = max(1, Int(ceil(Double(total) / Double(max(5, total / max(1, current))))))
            let unitSuffix = unitPart.isEmpty ? "" : " \(unitPart)"
            return "+\(perStep)\(unitSuffix)"
        }

        if t.lowercased().hasPrefix(goalTitle.lowercased()) {
            t = String(t.dropFirst(goalTitle.count)).trimmingCharacters(in: .whitespaces)
            while let first = t.first, "|—:-".contains(first) {
                t = String(t.dropFirst()).trimmingCharacters(in: .whitespaces)
            }
        }

        return t.isEmpty ? title : t
    }
}
