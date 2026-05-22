//
//  UserProgressStore.swift
//  todoTask
//

import Foundation

/// Local progress data for reports, energy, and login consistency — reset with goals.
enum UserProgressStore {
    private static let loginDaysKey = "login.days"
    private static let firstLaunchKey = "login.firstLaunchDate"
    private static let energyKey = "dailyEnergy.entries"
    private static let energyDeferPrefix = "energy.deferred."

    static func resetAll() {
        UserDefaults.standard.removeObject(forKey: loginDaysKey)
        UserDefaults.standard.removeObject(forKey: firstLaunchKey)
        UserDefaults.standard.removeObject(forKey: energyKey)

        for key in UserDefaults.standard.dictionaryRepresentation().keys where key.hasPrefix(energyDeferPrefix) {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }

    /// Consistency window starts when the user has goals (or today if empty).
    static func consistencyStartDate(goals: [OrbGoal], calendar: Calendar = .current) -> Date {
        let today = calendar.startOfDay(for: Date())
        guard let earliest = goals.map(\.createdAt).min() else { return today }
        return calendar.startOfDay(for: earliest)
    }
}
