//
//  GoalTasksViewModel.swift
//  todoTask
//
//  Created by Ruba Alghamdi on 25/08/1447 AH.
//

import Foundation
import Observation

@Observable
final class GoalTasksViewModel {

    var goalTitle: String = "Learn Spanish By September"

    
    var maxTasks: Int = 30

    var tasks: [GoalTask] = [
        .init(spec: .init(action: "study", quantity: 5, unit: "flashcards")),
        .init(spec: .init(action: "learn", quantity: 3, unit: "words"))
    ]

    var progress: Double { 0.0 }

    func addTask(spec: TaskSpec) {
        let a = spec.action.trimmingCharacters(in: .whitespacesAndNewlines)
        let u = spec.unit.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !a.isEmpty else { return }
        guard !u.isEmpty else { return }
        guard spec.quantity > 0 else { return }
        guard tasks.count < maxTasks else { return }

        tasks.append(.init(spec: .init(action: a, quantity: spec.quantity, unit: u)))
    }

    func deleteTask(taskID: UUID) {
        tasks.removeAll { $0.id == taskID }
    }
}
