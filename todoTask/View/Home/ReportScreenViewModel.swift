//
//  ReportScreenViewModel.swift
//  todoTask
//
//  Created by You on 14/02/2026.
//

import Foundation
import Combine

// MARK: - Local login tracker (moved from view file)
enum LoginTracker {
    private static let key = "login.days" // stores Set<String> of yyyy-MM-dd
    private static let firstLaunchKey = "login.firstLaunchDate"

    static func recordTodayOpened() {
        let todayKey = dateKey(for: Date())
        var set = load()
        set.insert(todayKey)
        save(set)

        // Set first launch date if missing
        if UserDefaults.standard.object(forKey: firstLaunchKey) as? Date == nil {
            UserDefaults.standard.set(Date(), forKey: firstLaunchKey)
        }
    }

    static func load() -> Set<String> {
        if let data = UserDefaults.standard.array(forKey: key) as? [String] {
            return Set(data)
        }
        return []
    }

    static func save(_ set: Set<String>) {
        UserDefaults.standard.set(Array(set), forKey: key)
    }

    static func dateKey(for date: Date) -> String {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    // Build a 0/1 series for the current month
    static func monthSeries(for date: Date) -> [Int] {
        let cal = Calendar(identifier: .gregorian)
        let startOfMonth = cal.date(from: cal.dateComponents([.year, .month], from: date))!
        // Use half-open fallback to match API return type
        let range = cal.range(of: .day, in: .month, for: startOfMonth) ?? 1..<31
        let stored = load()
        return range.map { day in
            let d = cal.date(byAdding: .day, value: day - 1, to: startOfMonth)!
            let key = dateKey(for: d)
            return stored.contains(key) ? 1 : 0
        }
    }

    static func monthPercentage(for date: Date) -> Int {
        let series = monthSeries(for: date)
        guard !series.isEmpty else { return 0 }
        let sum = series.reduce(0, +)
        let cal = Calendar(identifier: .gregorian)
        let day = cal.component(.day, from: date)
        let denom = max(1, min(day, series.count))
        return Int(round(Double(sum) / Double(denom) * 100.0))
    }

    // Expose first launch date if set
    static func firstLaunchDate() -> Date? {
        UserDefaults.standard.object(forKey: firstLaunchKey) as? Date
    }

    // Best-effort earliest open date derived from stored keys
    static func earliestOpenDate() -> Date? {
        let stored = load()
        guard let minKey = stored.min() else { return nil }
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "yyyy-MM-dd"
        return f.date(from: minKey)
    }
}

// MARK: - Report screen view model
@MainActor
final class ReportScreenViewModel: ObservableObject {
    // Inputs
    @Published var goals: [Goal] = []

    // Outputs
    @Published private(set) var summary: ReportSummary = .empty
    @Published private(set) var isLoading: Bool = false

    // Dependencies
    private let energyVM: DailyEnergyViewModel
    private let planetVM: PlanetViewModel

    init(
        energyVM: DailyEnergyViewModel = DailyEnergyViewModel(),
        planetVM: PlanetViewModel = PlanetViewModel()
    ) {
        self.energyVM = energyVM
        self.planetVM = planetVM
        // Initialize energy for today
        self.energyVM.refreshToday()
        // Precompute initial summary
        recomputeSummary(planetsCount: 0)
    }

    func load(userID: String?) async {
        isLoading = true
        defer { isLoading = false }

        var planetsCount = 0
        if let uid = userID, !uid.isEmpty {
            do {
                try await planetVM.fetchMyPlanets(for: uid)
                planetsCount = planetVM.myPlanets.count
            } catch {
                print("Failed to fetch planets: \(error)")
                planetsCount = 0
            }
        }

        // Refresh local energy state
        energyVM.refreshToday()

        // Publish recomputed summary
        recomputeSummary(planetsCount: planetsCount)
    }

    // Allow external code to inject goals and recompute
    func setGoals(_ goals: [Goal]) {
        self.goals = goals
        recomputeSummary(planetsCount: summary.planetsCount)
    }

    // MARK: - Private
    private func recomputeSummary(planetsCount: Int) {
        // Goals derived metrics
        let totalGoals = goals.count
        let goalsCompleted = goals.filter { $0.state == .completed }.count
        let now = Date()
        let goalsOverDeadline = goals.filter { goal in
            if let end = goal.endDate {
                return end < now && goal.state != .completed
            }
            return false
        }.count

        // Consistency
        let series = LoginTracker.monthSeries(for: Date())
        let percentageText = "\(LoginTracker.monthPercentage(for: Date()))%"

        // Energy history (last 14 days from local storage)
        let energyHistory = Self.loadEnergyHistory()

        summary = ReportSummary(
            totalGoals: totalGoals,
            goalsCompleted: goalsCompleted,
            planetsCount: planetsCount,
            goalsOverDeadline: goalsOverDeadline,
            consistencySeries: series,
            consistencyPercentageText: percentageText,
            energyHistory: energyHistory
        )
    }

    private static func loadEnergyHistory() -> [DailyEnergyEntry] {
        let key = "dailyEnergy.entries"
        guard let data = UserDefaults.standard.data(forKey: key),
              let dict = try? JSONDecoder().decode([String: DailyEnergyEntry].self, from: data)
        else { return [] }
        let sorted = dict.values.sorted { $0.dateKey > $1.dateKey }
        return Array(sorted.prefix(14))
    }
}
