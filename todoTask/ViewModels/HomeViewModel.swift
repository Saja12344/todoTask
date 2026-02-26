//
//  HomeViewModel.swift
//  todoTask
//
//  Created by Jana Abdulaziz Malibari on 09/02/2026.
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
    @Published var displayedMonth: Date   // controls picker + visible month
    
    
    let today: Date = Date()
    private let calendar = Calendar.current
    
    init() {
        let now = Date()
        self.selectedDate = now
        self.displayedMonth = now
    }
    
    // MARK: - Month
    
    var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: displayedMonth)
    }
    
    var availableMonths: [Date] {
        let start = calendar.date(byAdding: .month, value: -6, to: today)!
        return (0..<12).compactMap {
            calendar.date(byAdding: .month, value: $0, to: start)
        }
    }
    
    func changeMonth(to date: Date) {
        displayedMonth = date
        
        // keep selection sane
        if !calendar.isDate(selectedDate, equalTo: date, toGranularity: .month) {
            selectedDate = calendar.startOfDay(for: date)
        }
    }
    
    // MARK: - Week
  
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
        
        // الرجوع إلى بداية الأسبوع (Sunday = 1)
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
