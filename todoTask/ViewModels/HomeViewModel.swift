//
//  HomeViewModel.swift
//  todoTask
//

import SwiftUI
import Foundation
import Combine

final class HomeViewModel: ObservableObject {
    
    @Published private(set) var formattedDate: String

    private let model: DayModel
    
    init(model: DayModel = DayModel(date: Date())) {
        self.model = model
        self.formattedDate = HomeViewModel.format(date: model.date)
    }
    
    private static func format(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM, yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let base = formatter.string(from: date)
        return base.uppercased()
    }
}

final class MiniCalendarViewModel: ObservableObject {
    @Published var selectedDate: Date
    @Published var displayedMonth: Date

    let today: Date = Date()
    private let calendar = Calendar.current
    
    init() {
        let now = Date()
        self.selectedDate = now
        self.displayedMonth = now
    }
    
    var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayedMonth)
    }
    
    var availableMonths: [Date] {
        let comps = calendar.dateComponents([.year], from: displayedMonth)
        guard let year = comps.year,
              let startOfYear = calendar.date(from: DateComponents(year: year, month: 1, day: 1))
        else { return [] }
        return (0..<12).compactMap { offset in
            calendar.date(byAdding: .month, value: offset, to: startOfYear)
        }
    }
    
    func changeMonth(to date: Date) {
        displayedMonth = date
        if !calendar.isDate(selectedDate, equalTo: date, toGranularity: .month) {
            selectedDate = calendar.startOfDay(for: date)
        }
    }
    
    func goToToday() {
        let now = Date()
        selectedDate = now
        displayedMonth = now
    }
    
    func moveWeek(by value: Int) {
        let weekday = calendar.component(.weekday, from: selectedDate)
        let startOfWeek = calendar.date(
            byAdding: .day,
            value: -(weekday - 1),
            to: calendar.startOfDay(for: selectedDate)
        )!
        let newDate = calendar.date(
            byAdding: .day,
            value: value * 7,
            to: startOfWeek
        )!
        selectedDate = newDate
        displayedMonth = newDate
    }
  
    var visibleWeek: [Date] {
        let calendar = Calendar.current
        let today = selectedDate
        let weekday = calendar.component(.weekday, from: today)
        let startOfWeek = calendar.date(
            byAdding: .day,
            value: -(weekday - 1),
            to: calendar.startOfDay(for: today)
        )!
        var week: [Date] = []
        for i in 0..<7 {
            if let day = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                week.append(day)
            }
        }
        return week
    }
}

final class NotificationPermissionManager {
    static let shared = NotificationPermissionManager()
    private init() {}

    func requestPermissionIfNeeded() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .notDetermined else { return }
            center.requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
        }
    }
}
