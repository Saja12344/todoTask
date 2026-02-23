//
//  OrbGoalStore.swift
//  todoTask
//
//  استبدل الملف الموجود بهذا كاملاً
//

import SwiftUI
import Combine

final class OrbGoalStore: ObservableObject {
    @Published private(set) var goals: [OrbGoal] = []

    private let persistence = OrbGoalPersistence()

    init() { load() }

    // MARK: - Load / Save
    func load() { goals = persistence.load() }
    private func save() { persistence.save(goals) }

    // MARK: - Add Goal
    func add(_ goal: OrbGoal) {
        goals.append(goal)
        save()
    }

    // MARK: - Delete Goal
    func delete(goalID: UUID) {
        goals.removeAll { $0.id == goalID }
        save()
    }

    // MARK: - Lookup
    func goal(with id: UUID) -> OrbGoal? {
        goals.first { $0.id == id }
    }

    // MARK: - Task CRUD
    func addTask(goalID: UUID, title: String, scheduledDate: Date? = nil) {
        guard let i = goals.firstIndex(where: { $0.id == goalID }) else { return }
        goals[i].tasks.append(GoalTask(title: title, scheduledDate: scheduledDate))
        save()
    }

    func deleteTask(goalID: UUID, taskID: UUID) {
        guard let i = goals.firstIndex(where: { $0.id == goalID }) else { return }
        goals[i].tasks.removeAll { $0.id == taskID }
        save()
    }

    func toggleTask(goalID: UUID, taskID: UUID) {
        guard let i = goals.firstIndex(where: { $0.id == goalID }) else { return }
        guard let j = goals[i].tasks.firstIndex(where: { $0.id == taskID }) else { return }
        goals[i].tasks[j].isDone.toggle()
        save()
    }

    func replaceTasks(goalID: UUID, tasks: [GoalTask]) {
        guard let i = goals.firstIndex(where: { $0.id == goalID }) else { return }
        goals[i].tasks = tasks
        save()
    }

    // MARK: - Generate Tasks from Settings + Energy
    /// يُستدعى بعد إنشاء الـ Goal لتعبئة المهام
    func generateTasks(goalID: UUID, energyFactor: Double = 0.7) {
        guard let i = goals.firstIndex(where: { $0.id == goalID }),
              let settings = goals[i].settings else { return }
        let generated = TaskGenerator.generate(
            from: settings,
            goalTitle: goals[i].title,
            energyFactor: energyFactor
        )
        goals[i].tasks = generated
        save()
    }

    // MARK: - Today's Tasks (للهوم)
    /// جميع المهام المجدولة لليوم من كل الأهداف
    func todayTasks(for date: Date = Date()) -> [(goal: OrbGoal, task: GoalTask)] {
        var result: [(OrbGoal, GoalTask)] = []
        for goal in goals {
            for task in goal.tasks(for: date) {
                result.append((goal, task))
            }
        }
        return result
    }

    // MARK: - Toggle Today Task
    func toggleTodayTask(goalID: UUID, taskID: UUID) {
        toggleTask(goalID: goalID, taskID: taskID)
    }

    // MARK: - Legacy
    func clearAll() {
        goals.removeAll()
        save()
    }

    func updateProgress(goalID: UUID, done: Int, total: Int) {
        // kept for backward compat — no longer needed since progress is computed
    }
}
