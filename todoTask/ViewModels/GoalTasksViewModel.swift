//
//  GoalTasksViewModel.swift
//  todoTask
//
//  Created by Ruba Alghamdi on 25/08/1447 AH.
//

import SwiftUI
import Observation

@Observable
final class GoalTasksViewModel {

    var goalTitle: String = "Learn Spanish By September"

    var tasks: [GoalTask] = [
        .init(title: "read 5 flash cards"),
        .init(title: "learn 3 new words")
    ]

    var newTaskText: String = ""

    var progress: Double {
        guard !tasks.isEmpty else { return 0 }
        let done = tasks.filter { $0.isDone }.count
        return Double(done) / Double(tasks.count)
    }

    func toggle(_ task: GoalTask) {
        guard let i = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[i].isDone.toggle()
    }

    func addTask() {
        let t = newTaskText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return }
        tasks.append(.init(title: t))
        newTaskText = ""
    }

    func updateTaskTitle(taskID: UUID, newTitle: String) {
        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard let idx = tasks.firstIndex(where: { $0.id == taskID }) else { return }
        tasks[idx].title = trimmed
    }

    func deleteTask(taskID: UUID) {
        tasks.removeAll { $0.id == taskID }
    }
}
