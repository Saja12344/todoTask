//
//  GoalTasksViewModel.swift
//  todoTask
//

import Foundation
import Observation

@Observable
final class GoalTasksViewModel {
    var goalTitle: String = "Learn Spanish By September"
    var maxTasks:  Int    = 30
    var tasks:     [GoalTask] = []
    var progress:  Double {
        guard !tasks.isEmpty else { return 0 }
        return Double(tasks.filter(\.isDone).count) / Double(tasks.count)
    }

    func addTask(title: String) {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard tasks.count < maxTasks else { return }
        tasks.append(GoalTask(title: title))
    }

    func deleteTask(taskID: UUID) {
        tasks.removeAll { $0.id == taskID }
    }

    func toggleTask(taskID: UUID) {
        guard let i = tasks.firstIndex(where: { $0.id == taskID }) else { return }
        tasks[i].isDone.toggle()
    }
}
