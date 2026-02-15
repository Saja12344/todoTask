//
//  Report.swift
//  todoTask
//
//  Created by Jana Abdulaziz Malibari on 11/02/2026.
//

import SwiftUI
import Combine

struct Report: View {
    @EnvironmentObject private var userVM: UserViewModel
    @StateObject private var vm = ReportScreenViewModel()

    // Build cards from published summary
    private var reportCards: [ReportCard] {
        [
            ReportCard(title: "Total Goals",
                       value: "\(vm.summary.totalGoals)",
                       icon: "target"),
            ReportCard(title: "Goals Completed",
                       value: "\(vm.summary.goalsCompleted)",
                       icon: "checkmark.seal.fill"),
            ReportCard(title: "Total Planets",
                       value: "\(vm.summary.planetsCount)",
                       icon: "globe.americas.fill"),
            ReportCard(title: "Over Deadline",
                       value: "\(vm.summary.goalsOverDeadline)",
                       icon: "calendar.badge.exclamationmark")
        ]
    }

    // Build consistency rows (most recent first) from first use date to today
    private var consistencyRows: [(dateKey: String, opened: Bool)] {
        let cal = Calendar(identifier: .gregorian)
        let today = cal.startOfDay(for: Date())

        // Start date selection:
        // 1) If you later add createdAt to your User model, prefer it here.
        // 2) Otherwise use locally persisted firstLaunchDate.
        // 3) Fallback to earliest open date from stored keys.
        // 4) Final fallback: today (so it shows only today).
        let startDate: Date = {
            // Prefer locally stored first launch date
            if let first = UserDefaults.standard.object(forKey: "login.firstLaunchDate") as? Date {
                return cal.startOfDay(for: first)
            }
            // Fallback to earliest open date based on stored keys
            let stored = LoginTracker.load()
            if let minKey = stored.min(),
               let parsed = Self.parseDateKey(minKey) {
                return cal.startOfDay(for: parsed)
            }
            // Last fallback: today
            return today
        }()

        // Cap the window to keep UI manageable (e.g., last 90 days)
        let windowStart: Date = {
            if let ninetyDaysAgo = cal.date(byAdding: .day, value: -90, to: today) {
                return max(startDate, ninetyDaysAgo)
            }
            return startDate
        }()

        // Build rows from windowStart to today (inclusive)
        let stored = LoginTracker.load()
        var rows: [(dateKey: String, opened: Bool)] = []

        var cursor = windowStart
        while cursor <= today {
            let key = LoginTracker.dateKey(for: cursor)
            rows.append((dateKey: key, opened: stored.contains(key)))
            guard let next = cal.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = next
        }

        // Sort newest first
        return rows.sorted(by: { $0.dateKey > $1.dateKey })
    }

