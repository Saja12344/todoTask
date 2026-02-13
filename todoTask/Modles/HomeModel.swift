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
