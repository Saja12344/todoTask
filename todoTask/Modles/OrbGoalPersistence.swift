//
//  OrbGoalPersistence.swift
//  todoTask
//

import Foundation

struct OrbGoalPersistence {
    private static let legacyKey = "orb_goals_v2"

    private func key(for userId: String) -> String {
        "orb_goals_v3_\(userId)"
    }

    func save(_ goals: [OrbGoal], userId: String) {
        guard userId != "logged_out" else { return }
        do {
            let data = try JSONEncoder().encode(goals)
            UserDefaults.standard.set(data, forKey: key(for: userId))
        } catch {
            print("❌ Save goals failed:", error)
        }
    }

    func load(userId: String) -> [OrbGoal] {
        guard userId != "logged_out" else { return [] }
        guard let data = UserDefaults.standard.data(forKey: key(for: userId)) else { return [] }
        do {
            return try JSONDecoder().decode([OrbGoal].self, from: data)
        } catch {
            print("❌ Load goals failed:", error)
            return []
        }
    }

    func delete(userId: String) {
        UserDefaults.standard.removeObject(forKey: key(for: userId))
    }

    /// One-time migration from the old global store into the first signed-in account.
    func migrateLegacyGlobalStore(to userId: String) {
        guard load(userId: userId).isEmpty,
              let data = UserDefaults.standard.data(forKey: Self.legacyKey),
              let legacy = try? JSONDecoder().decode([OrbGoal].self, from: data),
              !legacy.isEmpty else { return }
        save(legacy, userId: userId)
        UserDefaults.standard.removeObject(forKey: Self.legacyKey)
    }
}
