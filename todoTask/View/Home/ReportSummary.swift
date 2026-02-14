//
//  ReportSummary.swift
//  todoTask
//
//  Created by You on 14/02/2026.
//

import Foundation

// Immutable model consumed by the Report view
struct ReportSummary: Equatable {
    // Top cards
    let totalGoals: Int
    let goalsCompleted: Int
    let planetsCount: Int
    let goalsOverDeadline: Int

    // Consistency
    let consistencySeries: [Int] // 0/1 per day of current month
    let consistencyPercentageText: String // e.g., "67%"

    // Energy
    let energyHistory: [DailyEnergyEntry]

    // Convenience for empty state
    static let empty = ReportSummary(
        totalGoals: 0,
        goalsCompleted: 0,
        planetsCount: 0,
        goalsOverDeadline: 0,
        consistencySeries: [],
        consistencyPercentageText: "0%",
        energyHistory: []
    )
}
