//
//  ViewGoalModels.swift
//  todoTask
//
//  Created by شهد عبدالله القحطاني on 20/08/1447 AH.
//


import Foundation



// ═══════════════════════════════════════════════════════════
// MARK: - Goal State (حالات الهدف)
// ═══════════════════════════════════════════════════════════

enum GoalState: String, Codable {
    case draft      // مسودة
    case active     // نشط
    case locked     // مقفل
    case completed  // مكتمل
    case failed     // فاشل
}

// ═══════════════════════════════════════════════════════════
// MARK: - Goal (الهدف الكامل)
// ═══════════════════════════════════════════════════════════

struct Goal: Identifiable, Codable {
    let id: String
    let userID: String
    var title: String
    let category: GoalCategory
    let goalType: GoalType
    let shape: GoalShape?
    let startDate: Date
    let endDate: Date?
    var subTasks: [SubTask]
    let challengeContext: ChallengeContext?
    var state: GoalState
    var planetState: PlanetState
    var planetDesign: PlanetDesign?
    let createdAt: Date
    var updatedAt: Date?
    var completedAt: Date?
}

// ═══════════════════════════════════════════════════════════
// MARK: - SubTask (المهمة الفرعية)
// ═══════════════════════════════════════════════════════════

struct SubTask: Identifiable, Codable {
    let id: String
    var title: String
    var description: String?
    let order: Int
    var isCompleted: Bool
    var isLocked: Bool
    var dependsOn: String?
    var completedAt: Date?
}

// ═══════════════════════════════════════════════════════════
// MARK: - SubTask Config (للإنشاء)
// ═══════════════════════════════════════════════════════════

struct SubTaskConfig {
    let title: String
    let description: String?
    let dependsOn: String?
}

// ═══════════════════════════════════════════════════════════
// MARK: - Goal Updates (للتحديث)
// ═══════════════════════════════════════════════════════════

struct GoalUpdates {
    let title: String?
    let subTasks: [SubTaskConfig]?
    let state: GoalState?
}

// ═══════════════════════════════════════════════════════════
// MARK: - Progress Snapshot (التقدم)
// ═══════════════════════════════════════════════════════════

struct ProgressSnapshot: Codable {
    let goalID: String
    let completedSubTasks: Int
    let totalSubTasks: Int
    let completionPercentage: Double
    let isLate: Bool
    let lastUpdated: Date
}

// ═══════════════════════════════════════════════════════════
// MARK: - Challenge Context (من سجى)
// ═══════════════════════════════════════════════════════════

struct ChallengeContext: Codable {
    let challengerID: String
    let opponentID: String?
    let planetStake: String
}
