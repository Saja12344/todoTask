//
//  SharedModle.swift
//  todoTask
//
//  Created by شهد عبدالله القحطاني on 19/08/1447 AH.
//


import Foundation

// MARK: -  Shared Models


enum GoalType: String, Codable {
    case habit
    case project
    case learning
    case fitness
    case finance
    case custom
}

// MARK: - Progress Snapshot

/// جنى تنشئه وترسله لشهد
struct ProgressSnapshot: Codable {
    let goalID: String
    let completedSubTasks: Int
    let totalSubTasks: Int
    let completionPercentage: Double
    let isLate: Bool
    let lastUpdated: Date
}

// MARK: - Game Outcome

/// جنى تنشئه لما الهدف ينتهي
struct GameOutcome: Codable {
    let goalID: String
    let finalState: String // "completed", "failed", "active"
    let completionDate: Date
    let totalSubTasks: Int
    let completedSubTasks: Int
}

// MARK: - Challenge Context

/// سجى ترسله لجنى لما يكون فيه تحدي
struct ChallengeContext: Codable {
    let challengerID: String
    let opponentID: String?
    let planetStake: String
}
