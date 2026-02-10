//
//  GoalShape.swift
//  todoTask
//
//  Created by شهد عبدالله القحطاني on 20/08/1447 AH.
//

import Foundation


// ═══════════════════════════════════════════════════════════
// MARK: - Goal Shape
// ═══════════════════════════════════════════════════════════

enum GoalShape: String, Codable, CaseIterable, Identifiable {
    case finishTotal = "Finish a Total"
    case repeatOnSchedule = "Repeat on Schedule"
    case buildStreak = "Build a Streak"
    case levelUpGradually = "Level Up Gradually"
    case finishByMilestones = "Finish by Milestones"
    case reduceSomething = "Reduce Something"
    
    var id: String { self.rawValue }
}

// ═══════════════════════════════════════════════════════════
// MARK: - Goal Category
// ═══════════════════════════════════════════════════════════

enum GoalCategory: String, Codable, CaseIterable {
    case habit
    case project
    case learning
    case fitness
    case finance
    case custom
}

// ═══════════════════════════════════════════════════════════
// MARK: - Goal Type
// ═══════════════════════════════════════════════════════════
//
enum GoalType: String, Codable {
    case finishTotal
    case repeatSchedule
    case buildStreak
    case levelUp
    case milestones
    case reduce
}
