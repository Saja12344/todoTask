//
//  AnalyticsTimelineViewModel.swift
//  todoTask
//
//  Created by شهد عبدالله القحطاني on 19/08/1447 AH.
//


import Foundation
import SwiftUI
import Combine

// MARK: - Analytics & Timeline ViewModel

class AnalyticsTimelineViewModel: ObservableObject {
    
    @Published var analyticsReport: AnalyticsReport?
    @Published var timelineEvents: [TimelineEvent] = []
    @Published var insightSummary: InsightSummary?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Core Responsibilities
    
    /// snapshot من جنى
    func aggregateWeeklyPerformance(
        for userID: String,
        snapshot: ProgressSnapshot,
        goalType: GoalType,
        completionHistory: [Date]
    ) {
        isLoading = true
        errorMessage = nil
        
        let weekRange = getCurrentWeekRange()
        let completionRate = calculateCompletionRate(from: snapshot)
        let onTimeRate = calculateOnTimeRate(from: snapshot)
        let currentStreak = calculateStreak(from: completionHistory, goalType: goalType)
        
        let report = AnalyticsReport(
            userID: userID,
            weekRange: weekRange,
            completionRate: completionRate,
            onTimeRate: onTimeRate,
            streak: currentStreak
        )
        
        DispatchQueue.main.async {
            self.analyticsReport = report
            self.isLoading = false
        }
    }
    
    
    
    /// 2. Completion & Failure Rates
    private func calculateCompletionRate(from snapshot: ProgressSnapshot) -> Double {
        guard snapshot.totalSubTasks > 0 else { return 0.0 }
        let completionRate = Double(snapshot.completedSubTasks) / Double(snapshot.totalSubTasks)
        return completionRate * 100
    }
    
    private func calculateFailureRate(from snapshot: ProgressSnapshot) -> Double {
        return 100.0 - calculateCompletionRate(from: snapshot)
    }
    
