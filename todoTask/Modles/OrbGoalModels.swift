//
//  OrbGoalModels.swift
//  todoTask
//

import SwiftUI
import Foundation

// MARK: - GoalType ✅ 4 cases
enum GoalType: String, CaseIterable, Codable {
    case reachTarget = "Reach a Target"
    case buildHabit  = "Build a Habit"
    case levelUp     = "Level Up"
    case reduce      = "Reduce Something"

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        switch raw {
        case "reachTarget", "Reach a Target", "finishTotal", "milestones":
            self = .reachTarget
        case "buildHabit", "Build a Habit", "repeatSchedule", "buildStreak":
            self = .buildHabit
        case "levelUp", "Level Up":
            self = .levelUp
        case "reduce", "Reduce Something":
            self = .reduce
        default:
            self = .reachTarget
        }
    }
}

// MARK: - GoalTask
struct GoalTask: Identifiable, Codable, Hashable {
    var id:            UUID   = UUID()
    var goalID:        UUID
    var title:         String
    var isDone:        Bool   = false
    var scheduledDate: Date
}

// MARK: - GoalSettings ✅ + isStreakMode + isMilestoneMode
struct GoalSettings: Codable, Equatable {
    var goalType:         GoalType = .reachTarget
    var selectedDays:     Set<Int> = [1,2,3,4,5,6,7]
    var startTime:        Date     = Calendar.current.date(bySettingHour: 8,  minute: 0, second: 0, of: Date())!
    var endTime:          Date     = Calendar.current.date(bySettingHour: 9,  minute: 0, second: 0, of: Date())!
    var targetNumber:     Int      = 10
    var unit:             String   = ""
    var deadline:         Date     = Calendar.current.date(byAdding: .month, value: 1, to: Date())!
    var breakDaysAllowed: Int      = 0
    var stepUpPaceWeeks:  Int      = 1
    var scopeSize:        Double   = 50
    var dailyMinutes:     Int      = 30
    var baselineNumber:   Int      = 0
    var isReduceBy:       Bool     = true
    var isStreakMode:     Bool     = false
    var isMilestoneMode:  Bool     = false
}

// MARK: - ChallengeInfo
struct ChallengeInfo: Codable, Equatable {
    var challengeID:    String
    var opponentID:     String
    var opponentName:   String
    var friendProgress: Double
    var isWinner:       Bool
    var winnerID:       String?
}

// MARK: - OrbGoal
struct OrbGoal: Identifiable, Codable, Equatable {
    let id:    UUID
    var title: String

    var tasks:     [GoalTask]    = []
    var design:    OrbDesign
    var settings:  GoalSettings?
    var createdAt: Date          = Date()

    var challengeInfo: ChallengeInfo? = nil
    var isChallenge: Bool { challengeInfo != nil }

    var progress: Double {
        guard !tasks.isEmpty else { return 0 }
        return Double(tasks.filter(\.isDone).count) / Double(tasks.count)
    }

    var doneTasks:  Int { tasks.filter(\.isDone).count }
    var totalTasks: Int { tasks.count }

    func tasks(for date: Date) -> [GoalTask] {
        let cal     = Calendar.current
        let weekday = cal.component(.weekday, from: date)
        let activeDays = settings?.selectedDays ?? []

        guard activeDays.contains(weekday),
              let deadline = settings?.deadline,
              date <= deadline else { return [] }

        return tasks.filter { cal.isDate($0.scheduledDate, inSameDayAs: date) }
    }
}

// MARK: - OrbDesign
struct OrbDesign: Codable, Equatable {
    var glow:             Double
    var textureOpacity:   Double
    var textureAssetName: String?
    var gradientStops:    [RGBAColor]
}

struct TodayItem: Identifiable {
    let id   = UUID()
    let goal: OrbGoal
    let task: GoalTask
}

// MARK: - RGBAColor
struct RGBAColor: Codable, Equatable {
    var r, g, b, a: Double

    var swiftUIColor: Color {
        Color(.sRGB, red: r, green: g, blue: b, opacity: a)
    }

    static func from(_ color: Color) -> RGBAColor {
        color.toRGBA() ?? RGBAColor(r: 0.6, g: 0.2, b: 0.9, a: 1)
    }
}

import UIKit
extension Color {
    func toRGBA() -> RGBAColor? {
        let ui = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard ui.getRed(&r, green: &g, blue: &b, alpha: &a) else { return nil }
        return RGBAColor(r: Double(r), g: Double(g), b: Double(b), a: Double(a))
    }
}

// MARK: - Mock
extension OrbGoal {
    static var mock: OrbGoal {
        var g = OrbGoal(
            id: UUID(),
            title: "Learn Spanish",
            design: OrbDesign(
                glow: 0.12,
                textureOpacity: 0.85,
                textureAssetName: "effect1",
                gradientStops: [
                    RGBAColor(r: 0.16, g: 0.26, b: 0.95, a: 1),
                    RGBAColor(r: 0.60, g: 0.50, b: 0.98, a: 1),
                    RGBAColor(r: 0.93, g: 0.30, b: 0.96, a: 1)
                ]
            ),
            settings: GoalSettings(goalType: .reachTarget, selectedDays: [], targetNumber: 10, unit: "lessons")
        )
        g.tasks = [
            GoalTask(goalID: g.id, title: "Study 5 flashcards",    scheduledDate: Date()),
            GoalTask(goalID: g.id, title: "Listen 10 min podcast",  scheduledDate: Date()),
            GoalTask(goalID: g.id, title: "Write 3 sentences",      scheduledDate: Date()),
            GoalTask(goalID: g.id, title: "Review grammar notes",   scheduledDate: Date())
        ]
        return g
    }

    static var mockChallenge: OrbGoal {
        var g = OrbGoal(
            id: UUID(),
            title: "Run 5K Daily ⚡️",
            design: OrbDesign(
                glow: 0.12,
                textureOpacity: 0.85,
                textureAssetName: "effect2",
                gradientStops: [
                    RGBAColor(r: 0.8, g: 0.2, b: 0.9, a: 1),
                    RGBAColor(r: 0.4, g: 0.1, b: 0.8, a: 1)
                ]
            ),
            settings: GoalSettings(goalType: .reachTarget, selectedDays: [], targetNumber: 6, unit: "km")
        )
        g.tasks = [
            GoalTask(goalID: g.id, title: "Run 1 km", scheduledDate: Date()),
            GoalTask(goalID: g.id, title: "Run 2 km", scheduledDate: Date()),
            GoalTask(goalID: g.id, title: "Run 3 km", scheduledDate: Date())
        ]
        g.challengeInfo = ChallengeInfo(
            challengeID: "ch_001",
            opponentID: "user_002",
            opponentName: "Ahmed",
            friendProgress: 0.4,
            isWinner: false,
            winnerID: nil
        )
        return g
    }
}
