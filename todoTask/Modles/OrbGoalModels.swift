//
//  OrbGoalModels.swift
//  todoTask
//
//  استبدل الملف الموجود بهذا كاملاً
//

import SwiftUI
import Foundation

// MARK: - GoalTask
struct GoalTask: Identifiable, Codable, Hashable {
    var id:     UUID   = UUID()
    var title:  String
    var isDone: Bool   = false
    // اليوم المحدد لهذه المهمة (nil = يظهر كل يوم نشط)
    var scheduledDate: Date? = nil
}

// MARK: - GoalSettings (يُخزن داخل OrbGoal)
struct GoalSettings: Codable, Equatable {
    var goalType:         GoalType    = .finishTotal
    var selectedDays:     Set<Int>   = [1,2,3,4,5]  // 0=Sun … 6=Sat
    var startTime:        Date       = Calendar.current.date(bySettingHour: 8,  minute: 0, second: 0, of: Date())!
    var endTime:          Date       = Calendar.current.date(bySettingHour: 9,  minute: 0, second: 0, of: Date())!
    var targetNumber:     Int        = 10
    var unit:             String     = ""
    var deadline:         Date       = Calendar.current.date(byAdding: .month, value: 1, to: Date())!
    var breakDaysAllowed: Int        = 0
    var stepUpPaceWeeks:  Int        = 1
    var scopeSize:        Double     = 50
    var dailyMinutes:     Int        = 30
    var baselineNumber:   Int        = 0
    var isReduceBy:       Bool       = true
}

// MARK: - OrbGoal
struct OrbGoal: Identifiable, Codable, Equatable {
    let id:    UUID
    var title: String

    // Tasks array — progress محسوب تلقائياً
    var tasks: [GoalTask] = []

    // Planet design
    var design:   OrbDesign
    var settings: GoalSettings?

    // الإنشاء تاريخ (لحساب الجدول)
    var createdAt: Date = Date()

    // ── Computed ──────────────────────────────────────────
    var progress: Double {
        guard !tasks.isEmpty else { return 0 }
        return Double(tasks.filter(\.isDone).count) / Double(tasks.count)
    }

    var doneTasks: Int  { tasks.filter(\.isDone).count }
    var totalTasks: Int { tasks.count }

    // المهام المجدولة لتاريخ معين
    func tasks(for date: Date) -> [GoalTask] {
        let cal = Calendar.current
        let weekday = cal.component(.weekday, from: date) - 1 // 0=Sun
        let activeDays = settings?.selectedDays ?? Set(0...6)

        guard activeDays.contains(weekday) else { return [] }

        return tasks.filter { task in
            if let sd = task.scheduledDate {
                return cal.isDate(sd, inSameDayAs: date)
            }
            return true // بدون تحديد → يظهر كل يوم نشط
        }
    }
}

// MARK: - OrbDesign
struct OrbDesign: Codable, Equatable {
    var glow:              Double
    var textureOpacity:    Double
    var textureAssetName:  String?
    var gradientStops:     [RGBAColor]
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
            settings: GoalSettings(
                goalType: .finishTotal,
                selectedDays: [1,2,3,4,5],
                targetNumber: 10,
                unit: "lessons"
            )
        )
        g.tasks = [
            GoalTask(title: "Study 5 flashcards"),
            GoalTask(title: "Listen 10 min podcast"),
            GoalTask(title: "Write 3 sentences"),
            GoalTask(title: "Review grammar notes")
        ]
        return g
    }
}
