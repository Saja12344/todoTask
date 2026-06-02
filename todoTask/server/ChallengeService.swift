//
//  ChallengeService.swift
//  todoTask
//
//  Created by شهد عبدالله القحطاني on 16/12/1447 AH.
//


//  ChallengeService.swift
//  todoTask

import SwiftUI
import FirebaseFirestore
import Combine

@MainActor
class ChallengeService: ObservableObject {

    private let db = Firestore.firestore()

    @Published var room: ChallengeRoom?
    @Published var tasks: [ChallengeTask] = []
    @Published var winner: ChallengeWinner?

    private var listeners: [ListenerRegistration] = []

    // ─── إنشاء غرفة + كوكب (Player 1) ─────────────────────
    func createRoom(
        userId: String,
        userName: String,
        orbDesign: OrbDesign,
        orbTasks: [OrbGoal]   // مهام اليوم من الـ store
    ) async throws -> String {

        let ref = db.collection("challenges").document()

        let gradients = orbDesign.gradientStops.map { $0.toHex() }

        let room = ChallengeRoom(
            id: ref.documentID,
            player1Id: userId,
            player1Name: userName,
            player2Id: nil,
            player2Name: nil,
            status: .waiting,
            createdAt: Date(),
            finishedAt: nil,
            winnerId: nil,
            winnerName: nil,
            planetGradient: gradients,
            planetGlow: orbDesign.glow,
            planetName: randomPlanetName(),
            planetTextureAsset: orbDesign.textureAssetName ?? "",
            planetTextureOpacity: orbDesign.textureOpacity
        )

        let batch = db.batch()
        try batch.setData(from: room, forDocument: ref)

        // حوّل مهام الـ orb لمهام تحدي
        let challengeTasks = buildTasks(from: orbTasks)
        for task in challengeTasks {
            let taskRef = ref.collection("tasks").document(task.id)
            try batch.setData(from: task, forDocument: taskRef)
        }

        try await batch.commit()
        return ref.documentID
    }

    // ─── انضمام (Player 2) ───────────────────────────────────
    func joinRoom(roomId: String, userId: String, userName: String) async throws {
        let ref = db.collection("challenges").document(roomId)
        try await ref.updateData([
            "player2Id":   userId,
            "player2Name": userName,
            "status":      ChallengeStatus.active.rawValue
        ])
    }

    // ─── الاستماع real-time ──────────────────────────────────
    func listen(roomId: String, myId: String) {
        stopListening()
        let ref = db.collection("challenges").document(roomId)

        // استمع للغرفة
        let r1 = ref.addSnapshotListener { [weak self] snap, _ in
            guard let self, let snap else { return }
            self.room = try? snap.data(as: ChallengeRoom.self)
            if let w = self.room?.winnerId, let wName = self.room?.winnerName,
               let room = self.room, self.winner == nil {
                self.winner = ChallengeWinner(
                    id: w, name: wName,
                    planetGradient: room.planetGradient,
                    planetGlow: room.planetGlow,
                    planetName: room.planetName,
                    planetTextureAsset: room.planetTextureAsset,
                    planetTextureOpacity: room.planetTextureOpacity
                )
            }
        }

        // استمع للمهام
        let r2 = ref.collection("tasks").addSnapshotListener { [weak self] snap, _ in
            guard let self, let docs = snap?.documents else { return }
            self.tasks = docs.compactMap { try? $0.data(as: ChallengeTask.self) }

            // تحقق الفوز
            if self.tasks.allSatisfy({ $0.completedBy != nil }) {
                Task { try? await self.resolveWinner(ref: ref) }
            }
        }

        listeners = [r1, r2]
    }

    // ─── إكمال مهمة ─────────────────────────────────────────
    func completeTask(roomId: String, taskId: String, userId: String) async throws {
        let ref = db.collection("challenges")
                    .document(roomId)
                    .collection("tasks")
                    .document(taskId)

        try await db.runTransaction { transaction, error in
            guard let doc = try? transaction.getDocument(ref),
                  doc.data()?["completedBy"] == nil else { return nil }
            transaction.updateData([
                "completedBy": userId,
                "completedAt": Timestamp(date: Date())
            ], forDocument: ref)
            return nil
        }
    }

    // ─── تحديد الفائز ───────────────────────────────────────
    private func resolveWinner(ref: DocumentReference) async throws {
        guard let room, room.winnerId == nil else { return }

        let scores = Dictionary(grouping: tasks) { $0.completedBy ?? "" }
            .mapValues { $0.reduce(0) { $0 + $1.points } }

        guard let winnerId = scores.max(by: { $0.value < $1.value })?.key,
              !winnerId.isEmpty else { return }

        let winnerName = winnerId == room.player1Id ? room.player1Name : (room.player2Name ?? "")

        try await ref.updateData([
            "winnerId":   winnerId,
            "winnerName": winnerName,
            "status":     ChallengeStatus.finished.rawValue,
            "finishedAt": Timestamp(date: Date())
        ])
    }

    // ─── حفظ الكوكب للفائز في Firestore ─────────────────────
    func savePlanetToWinner(winner: ChallengeWinner) async throws {
        let design = [
            "planetName":           winner.planetName,
            "planetGradient":       winner.planetGradient,
            "planetGlow":           winner.planetGlow,
            "planetTextureAsset":   winner.planetTextureAsset,
            "planetTextureOpacity": winner.planetTextureOpacity,
            "wonAt":                Timestamp(date: Date())
        ] as [String: Any]

        try await db.collection("users")
            .document(winner.id)
            .collection("wonPlanets")
            .document()
            .setData(design)
    }

    func stopListening() { listeners.forEach { $0.remove() }; listeners = [] }

    // ─── Helpers ─────────────────────────────────────────────
    func myProgress(myId: String) -> Double {
        guard !tasks.isEmpty else { return 0 }
        return Double(tasks.filter { $0.completedBy == myId }.count) / Double(tasks.count)
    }

    func opponentProgress(myId: String) -> Double {
        guard !tasks.isEmpty else { return 0 }
        let opId = tasks.first { $0.completedBy != nil && $0.completedBy != myId }?.completedBy
        return Double(tasks.filter { $0.completedBy == opId }.count) / Double(tasks.count)
    }

    private func buildTasks(from goals: [OrbGoal]) -> [ChallengeTask] {
        var result: [ChallengeTask] = []
        for goal in goals {
            for task in goal.tasks {
                result.append(ChallengeTask(
                    id: UUID().uuidString,
                    title: task.title,
                    points: task.targetAmount > 1 ? task.targetAmount * 5 : 10,
                    completedBy: nil,
                    completedAt: nil
                ))
            }
        }
        return result.isEmpty ? defaultTasks() : result
    }

    private func defaultTasks() -> [ChallengeTask] {
        let titles = ["اشرب 8 أكواب ماء","تمرين 30 دقيقة","قرأ 20 صفحة","نم 8 ساعات","تجنب السكر"]
        return titles.map {
            ChallengeTask(id: UUID().uuidString, title: $0, points: 10, completedBy: nil, completedAt: nil)
        }
    }

    private func randomPlanetName() -> String {
        ["زيفيريا","نيبتارا","كروناس","فيلاكس","أزوريا","ثيميرا"].randomElement()!
    }
}

// Helper: RGBAColor → hex string
extension RGBAColor {
    func toHex() -> String {
        String(format: "#%02X%02X%02X",
               Int(r * 255), Int(g * 255), Int(b * 255))
    }
}
