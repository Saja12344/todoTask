
//
//  OrbGoalPersistence.swift.swift
//  todoTask
//
//  Created by Ruba Alghamdi on 27/08/1447 AH.
//

import Foundation

struct OrbGoalPersistence {
    private let key = "orb_goals_v1"

    func save(_ goals: [OrbGoal]) {
        do {
            let data = try JSONEncoder().encode(goals)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("❌ Save goals failed:", error)
        }
    }

    func load() -> [OrbGoal] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [OrbGoal.mock] } // start with 1 mock if empty
        do {
            return try JSONDecoder().decode([OrbGoal].self, from: data)
        } catch {
            print("❌ Load goals failed:", error)
            return [OrbGoal.mock]
        }
    }
}
