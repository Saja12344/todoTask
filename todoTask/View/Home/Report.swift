//
//  Report.swift
//  todoTask
//

import SwiftUI

struct Report: View {
    @EnvironmentObject private var userVM: UserViewModel
    @EnvironmentObject private var store: OrbGoalStore
    @EnvironmentObject private var lang: LanguageManager
    @StateObject private var vm = ReportScreenViewModel()

    private var orbSummary: OrbReportSummary {
        OrbReportSummary.from(goals: store.goals)
    }

    private var reportCards: [ReportCard] {
        let s = orbSummary
        return [
            ReportCard(title: lang.t(.reportTotalGoals), value: "\(s.totalGoals)", icon: "target"),
            ReportCard(title: lang.t(.reportGoalsCompleted), value: "\(s.goalsCompleted)", icon: "checkmark.seal.fill"),
            ReportCard(title: lang.t(.reportAvgProgress), value: "\(s.averageProgressPercent)%", icon: "chart.line.uptrend.xyaxis"),
            ReportCard(title: lang.t(.reportOverdue), value: "\(s.goalsOverDeadline)", icon: "calendar.badge.exclamationmark")
        ]
    }

    private var consistencyRows: [(dateKey: String, opened: Bool)] {
        guard !store.goals.isEmpty else { return [] }

        let cal = Calendar(identifier: .gregorian)
        let today = cal.startOfDay(for: Date())
        let startDate = UserProgressStore.consistencyStartDate(goals: store.goals, calendar: cal)

        let windowStart: Date = {
            if let ninetyDaysAgo = cal.date(byAdding: .day, value: -90, to: today) {
                return max(startDate, ninetyDaysAgo)
            }
            return startDate
        }()

        let stored = LoginTracker.load()
        var rows: [(dateKey: String, opened: Bool)] = []
        var cursor = windowStart
        while cursor <= today {
            let key = LoginTracker.dateKey(for: cursor)
            rows.append((dateKey: key, opened: stored.contains(key)))
            guard let next = cal.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = next
        }
        return rows.sorted(by: { $0.dateKey > $1.dateKey })
    }

    private var consistencyPercentageText: String {
        guard !consistencyRows.isEmpty else { return "0%" }
        let opened = consistencyRows.filter(\.opened).count
        let pct = Int(round(Double(opened) / Double(consistencyRows.count) * 100))
        return "\(pct)%"
    }

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
                    .fill(LinearGradient(colors: [.darkBlu, .dark], startPoint: .bottom, endPoint: .top))
                    .ignoresSafeArea()
                Image("Background 4")
                    .resizable()
                    .ignoresSafeArea()
                    .opacity(0.4)
                Image("Gliter")
                    .resizable()
                    .ignoresSafeArea()

                VStack(spacing: 10) {
                    Text(lang.t(.reportTitle))
                        .font(Font.largeTitle.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: lang.language == .arabic ? .trailing : .leading)
                        .padding(.horizontal, 24)

                    Color.clear
                    TabView {
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
                                .glassEffect(.clear, in: .rect(cornerRadius: 30))
                            }
                            .frame(width: 350, height: 160)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .automatic))
                    .padding(.all, -100)

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
                                    Text(lang.t(.reportConsistency))
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                    Text(consistencyPercentageText)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal)
                            }
                            ScrollView {
                                VStack(alignment: .leading, spacing: 8) {
                                    if consistencyRows.isEmpty {
                                        Text(lang.t(.reportConsistencyEmpty))
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.5))
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .padding(.vertical, 20)
                                    }
                                    ForEach(consistencyRows, id: \.dateKey) { row in
                                        HStack {
                                            Text(row.dateKey)
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.8))
                                            Spacer()
                                            HStack(spacing: 8) {
                                                Image(systemName: row.opened ? "checkmark.circle.fill" : "xmark.circle")
                                                    .foregroundColor(.white)
                                                Text(row.opened ? lang.t(.reportOpened) : lang.t(.reportMissed))
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
                                Text(lang.t(.reportEnergyOverTime))
                                    .font(.system(size: 14, weight: .semibold))
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
                                                Text(lang.localizedEnergyTitle(value: entry.value, fallback: entry.title))
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
        }
        .colorScheme(.dark)
    }
}

#Preview {
    Report()
        .environmentObject(UserViewModel())
        .environmentObject(OrbGoalStore())
        .environmentObject(LanguageManager())
}
