//
//  HomeModel.swift
//  todoTask
//
//  Created by Jana Abdulaziz Malibari on 09/02/2026.
//

// ═══════════════════════════════════════════════════════════
// MARK: - Date od the day(تاريخ اليوم)
// ═══════════════════════════════════════════════════════════

import Foundation

struct DayModel {
    let date: Date
}

struct CalendarDay: Identifiable {
    let id = UUID()
    let date: Date
}


// ═══════════════════════════════════════════════════════════
// MARK: - Repeort Progress(تقرير مسمتمر)
// ═══════════════════════════════════════════════════════════

struct ReportCard: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let icon: String
}

// ═══════════════════════════════════════════════════════════
// MARK: - Today's Energy(طاقة اليوم)
// ═══════════════════════════════════════════════════════════

struct Energytoday: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let icon: String
}

// Centralized static options to reuse across the app
extension Energytoday {
    static let defaults: [Energytoday] = [
        Energytoday(title: "Take Break",
                    value: "1",
                    icon: "figure.mind.and.body"),
        Energytoday(title: "Average",
                    value: "2",
                    icon: "figure.mixed.cardio"),
        Energytoday(title: "Hardcore",
                    value: "3",
                    icon: "figure.strengthtraining.traditional")
    ]
}
