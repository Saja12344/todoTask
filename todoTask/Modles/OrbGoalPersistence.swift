//
//  OrbGoalPersistence.swift
//  todoTask
//
//  استبدل الملف الموجود بهذا كاملاً
//

import Foundation

struct OrbGoalPersistence {
    private let key = "orb_goals_v2"  // v2 للموديل الجديد

    func save(_ goals: [OrbGoal]) {
        do {
            let data = try JSONEncoder().encode(goals)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("❌ Save goals failed:", error)
        }
    }

    func load() -> [OrbGoal] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [.mock] }
        do {
            return try JSONDecoder().decode([OrbGoal].self, from: data)
        } catch {
            print("❌ Load goals failed:", error)
            return [.mock]
        }
    }
}
