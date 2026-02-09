////
////  GoalSetting.swift
////  todoTask
////
////  Created by شهد عبدالله القحطاني on 20/08/1447 AH.
////
//
//


import Foundation


// ═══════════════════════════════════════════════════════════
// MARK: - Weekday (أيام الأسبوع)
// ═══════════════════════════════════════════════════════════

enum Weekday: String, CaseIterable, Codable {
    case saturday = "Sat"
    case sunday = "Sun"
    case monday = "Mon"
    case tuesday = "Tue"
    case wednesday = "Wed"
    case thursday = "Thu"
    case friday = "Fri"
    
    var fullName: String {
        switch self {
        case .saturday: return "السبت"
        case .sunday: return "الأحد"
        case .monday: return "الإثنين"
        case .tuesday: return "الثلاثاء"
        case .wednesday: return "الأربعاء"
        case .thursday: return "الخميس"
        case .friday: return "الجمعة"
        }
    }
}

// ═══════════════════════════════════════════════════════════
// MARK: - Time Window (نافذة الوقت)
// ═══════════════════════════════════════════════════════════

struct TimeWindow: Codable {
    let startTime: Date
    let endTime: Date
    let daysOfWeek: [Weekday]
}

// ═══════════════════════════════════════════════════════════
// MARK: - Goal Settings (الإعدادات الكاملة)
// ═══════════════════════════════════════════════════════════

struct GoalSettings {
    // Common
    var targetNumber: Int?
    var unit: String?
    var deadlineDate: Date?
    var daysAWeek: [Weekday] = []
    
    // Time
    var timeWindow: TimeWindow?
    var dailyEffort: Double = 50.0
    
    // Flexibility
    var makeupAllowed: Bool = false
    var breakDays: Int = 0
    
    // Activity (للياقة/تعلم)
    var activity: String?
    var targetLevel: String?
    var stepUpPace: String?
    var recoveryWeek: Bool = false
    
    // Scope (للمشاريع)
    var scopeSize: String?
    var dailyTimePreference: Int?
}

// ═══════════════════════════════════════════════════════════
// MARK: - Goal Config (للإنشاء)
// ═══════════════════════════════════════════════════════════

struct GoalConfig {
    let title: String
    let category: GoalCategory
    let goalType: GoalType
    let shape: GoalShape?
    let startDate: Date
    let endDate: Date?
}

// ═══════════════════════════════════════════════════════════
// MARK: - Category Rules (قواعد كل فئة)
// ═══════════════════════════════════════════════════════════

struct CategoryRules {
    let minDuration: Int // days
    let maxDuration: Int // days
    let requiresDailyCheckin: Bool
    let allowsSubTasks: Bool
    let recommendedSubTaskCount: ClosedRange<Int>
}
