//
//  GoalShapeViewModel.swift
//  todoTask
//
//  Created by شهد عبدالله القحطاني on 20/08/1447 AH.
//


import Foundation
import SwiftUI
import Combine



class GoalShapeViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var selectedShape: GoalShape?
    @Published var suggestedShape: GoalShape?
    
    // MARK: - Initialization
    init() {
        suggestedShape = .levelUpGradually
    }
    
    // MARK: - Shape Selection
    
    func selectShape(_ shape: GoalShape) {
        selectedShape = shape
    }
    
    func getAllShapes() -> [GoalShape] {
        return GoalShape.allCases
    }
    
    func isShapeSelected() -> Bool {
        return selectedShape != nil
    }
    
    // MARK: - Shape Suggestions
    
    func suggestShape(for category: GoalCategory) -> GoalShape {
        switch category {
        case .habit:
            return .buildStreak
        case .project:
            return .finishByMilestones
        case .learning:
            return .levelUpGradually
        case .fitness:
            return .levelUpGradually
        case .finance:
            return .finishTotal
        case .custom:
            return .finishTotal
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // MARK: - Core Inputs (من التصميم)
    // ═══════════════════════════════════════════════════════════
    
    func getCoreInputs(for shape: GoalShape) -> [String] {
        switch shape {
        case .finishTotal:
            return [
                "Goal title",
                "Target total number",
                "Unit type (pages / words / SAR / workouts / freq / custom)",
                "Deadline (date) (optional but recommended)",
                "Days per week available (optional)",
                "Daily effort preference (Easy / Balanced / Ambitious) (optional)"
            ]
            
        case .repeatOnSchedule:
            return [
                "Goal title",
                "Frequency (days per week 1-7)",
                "Preferred time window (morning / afternoon / evening / anytime)",
                "Minimum version (2 days / mar 10 min OR 1/2/3 /3 version you can always do)"
            ]
            
        case .buildStreak:
            return [
                "Goal title",
                "Streak target (7 /14 /21 /30 / custom)",
                "Time window (anytime OR before X pm)",
                "Minimum version (tiny version you can always do)"
            ]
            
        case .levelUpGradually:
            return [
                "Goal title",
                "Activity type (reading / running / workout / coding / custom)",
                "Starting level (Very beginner / Beginner / Comfortable OR custom value)",
                "Target level (minutes / pages / reps / distance / custom)",
                "Days per week",
                "Step-up pace (weekly increase / every 2 weeks /custom)"
            ]
            
        case .finishByMilestones:
            return [
                "Goal title",
                "Milestone list (auto-generated + editable)",
                "Deadline (date) (optional)",
                "Output type name (items / chapters / slides / custom)"
            ]
            
        case .reduceSomething:
            return [
                "Goal title",
                "Metric type (screen time / spending / cigarettes / sugar / custom)",
                "Baseline Number (current level)",
                "Tracking mode (Reduce by X or Stay under X)",
                "Target final level or cap",
                "Deadline or duration (2 weeks / 30 days / custom)"
            ]
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // MARK: - Nice-to-have (من التصميم)
    // ═══════════════════════════════════════════════════════════
    
    func getNiceToHave(for shape: GoalShape) -> [String] {
        switch shape {
        case .finishTotal:
            return [
                "Starting amount (default 0)",
                "Reminder time (optional)"
            ]
            
        case .repeatOnSchedule:
            return [
                "\"Make-up allowed\" (Yes/No)",
                "Specific days (Mon...)"
            ]
            
        case .buildStreak:
            return [
                "Allowed breaks (0-2) \"pause days\"",
                "Restart rule (auto-reset vs. keep best streak)"
            ]
            
        case .levelUpGradually:
            return [
                "Max cap per day (optional)",
                "Recovery week toggle (Yes/No)"
            ]
            
        case .finishByMilestones:
            return [
                "\"Share with friend\" (goal id) (if you want the social feature)",
                "Trigger notes (optional: \"when bored\" etc.)"
            ]
            
        case .reduceSomething:
            return [
                "Allowed exceptions (e.g., 1 cheat day / week)",
                "Trigger notes (optional: \"when bored\" etc.)"
            ]
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // MARK: - Examples
    // ═══════════════════════════════════════════════════════════
    
    func getExamples(for shape: GoalShape) -> [String] {
        switch shape {
        case .finishTotal:
            return [
                "Read 500 pages",
                "Save 10,000 SAR",
                "Complete 100 workouts",
                "Write 50,000 words"
            ]
            
        case .repeatOnSchedule:
            return [
                "Meditate 5 days/week",
                "Gym 3x/week",
                "Study every weekday",
                "Journal 7 days/week"
            ]
            
        case .buildStreak:
            return [
                "30-day journaling streak",
                "21-day workout streak",
                "7-day reading streak",
                "14-day meditation streak"
            ]
            
        case .levelUpGradually:
            return [
                "Run 5K → 10K",
                "Read 10 pages → 50 pages/day",
                "Code 30 min → 2 hours/day",
                "Workout 20 min → 1 hour"
            ]
            
        case .finishByMilestones:
            return [
                "Complete project in 5 phases",
                "Finish book in 10 chapters",
                "Launch product in 4 stages",
                "Complete course in modules"
            ]
            
        case .reduceSomething:
            return [
                "Reduce screen time to 2h/day",
                "Cut spending by 30%",
                "Reduce sugar to 25g/day",
                "Lower cigarettes from 10 to 0"
            ]
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // MARK: - Icons
    // ═══════════════════════════════════════════════════════════
    
    func getIcon(for shape: GoalShape) -> String {
        switch shape {
        case .finishTotal: return "target"
        case .repeatOnSchedule: return "calendar.circle"
        case .buildStreak: return "flame"
        case .levelUpGradually: return "chart.line.uptrend.xyaxis"
        case .finishByMilestones: return "flag.checkered"
        case .reduceSomething: return "arrow.down.circle"
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // MARK: - Descriptions
    // ═══════════════════════════════════════════════════════════
    
    func getShortDescription(for shape: GoalShape) -> String {
        switch shape {
        case .finishTotal:
            return "Complete a cumulative target"
        case .repeatOnSchedule:
            return "Do something consistently"
        case .buildStreak:
            return "Build consecutive days streak"
        case .levelUpGradually:
            return "Gradually increase over time"
        case .finishByMilestones:
            return "Complete in stages"
        case .reduceSomething:
            return "Decrease over time"
        }
    }
    
    func getDetailedDescription(for shape: GoalShape) -> String {
        switch shape {
        case .finishTotal:
            return "Set a total number to reach (e.g., read 500 pages, save 10,000 SAR). Track cumulative progress toward your target."
            
        case .repeatOnSchedule:
            return "Commit to doing something on specific days each week. Perfect for building consistency in your routine."
            
        case .buildStreak:
            return "Do something every single day to build momentum. Track your longest streak and stay motivated."
            
        case .levelUpGradually:
            return "Start small and gradually increase difficulty over time. Perfect for fitness, learning, or skill development."
            
        case .finishByMilestones:
            return "Break a big project into smaller milestones. Complete them one by one to reach your goal."
            
        case .reduceSomething:
            return "Gradually decrease a habit or behavior. Set a baseline and work toward reducing it over time."
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // MARK: - Validation
    // ═══════════════════════════════════════════════════════════
    
    func validateShapeSelection() -> Bool {
        return selectedShape != nil
    }
    
    func getValidationMessage() -> String? {
        if selectedShape == nil {
            return "⚠️ Please select a goal shape to continue"
        }
        return nil
    }
}
