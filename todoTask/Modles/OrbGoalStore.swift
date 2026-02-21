//
//  OrbGoalStore.swift
//  todoTask
//
//  Created by Ruba Alghamdi on 27/08/1447 AH.
//

import SwiftUI
import Combine

final class OrbGoalStore: ObservableObject {
    @Published private(set) var goals: [OrbGoal] = []

    private let persistence = OrbGoalPersistence()

    init() {
        load()
    }

    func load() {
        goals = persistence.load()
    }

    func add(_ goal: OrbGoal) {
        goals.append(goal)
        persistence.save(goals)
    }

    func updateProgress(goalID: UUID, done: Int, total: Int) {
        guard let idx = goals.firstIndex(where: { $0.id == goalID }) else { return }
        goals[idx].doneTasks = done
        goals[idx].totalTasks = max(1, total)
        persistence.save(goals)
    }

    func clearAll() {
        goals.removeAll()
        persistence.save(goals)
    }

    // MARK: - Delete single goal
    func delete(goalID: UUID) {
        goals.removeAll { $0.id == goalID }
        persistence.save(goals)
    }

    // MARK: - Lookup
    func goal(with id: UUID) -> OrbGoal? {
        goals.first { $0.id == id }
    }
}

