//
//  CoreGameLogicViewModel.swift
//  todoTask
//
//  Created by شهد عبدالله القحطاني on 19/08/1447 AH.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Core Game Logic ViewModel (جنى)


class CoreGameLogicViewModel: ObservableObject {
    
    @Published var currentGoalState: GoalState = .draft
    @Published var currentPlanetState: PlanetState = .hidden
    @Published var progressSnapshot: ProgressSnapshot?
    @Published var gameOutcome: GameOutcome?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    

    // MARK: - 1. Goal Lifecycle
    
    func createGoal(
        userID: String,
        goalConfig: GoalConfig,
        subTasks: [SubTaskConfig],
        challengeContext: ChallengeContext? // من SharedModels.swift
    ) -> Goal {
        
        
        let goalID = UUID().uuidString
        let dependentSubTasks = applySubTaskDependencyRules(subTasks)
        
        let goal = Goal(
            id: goalID,
            userID: userID,
            title: goalConfig.title,
            category: goalConfig.category,
            goalType: goalConfig.goalType,
            startDate: goalConfig.startDate,
            endDate: goalConfig.endDate,
            subTasks: dependentSubTasks,
            challengeContext: challengeContext,
            state: .draft,
            planetState: .hidden,
            createdAt: Date()
        )
        
        DispatchQueue.main.async {
            self.currentGoalState = .draft
            self.currentPlanetState = .hidden
        }
        
        return goal
    }
    
    
    
    
    func updateGoal(_ goal: Goal, with updates: GoalUpdates) -> Goal {
        var updatedGoal = goal
        
        if let title = updates.title {
            updatedGoal.title = title
        }
        
        if let subTasks = updates.subTasks {
            updatedGoal.subTasks = applySubTaskDependencyRules(subTasks)
        }
        
        if let state = updates.state {
            updatedGoal.state = state
            self.currentGoalState = state
        }
        
        updatedGoal.updatedAt = Date()
        return updatedGoal
    }
    
    
    
    
    
    func closeGoal(_ goal: Goal, outcome: GoalOutcome) -> Goal {
        var closedGoal = goal
        
        switch outcome {
        case .completed:
            closedGoal.state = .completed
            closedGoal.planetState = .completed
        case .failed:
            closedGoal.state = .failed
            closedGoal.planetState = .damaged
        }
        
        closedGoal.completedAt = Date()

        
        // إنشاء GameOutcome لشهد
        let gameOutcome = GameOutcome(
            goalID: goal.id,
            finalState: closedGoal.state.rawValue,
            completionDate: Date(),
            totalSubTasks: goal.subTasks.count,
            completedSubTasks: goal.subTasks.filter { $0.isCompleted }.count
        )
        
        DispatchQueue.main.async {
            self.currentGoalState = closedGoal.state
            self.currentPlanetState = closedGoal.planetState
            self.gameOutcome = gameOutcome
        }
        
        return closedGoal
    }
    
    
    
    
    // MARK: - 2. SubTask Dependency Rules
    
    func applySubTaskDependencyRules(_ subTasks: [SubTaskConfig]) -> [SubTask] {
        var processedSubTasks: [SubTask] = []
        
        for (index, config) in subTasks.enumerated() {
            let subTask = SubTask(
                id: UUID().uuidString,
                title: config.title,
                description: config.description,
                order: index,
                isCompleted: false,
                isLocked: config.dependsOn != nil,
                dependsOn: config.dependsOn,
                completedAt: nil
            )
            processedSubTasks.append(subTask)
        }
        
        if let firstTask = processedSubTasks.first(where: { $0.dependsOn == nil }) {
            if let index = processedSubTasks.firstIndex(where: { $0.id == firstTask.id }) {
                processedSubTasks[index].isLocked = false
            }
        }
        
        return processedSubTasks
    }
    
    
    func unlockNextSubTask(after completedTaskID: String, in goal: Goal) -> [SubTask] {
        var updatedSubTasks = goal.subTasks
        
        for (index, subTask) in updatedSubTasks.enumerated() {
            if subTask.dependsOn == completedTaskID {
                updatedSubTasks[index].isLocked = false
            }
        }
        
        return updatedSubTasks
    }
    
    
    
    
    // MARK: - 3. Progress Recalculation Engine
    