    // Helper to parse yyyy-MM-dd keys back into Date
    private static func parseDateKey(_ key: String) -> Date? {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "yyyy-MM-dd"
        return f.date(from: key)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Rectangle()
                    .fill(LinearGradient(colors: [.color, .dark], startPoint: .bottom, endPoint: .top))
                    .ignoresSafeArea()
                Image("Background 4")
                    .resizable()
                    .ignoresSafeArea()
                    .opacity(0.4)
                Image("Gliter")
                    .resizable()
                    .ignoresSafeArea()

                VStack(spacing: 10){
                    Text("Progress Report")
                        .font(Font.largeTitle.bold())
                        .foregroundColor(.white)
                        .padding(.leading,-80)

                    Color.clear
                    TabView{
                        ForEach(reportCards) { card in
                            ZStack {
                                HStack {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 30)
                                            .fill(Color.white.opacity(0.2))

                                        Image(systemName: card.icon)
                                            .font(.system(size: 40))
                                            .foregroundColor(.white)
                                    }
                                    .frame(width: 175)

                                    VStack(alignment: .leading) {
                                        Text(card.value)
                                            .font(.system(size: 50, weight: .bold))
                                            .foregroundColor(.white)

                                        Text(card.title)
                                            .font(.title3)
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    .padding()

                                    Spacer()
                                }
                                .glassEffect(.clear, in: .rect (cornerRadius: 30))
                            }
                            .frame(width:350, height: 160)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .automatic))
                    .padding(.all, -100)

                    // Consistency card (logs instead of chart)
                    ZStack {
                        Rectangle()
                            .frame(width: 340, height: 200)
                            .cornerRadius(20)
                            .foregroundColor(Color.clear)
                        VStack(spacing: 0) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .frame(width: 340, height: 45)
                                    .foregroundColor(Color.white.opacity(0.2))

                                HStack {
                                    Text("Consistency")
                                        .font(.system(size: 14, weight: .semibold, design: .default))
                                        .foregroundColor(.white)

                                    Text(vm.summary.consistencyPercentageText)
                                        .font(.system(size: 14, weight: .semibold, design: .default))
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal)
                            }

                            // Logs list
                            ScrollView {
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(consistencyRows, id: \.dateKey) { row in
                                        HStack {
                                            Text(row.dateKey)
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.8))
                                            Spacer()
                                            HStack(spacing: 8) {
                                                Image(systemName: row.opened ? "checkmark.circle.fill" : "xmark.circle")
                                                    .foregroundColor(.white)
                                                Text(row.opened ? "Opened" : "Missed")
                                                    .foregroundColor(.white)
                                                    .font(.caption)
                                            }
                                        }
                                        .frame(width: 290)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.white.opacity(0.08))
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                }
                                .padding(10)
                            }
                            .frame(height: 155)
                            .scrollIndicators(.hidden)
                        }
                    }
                    .glassEffect(.clear, in: .rect(cornerRadius: 20))
                    .padding(.top, 80)

                    // Energy Over Time
                    ZStack {
                        Rectangle()
                            .frame(width: 340, height: 200)
                            .cornerRadius(20)
                            .foregroundColor(Color.clear)

                        VStack(spacing: 0) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .frame(width: 340, height: 45)
                                    .foregroundColor(Color.white.opacity(0.2))

                                Text("Energy Over Time")
                                    .font(.system(size: 14, weight: .semibold, design: .default))
                                    .foregroundColor(.white)
                            }

                            ScrollView {
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(vm.summary.energyHistory) { entry in
                                        HStack {
                                            Text(entry.dateKey)
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.8))
                                            Spacer()
                                            HStack(spacing: 8) {
                                                Image(systemName: entry.icon)
                                                    .foregroundColor(.white)
                                                Text(entry.title)
                                                    .foregroundColor(.white)
                                                    .font(.caption)
                                            }
                                        }
                                        .frame(width: 290)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.white.opacity(0.08))
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                }
                                .padding(10)
                            }
                            .frame(height: 155)
                            .scrollIndicators(.hidden)
                        }
                    }
                    .glassEffect(.clear, in: .rect(cornerRadius: 20))
                }
                .padding(.bottom, 20)
            }
        }
        .task {
            await vm.load(userID: userVM.currentUser?.id)
            // Record open and ensure firstLaunchDate is set if missing
            LoginTracker.recordTodayOpened()
        }
        .colorScheme(.dark)
    }
}

// MARK: - Tiny inline chart view (bars) — no longer used, but kept if needed elsewhere
private struct ConsistencyMiniChart: View {
    let series: [Int] // 0/1 per day of current month

    var body: some View {
        GeometryReader { geo in
            let count = max(1, series.count)
            let barWidth = max(2, (geo.size.width / CGFloat(count)).rounded(.down) - 1)
            let maxHeight = geo.size.height

            HStack(alignment: .bottom, spacing: 1) {
                ForEach(series.indices, id: \.self) { i in
                    let v = CGFloat(series[i])
                    RoundedRectangle(cornerRadius: 2)
                        .fill(v > 0 ? Color.accentColor : Color.white.opacity(0.15))
                        .frame(width: barWidth, height: v * maxHeight)
                }
            }
        }
    }
}

#Preview {
    Report()
        .environmentObject(UserViewModel())
}
