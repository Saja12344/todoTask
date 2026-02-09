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
        formatter.dateFormat = "d, MMM, yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        let base = formatter.string(from: date)
        return base.uppercased()
    }
}


final class MiniCalendarViewModel: ObservableObject {

    // MARK: - Published
    @Published private(set) var visibleDays: [CalendarDay] = []
    @Published var selectedDate: Date
    @Published var selectedMonth: Date

    // MARK: - Private
    private let calendar = Calendar.current
    private var currentWeekStart: Date

    init() {
        let today = Date()
        self.selectedDate = today
        self.selectedMonth = today
        self.currentWeekStart = calendar.dateInterval(of: .weekOfMonth, for: today)!.start
        generateWeek()
    }

    // MARK: - Month Picker
    var months: [Date] {
        (0..<12).compactMap {
            calendar.date(byAdding: .month, value: $0, to: startOfYear)
        }
    }

    private var startOfYear: Date {
        calendar.date(from: calendar.dateComponents([.year], from: Date()))!
    }

    func changeMonth(_ month: Date) {
        selectedMonth = month
        currentWeekStart = calendar.dateInterval(of: .weekOfMonth, for: month)!.start
        generateWeek()
    }

    // MARK: - Week Navigation
    func nextWeek() {
        moveWeek(by: 1)
    }

    func previousWeek() {
        moveWeek(by: -1)
    }

    private func moveWeek(by value: Int) {
        guard let next = calendar.date(byAdding: .weekOfMonth, value: value, to: currentWeekStart),
              calendar.isDate(next, equalTo: selectedMonth, toGranularity: .month)
        else { return }

        currentWeekStart = next
        generateWeek()
    }

    // MARK: - Generate Days
    private func generateWeek() {
        visibleDays = (0..<7).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: currentWeekStart),
                  calendar.isDate(date, equalTo: selectedMonth, toGranularity: .month)
            else { return nil }

            return CalendarDay(date: date)
        }
    }

    // MARK: - Formatting
    func monthTitle(_ date: Date) -> String {
        date.formatted(.dateTime.month(.wide))
    }

    func dayName(_ date: Date) -> String {
        date.formatted(.dateTime.weekday(.abbreviated)).uppercased()
    }

    func dayNumber(_ date: Date) -> String {
        date.formatted(.dateTime.day())
    }
}