    /// 3. On-time vs Late Detection Logic
    private func calculateOnTimeRate(from snapshot: ProgressSnapshot) -> Double {
        if snapshot.isLate {
            return 0.0
        } else {
            return snapshot.completionPercentage
        }
    }
    
    
    /// 4. Timeline & Calendar Data Builder
    func buildTimelineData(for goalID: String, events: [TimelineEvent]) {
        isLoading = true
        
        let filteredEvents = events.filter { $0.goalID == goalID }
        let sortedEvents = filteredEvents.sorted { $0.date < $1.date }
        
        DispatchQueue.main.async {
            self.timelineEvents = sortedEvents
            self.isLoading = false
        }
    }
    
    
    /// 5. Solo vs Shared Goal Metrics
    func calculateSoloVsSharedMetrics(goals: [GoalForAnalytics]) -> (soloAvg: Double, sharedAvg: Double) {
        let soloGoals = goals.filter { !$0.isShared }
        let sharedGoals = goals.filter { $0.isShared }
        
        let soloAvgCompletion = soloGoals.isEmpty ? 0.0 :
            soloGoals.map { $0.completionRate }.reduce(0, +) / Double(soloGoals.count)
        
        let sharedAvgCompletion = sharedGoals.isEmpty ? 0.0 :
            sharedGoals.map { $0.completionRate }.reduce(0, +) / Double(sharedGoals.count)
        
        return (soloAvgCompletion, sharedAvgCompletion)
    }
    
    
    /// 6. Trend Detection (Improving / Declining)
    func detectTrend(currentWeek: Double, previousWeek: Double) -> TrendDirection {
        let difference = currentWeek - previousWeek
        let threshold = 5.0
        
        if difference > threshold {
            return .improving
        } else if difference < -threshold {
            return .declining
        } else {
            return .stable
        }
    }
    
    
    /// 7. Generate Insight Summary
    func generateInsightSummary(currentReport: AnalyticsReport, previousReport: AnalyticsReport?) {
        isLoading = true
        
        guard let previous = previousReport else {
            let summary = InsightSummary(
                title: "أداءك هذا الأسبوع",
                description: "معدل إنجازك: \(String(format: "%.1f", currentReport.completionRate))%",
                trend: .stable,
                percentage: currentReport.completionRate
            )
            
            DispatchQueue.main.async {
                self.insightSummary = summary
                self.isLoading = false
            }
            return
        }
        
        let trend = detectTrend(
            currentWeek: currentReport.completionRate,
            previousWeek: previous.completionRate
        )
        
        let percentageChange = currentReport.completionRate - previous.completionRate
        
        let description: String
        switch trend {
        case .improving:
            description = "رائع! تحسن أداؤك بنسبة \(String(format: "%.1f", abs(percentageChange)))% 🎉"
        case .declining:
            description = "انتبهي! تراجع أداؤك بنسبة \(String(format: "%.1f", abs(percentageChange)))% 📉"
        case .stable:
            description = "أداؤك مستقر عند \(String(format: "%.1f", currentReport.completionRate))% ✨"
        }
        
        let summary = InsightSummary(
            title: "تحليل الأداء الأسبوعي",
            description: description,
            trend: trend,
            percentage: abs(percentageChange)
        )
        
        DispatchQueue.main.async {
            self.insightSummary = summary
            self.isLoading = false
        }
    }
    
    
    /// 8. Habit Streak Tracking (15-day logic)
    func calculateStreak(from completionHistory: [Date], goalType: GoalType) -> Int {
        guard goalType == .habit else { return 0 }
        
        let sortedDates = completionHistory.sorted(by: >)
        guard let mostRecent = sortedDates.first else { return 0 }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let mostRecentDay = calendar.startOfDay(for: mostRecent)
        
        let daysDifference = calendar.dateComponents([.day], from: mostRecentDay, to: today).day ?? 0
        
        if daysDifference > 1 {
            return 0
        }
        
        var streak = 0
        var currentDate = mostRecentDay
        
        for date in sortedDates {
            let checkDate = calendar.startOfDay(for: date)
            let difference = calendar.dateComponents([.day], from: checkDate, to: currentDate).day ?? 0
            
            if difference <= 1 {
                streak += 1
                currentDate = checkDate
            } else {
                break
            }
        }
        
        return streak
    }
    
    
    /// 9. Project Duration Tracking
    func trackProjectDuration(startDate: Date, endDate: Date?, goalType: GoalType) -> Int? {
        guard goalType == .project else { return nil }
        
        let calendar = Calendar.current
        let end = endDate ?? Date()
        
        let components = calendar.dateComponents([.day], from: startDate, to: end)
        return components.day
    }
    
    
    /// 10. Completion vs Failure Rate (Enhanced)
    func calculateCompletionVsFailureRate(goals: [GoalWithStatus]) -> (completionRate: Double, failureRate: Double) {
        guard !goals.isEmpty else { return (0.0, 0.0) }
        
        let completedCount = goals.filter { $0.status == "completed" }.count
        let failedCount = goals.filter { $0.status == "failed" }.count
        let totalCount = goals.count
        
        let completionRate = (Double(completedCount) / Double(totalCount)) * 100
        let failureRate = (Double(failedCount) / Double(totalCount)) * 100
        
        return (completionRate, failureRate)
    }
    
    
    // MARK: - Helper Functions
    
    private func getCurrentWeekRange() -> DateInterval {
        let calendar = Calendar.current
        let today = Date()
        
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start else {
            return DateInterval(start: today, end: today)
        }
        
        guard let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) else {
            return DateInterval(start: weekStart, end: today)
        }
        
        return DateInterval(start: weekStart, end: weekEnd)
    }
}

// MARK: - Models (خاصه في لوجك شهد بس )

struct AnalyticsReport {
    let userID: String
    let weekRange: DateInterval
    let completionRate: Double
    let onTimeRate: Double
    let streak: Int
}

struct TimelineEvent {
    let date: Date
    let goalID: String
    let eventType: String
}

struct InsightSummary {
    let title: String
    let description: String
    let trend: TrendDirection
    let percentage: Double
}

enum TrendDirection {
    case improving
    case declining
    case stable
}

struct GoalForAnalytics {
    let id: String
    let name: String
    let isShared: Bool
    let completionRate: Double
}

struct GoalWithStatus {
    let id: String
    let status: String
    let goalType: GoalType // ⬅️ من SharedModels.swift
    let startDate: Date
    let endDate: Date?
}