    func recalculateProgress(for goal: Goal) -> ProgressSnapshot {
        let totalSubTasks = goal.subTasks.count
        let completedSubTasks = goal.subTasks.filter { $0.isCompleted }.count
        
        let completionPercentage = totalSubTasks > 0 
            ? (Double(completedSubTasks) / Double(totalSubTasks)) * 100.0 
            : 0.0
        
        let isLate = checkIfLate(goal)
        
        let snapshot = ProgressSnapshot(
            goalID: goal.id,
            completedSubTasks: completedSubTasks,
            totalSubTasks: totalSubTasks,
            completionPercentage: completionPercentage,
            isLate: isLate,
            lastUpdated: Date()
        )
        
        DispatchQueue.main.async {
            self.progressSnapshot = snapshot
        }
        
        return snapshot
    }
    
    private func checkIfLate(_ goal: Goal) -> Bool {
        guard let endDate = goal.endDate else { return false }
        let now = Date()
        let isOverdue = now > endDate
        let isNotCompleted = goal.state != .completed
        return isOverdue && isNotCompleted
    }
    
    
    
    // MARK: - 4. Completion Percentage Formula
    
    func calculateCompletionPercentage(
        subTasks: [SubTask],
        withWeights weights: [String: Double]? = nil
    ) -> Double {
        
        if let weights = weights {
            var totalWeight: Double = 0
            var completedWeight: Double = 0
            
            for subTask in subTasks {
                let weight = weights[subTask.id] ?? 1.0
                totalWeight += weight
                
                if subTask.isCompleted {
                    completedWeight += weight
                }
            }
            
            return totalWeight > 0 ? (completedWeight / totalWeight) * 100.0 : 0.0
            
        } else {
            let total = subTasks.count
            let completed = subTasks.filter { $0.isCompleted }.count
            return total > 0 ? (Double(completed) / Double(total)) * 100.0 : 0.0
        }
    }
    
    
    
    
    // MARK: - 5. Category Rule Enforcement
    
    func enforceCategoryRules(_ category: GoalCategory) -> CategoryRules {
        switch category {
        case .habit:
            return CategoryRules(
                minDuration: 15,
                maxDuration: 365,
                requiresDailyCheckin: true,
                allowsSubTasks: true,
                recommendedSubTaskCount: 1...3
            )
        case .project:
            return CategoryRules(
                minDuration: 1,
                maxDuration: 180,
                requiresDailyCheckin: false,
                allowsSubTasks: true,
                recommendedSubTaskCount: 3...10
            )
        case .learning:
            return CategoryRules(
                minDuration: 7,
                maxDuration: 90,
                requiresDailyCheckin: false,
                allowsSubTasks: true,
                recommendedSubTaskCount: 5...15
            )
        case .fitness:
            return CategoryRules(
                minDuration: 7,
                maxDuration: 90,
                requiresDailyCheckin: true,
                allowsSubTasks: true,
                recommendedSubTaskCount: 1...5
            )
        case .finance:
            return CategoryRules(
                minDuration: 30,
                maxDuration: 365,
                requiresDailyCheckin: false,
                allowsSubTasks: true,
                recommendedSubTaskCount: 3...8
            )
        case .custom:
            return CategoryRules(
                minDuration: 1,
                maxDuration: 365,
                requiresDailyCheckin: false,
                allowsSubTasks: true,
                recommendedSubTaskCount: 1...20
            )
        }
    }
    
    
    
    
    // MARK: - 6. Planet State Machine
    
