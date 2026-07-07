//
//  OrbGoalModels.swift
//  todoTask
//

import SwiftUI
import Foundation

// MARK: - GoalType ✅ 4 cases
enum GoalType: String, CaseIterable, Codable, Hashable {
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
    var id:              UUID   = UUID()
    var goalID:          UUID
    var title:           String
    var isDone:          Bool   = false
    var scheduledDate:   Date
    /// How much this session asks for (e.g. 4 books today).
    var targetAmount:    Int    = 1
    /// How much the user actually did (e.g. 3 of 4).
    var completedAmount: Int    = 0
    /// Optional note the user writes after finishing (reflection).
    var reflectionNote: String? = nil
    /// Which prompt was shown when they wrote the note.
    var reflectionPromptKey: String? = nil
    /// When the task was first fully completed.
    var completedAt: Date? = nil

    var isFullyComplete: Bool {
        targetAmount > 0 && completedAmount >= targetAmount
    }

    mutating func syncDoneFlag() {
        isDone = isFullyComplete
    }
}

// MARK: - GoalSettings ✅ + isStreakMode + isMilestoneMode
struct GoalSettings: Codable, Equatable {
    var goalType:         GoalType = .reachTarget
    var selectedDays:     Set<Int> = [1,2,3,4,5,6,7]
    var startTime:        Date     = Calendar.current.date(bySettingHour: 8,  minute: 0, second: 0, of: Date())!
    var endTime:          Date     = Calendar.current.date(bySettingHour: 9,  minute: 0, second: 0, of: Date())!
    var targetNumber:     Int      = 10
    var unit:             String   = ""
    /// nil until the user picks a date in goal setup — calendar must not filter by deadline when nil.
    var deadline:         Date?    = nil
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

    /// Tasks rolled forward after 34h+ overdue (show «متأخر» on the new day).
    var lateTaskIDs: [UUID: Bool] = [:]

    var progress: Double {
        guard !tasks.isEmpty else { return 0 }

        if let settings, settings.goalType == .reachTarget, !settings.isMilestoneMode {
            let goalTotal = max(1, settings.targetNumber)
            let done = tasks.reduce(0) { $0 + min($1.completedAmount, $1.targetAmount) }
            return min(1.0, Double(done) / Double(goalTotal))
        }

        let total = tasks.reduce(0) { $0 + max(1, $1.targetAmount) }
        guard total > 0 else {
            return Double(tasks.filter(\.isDone).count) / Double(tasks.count)
        }
        let done = tasks.reduce(0) { $0 + min($1.completedAmount, $1.targetAmount) }
        return min(1.0, Double(done) / Double(total))
    }

    var doneTasks:  Int { tasks.filter(\.isDone).count }
    var totalTasks: Int { tasks.count }

    /// Every scheduled task on this orb is fully done.
    var isOrbFullyComplete: Bool {
        guard !tasks.isEmpty else { return false }
        return tasks.allSatisfy(\.isFullyComplete)
    }

    var hasOrbReflection: Bool {
        tasks.contains { !($0.reflectionNote ?? "").isEmpty }
    }

    /// Units completed toward the goal (e.g. 7 books when 3+4 on two days).
    var completedUnits: Int {
        tasks.reduce(0) { $0 + min($1.completedAmount, max(1, $1.targetAmount)) }
    }

    var targetUnits: Int {
        if let settings, settings.goalType == .reachTarget, !settings.isMilestoneMode {
            return max(1, settings.targetNumber)
        }
        return max(1, tasks.reduce(0) { $0 + max(1, $1.targetAmount) })
    }

    /// Primary: readable step label. Secondary: goal name.
    func todayTaskLines(for task: GoalTask, lang: LanguageManager) -> (primary: String, secondary: String) {
        (GoalTaskDisplay.todayPrimary(for: task, in: self, lang: lang), title)
    }

    var accentColor: Color {
        design.gradientStops.first?.swiftUIColor ?? Color("accent")
    }

    func tasks(for date: Date) -> [GoalTask] {
        let cal = Calendar.current

        if let settings, let deadline = settings.deadline {
            let day = cal.startOfDay(for: date)
            if day > cal.startOfDay(for: deadline) { return [] }
            let activeDays = settings.selectedDays
            if !activeDays.isEmpty {
                let weekday = cal.component(.weekday, from: date)
                guard activeDays.contains(weekday) else { return [] }
            }
        }

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
    let id: UUID
    let goal: OrbGoal
    let task: GoalTask
    let isLate: Bool
    /// Firebase challenge task id when this row comes from a friend challenge.
    let challengeTaskId: String?

    init(goal: OrbGoal, task: GoalTask, isLate: Bool = false, challengeTaskId: String? = nil) {
        self.id = task.id
        self.goal = goal
        self.task = task
        self.isLate = isLate
        self.challengeTaskId = challengeTaskId
    }

    var isChallengeMission: Bool { challengeTaskId != nil }
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
