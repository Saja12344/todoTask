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