    func updatePlanetState(for goal: Goal) -> PlanetState {
        let progress = recalculateProgress(for: goal)
        
        let newState: PlanetState
        
        switch goal.state {
        case .draft:
            newState = .hidden
        case .active:
            if progress.completionPercentage >= 100.0 {
                newState = .completed
            } else if progress.isLate {
                newState = .damaged
            } else {
                newState = .active
            }
        case .locked:
            newState = .hidden
        case .completed:
            newState = .completed
        case .failed:
            newState = .damaged
        }
        
        DispatchQueue.main.async {
            self.currentPlanetState = newState
        }
        
        return newState
    }
    
    
    
    
    // MARK: - 7. Rocket & Reward Logic
    
    func calculateRocketReward(for goal: Goal) -> RocketReward {
        let progress = recalculateProgress(for: goal)
        
        var points = Int(progress.completionPercentage * 10)
        
        if !progress.isLate {
            points += 100
        }
        
        if progress.completionPercentage == 100.0 {
            points += 500
        }
        
        let rocketType: RocketType
        if progress.completionPercentage == 100.0 && !progress.isLate {
            rocketType = .gold
        } else if progress.completionPercentage >= 75.0 {
            rocketType = .silver
        } else {
            rocketType = .bronze
        }
        
        return RocketReward(
            points: points,
            rocketType: rocketType,
            unlockables: generateUnlockables(for: goal),
            badges: generateBadges(for: goal)
        )
    }
    
    
    
    private func generateUnlockables(for goal: Goal) -> [String] {
        var unlockables: [String] = []
        let progress = recalculateProgress(for: goal)
        
        if progress.completionPercentage >= 50.0 {
            unlockables.append("rocket_skin_blue")
        }
        
        if progress.completionPercentage == 100.0 {
            unlockables.append("planet_theme_\(goal.category.rawValue)")
        }
        
        return unlockables
    }
    
    private func generateBadges(for goal: Goal) -> [String] {
        var badges: [String] = []
        
        if goal.state == .completed {
            badges.append("goal_completed_\(goal.category.rawValue)")
        }
        
        let progress = recalculateProgress(for: goal)
        if progress.completionPercentage == 100.0 && !progress.isLate {
            badges.append("on_time_completion")
        }
        
        return badges
    }
    
    
    
    // MARK: - 8. Win / Lose Resolution
    
    func resolveGoalOutcome(_ goal: Goal) -> GoalResolution {
        let progress = recalculateProgress(for: goal)
        
        let resolution: GoalResolution
        
        if progress.completionPercentage == 100.0 {
            let reward = calculateRocketReward(for: goal)
            resolution = .win(
                message: "🎉 مبروك! أكملت هدفك بنجاح!",
                reward: reward
            )
        } else if progress.isLate && progress.completionPercentage < 50.0 {
            resolution = .lose(
                message: "😔 للأسف، لم تكمل الهدف في الوقت المحدد",
                penaltyPoints: -50
            )
        } else {
            let partialReward = calculateRocketReward(for: goal)
            resolution = .partial(
                message: "👍 إنجاز جيد! أكملت \(Int(progress.completionPercentage))%",
                reward: partialReward
            )
        }
        
        return resolution
    }
    
    // MARK: - 9. Penalty & Steal Logic
    
    func applyPenalty(to goal: Goal, type: PenaltyType) -> PenaltyResult {
        let result: PenaltyResult
        
        switch type {
        case .latePenalty:
            let pointsLost = calculateLatePenalty(for: goal)
            result = PenaltyResult(
                type: .latePenalty,
                pointsLost: pointsLost,
                message: "⚠️ خصم \(pointsLost) نقطة بسبب التأخير",
                affectedGoalID: goal.id
            )
        case .stolen(let thiefUserID):
            let stolenPoints = Int(recalculateProgress(for: goal).completionPercentage * 5)
            result = PenaltyResult(
                type: .stolen(thiefUserID: thiefUserID),
                pointsLost: stolenPoints,
                message: "🏴‍☠️ تم سرقة \(stolenPoints) نقطة من هدفك!",
                affectedGoalID: goal.id
            )
        }
        
        return result
    }
    
    
    
    
    private func calculateLatePenalty(for goal: Goal) -> Int {
        guard let endDate = goal.endDate else { return 0 }
        let now = Date()
        let daysLate = Calendar.current.dateComponents([.day], from: endDate, to: now).day ?? 0
        return min(daysLate * 10, 100)
    }
    
