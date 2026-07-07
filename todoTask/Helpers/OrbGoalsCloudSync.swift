//
//  OrbGoalsCloudSync.swift
//  todoTask
//

import Foundation
import FirebaseFirestore

/// Syncs a user's orb library to Firestore so goals survive logout and new devices.
@MainActor
final class OrbGoalsCloudSync {
    static let shared = OrbGoalsCloudSync()

    private let db = Firestore.firestore()

    private struct Payload: Codable {
        var goals: [OrbGoal]
        var updatedAt: Date
    }

    static func isSyncable(_ userId: String) -> Bool {
        !userId.isEmpty
            && userId != "logged_out"
            && !userId.hasPrefix("guest")
            && userId != "orin-demo-review"
    }

    func save(userId: String, goals: [OrbGoal]) async {
        guard Self.isSyncable(userId) else { return }
        let ref = db.collection("users").document(userId).collection("library").document("orbs")
        let payload = Payload(goals: goals, updatedAt: Date())
        do {
            try ref.setData(from: payload, merge: true)
        } catch {
            print("❌ Cloud save orbs failed:", error.localizedDescription)
        }
    }

    func load(userId: String) async -> [OrbGoal]? {
        guard Self.isSyncable(userId) else { return nil }
        let ref = db.collection("users").document(userId).collection("library").document("orbs")
        do {
            let snap = try await ref.getDocument()
            guard snap.exists else { return nil }
            return try snap.data(as: Payload.self).goals
        } catch {
            print("❌ Cloud load orbs failed:", error.localizedDescription)
            return nil
        }
    }

    func delete(userId: String) async {
        guard Self.isSyncable(userId) else { return }
        let ref = db.collection("users").document(userId).collection("library").document("orbs")
        try? await ref.delete()
    }
}
