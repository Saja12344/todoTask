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
// MARK: - Challenge State
// ═══════════════════════════════════════════════════════════

enum ChallengeState: String, Codable {
    case draft
    case pendingAcceptance
    case active
    case locked
    case completed
    case rejected
}

// ═══════════════════════════════════════════════════════════
// MARK: - Challenge Model
// ═══════════════════════════════════════════════════════════



struct Challenge: Codable, Identifiable {
    var id: String { recordID ?? UUID().uuidString }
    
    var recordID: String?
    var challengerID: String
    var opponentID: String?
    
    var state: ChallengeState
    
    // Planet Stakes optional
    var planetStakeID: String?           // كوكب الـ challenger (optional)
    var opponentPlanetID: String?        // كوكب opponent (optional)
    
    // Goal associated (optional)
    var goalContext: Goal?               // الهدف المرتبط بالتحدي (optional)
    
    var createdAt: Date
    var editDeadline: Date
}


// ═══════════════════════════════════════════════════════════
// MARK: - Challenge Context
// ═══════════════════════════════════════════════════════════

struct ChallengeContext: Codable {
    let challengeID: String       // ID للـ Challenge نفسه
    let challengerID: String
    let opponentID: String?
    let planetStakeID: String?    // ID للكوكب لو موجود
    let state: ChallengeState     // حالة التحدي الحالية
}