    // MARK: - 10. Planet Logic
    
    func managePlanetLogic(for goal: Goal) -> PlanetInfo {
        let state = updatePlanetState(for: goal)
        let progress = recalculateProgress(for: goal)
        
        return PlanetInfo(
            goalID: goal.id,
            state: state,
            visualTheme: getPlanetTheme(for: goal.category),
            progressPercentage: progress.completionPercentage,
            isVisible: state != .hidden,
            animations: getPlanetAnimations(for: state)
        )
    }
    
    private func getPlanetTheme(for category: GoalCategory) -> String {
        switch category {
        case .habit: return "green_nature"
        case .project: return "blue_tech"
        case .learning: return "purple_wisdom"
        case .fitness: return "red_energy"
        case .finance: return "gold_wealth"
        case .custom: return "rainbow_custom"
        }
    }
    
    private func getPlanetAnimations(for state: PlanetState) -> [String] {
        switch state {
        case .hidden: return []
        case .active: return ["pulse", "rotate"]
        case .completed: return ["explode_confetti", "glow"]
        case .damaged: return ["shake", "crack"]
        case .stolen: return ["fade_out", "disappear"]
        }
    }
}





// MARK: - Models (خاصة ب لوجك جنا بس)

enum GoalState: String, Codable {
    case draft, active, locked, completed, failed
}

enum PlanetState: String, Codable {
    case hidden, active, completed, damaged, stolen
}

enum GoalCategory: String, Codable {
    case habit, project, learning, fitness, finance, custom
}

struct Goal: Identifiable, Codable {
    let id: String
    let userID: String
    var title: String
    let category: GoalCategory
    let goalType: GoalType // ⬅️ من SharedModels.swift
    let startDate: Date
    let endDate: Date?
    var subTasks: [SubTask]
    let challengeContext: ChallengeContext? // ⬅️ من SharedModels.swift
    var state: GoalState
    var planetState: PlanetState
    let createdAt: Date
    var updatedAt: Date?
    var completedAt: Date?
}

struct SubTask: Identifiable, Codable {
    let id: String
    var title: String
    var description: String?
    let order: Int
    var isCompleted: Bool
    var isLocked: Bool
    var dependsOn: String?
    var completedAt: Date?
}

struct SubTaskConfig {
    let title: String
    let description: String?
    let dependsOn: String?
}

struct GoalConfig {
    let title: String
    let category: GoalCategory
    let goalType: GoalType // ⬅️ من SharedModels.swift
    let startDate: Date
    let endDate: Date?
}

struct GoalUpdates {
    let title: String?
    let subTasks: [SubTaskConfig]?
    let state: GoalState?
}

struct CategoryRules {
    let minDuration: Int
    let maxDuration: Int
    let requiresDailyCheckin: Bool
    let allowsSubTasks: Bool
    let recommendedSubTaskCount: ClosedRange<Int>
}

enum RocketType: String, Codable {
    case bronze, silver, gold
}

struct RocketReward: Codable {
    let points: Int
    let rocketType: RocketType
    let unlockables: [String]
    let badges: [String]
}

enum GoalResolution {
    case win(message: String, reward: RocketReward)
    case lose(message: String, penaltyPoints: Int)
    case partial(message: String, reward: RocketReward)
}

enum GoalOutcome {
    case completed
    case failed
}

enum PenaltyType {
    case latePenalty
    case stolen(thiefUserID: String)
}

struct PenaltyResult {
    let type: PenaltyType
    let pointsLost: Int
    let message: String
    let affectedGoalID: String
}

struct PlanetInfo {
    let goalID: String
    let state: PlanetState
    let visualTheme: String
    let progressPercentage: Double
    let isVisible: Bool
    let animations: [String]
}
