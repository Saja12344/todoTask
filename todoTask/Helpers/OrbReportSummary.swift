//
//  OrbReportSummary.swift
//  todoTask
//

import Foundation

struct OrbReportSummary {
    let totalGoals: Int
    let goalsCompleted: Int
    let averageProgressPercent: Int
    let goalsOverDeadline: Int

    static func from(goals: [OrbGoal]) -> OrbReportSummary {
        let total = goals.count
        let completed = goals.filter { $0.progress >= 1.0 }.count
        let avg = total > 0
            ? Int(round(goals.map(\.progress).reduce(0, +) / Double(total) * 100))
            : 0
        let now = Date()
        let overdue = goals.filter { goal in
            guard let end = goal.settings?.deadline else { return false }
            return end < now && goal.progress < 1.0
        }.count
        return OrbReportSummary(
            totalGoals: total,
            goalsCompleted: completed,
            averageProgressPercent: avg,
            goalsOverDeadline: overdue
        )
    }
}
