//
//  GoalShape.swift
//  todoTask
//

import Foundation

// MARK: - Goal Shape (4 types — aligned with GoalType)

enum GoalShape: String, Codable, CaseIterable, Identifiable {
    case reachTarget = "Reach a Target"
    case buildHabit  = "Build a Habit"
    case levelUp     = "Level Up"
    case reduce      = "Reduce Something"

    var id: String { rawValue }

    var goalType: GoalType {
        switch self {
        case .reachTarget: return .reachTarget
        case .buildHabit:  return .buildHabit
        case .levelUp:     return .levelUp
        case .reduce:      return .reduce
        }
    }

    init(goalType: GoalType) {
        switch goalType {
        case .reachTarget: self = .reachTarget
        case .buildHabit:  self = .buildHabit
        case .levelUp:     self = .levelUp
        case .reduce:      self = .reduce
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        switch raw {
        case "Reach a Target", "reachTarget", "finishTotal", "Finish a Total",
             "Finish by Milestones", "finishByMilestones", "milestones":
            self = .reachTarget
        case "Build a Habit", "buildHabit", "repeatOnSchedule", "Repeat on Schedule",
             "buildStreak", "Build a Streak", "repeatSchedule":
            self = .buildHabit
        case "Level Up", "levelUp", "levelUpGradually", "Level Up Gradually":
            self = .levelUp
        case "Reduce Something", "reduce", "reduceSomething":
            self = .reduce
        default:
            self = .reachTarget
        }
    }
}

// MARK: - Goal Category

enum GoalCategory: String, Codable, CaseIterable {
    case habit
    case project
    case learning
    case fitness
    case finance
    case custom
}
