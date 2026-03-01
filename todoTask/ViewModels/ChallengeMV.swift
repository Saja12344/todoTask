//
//  ChallengeViewModel.swift
//  todoTask
//
//  Created by saja khalid on 20/08/1447 AH.
//


//
//  ChallengeViewModel.swift
//  toDotask
//
//  Created by saja khalid on 19/08/1447 AH.
//

import Foundation
import CloudKit
import Combine

class ChallengeViewModel: ObservableObject {
    
    @Published var myChallenges: [Challenge] = []
    @Published var incomingChallenges: [Challenge] = []
    
    private let container = CKContainer.default()
    private lazy var publicDB = container.publicCloudDatabase
    
    // في ChallengeViewModel.swift - استبدلي createChallenge بهذا:

    func createChallenge(
        challengerID: String,
        opponentID: String,
        planetStake: Planet,
        goalTitle: String,
        goalCategory: GoalCategory,
        goalType: GoalType,
        goalShape: GoalShape?,
        subTasksConfig: [SubTaskConfig] = []
    ) async throws {

        guard planetStake.state == .completed else {
            throw NSError(domain: "ChallengeError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Planet must be completed"])
        }

        let now = Date()
        let deadline = Calendar.current.date(byAdding: .day, value: 3, to: now)!

        let record = CKRecord(recordType: "Challenge")
        record["challengerID"] = challengerID as CKRecordValue
        record["opponentID"]   = opponentID as CKRecordValue
        record["state"]        = ChallengeState.pendingAcceptance.rawValue as CKRecordValue
        record["planetStakeID"]    = planetStake.recordID as CKRecordValue
        record["planetStakeState"] = planetStake.state.rawValue as CKRecordValue
        record["createdAt"]    = now as CKRecordValue
        record["editDeadline"] = deadline as CKRecordValue

        // ── Save مع timeout 10 ثواني ──────────────────────
        let saved = try await withThrowingTaskGroup(of: CKRecord.self) { group in
            group.addTask {
                try await self.publicDB.save(record)
            }
            group.addTask {
                try await Task.sleep(nanoseconds: 10_000_000_000) // 10 ثواني
                throw NSError(domain: "ChallengeError", code: 408, userInfo: [NSLocalizedDescriptionKey: "CloudKit timeout"])
            }
            let result = try await group.next()!
            group.cancelAll()
            return result
        }

        let subTasks: [SubTask] = subTasksConfig.enumerated().map { index, config in
            SubTask(
                id: UUID().uuidString,
                title: config.title,
                description: config.description,
                order: index,
                isCompleted: false,
                isLocked: false,
                dependsOn: config.dependsOn,
                completedAt: nil
            )
        }

        let challengeContext = ChallengeContext(
            challengeID: saved.recordID.recordName,
            challengerID: challengerID,
            opponentID: opponentID,
            planetStakeID: planetStake.recordID,
            state: .pendingAcceptance
        )

        _ = Goal(
            id: UUID().uuidString,
            userID: challengerID,
            title: goalTitle,
            category: goalCategory,
            goalType: goalType,
            shape: goalShape,
            startDate: now,
            endDate: nil,
            subTasks: subTasks,
            challengeContext: challengeContext,
            state: .active,
            planetState: planetStake.state,
            planetDesign: planetStake.design,
            createdAt: now,
            updatedAt: nil,
            completedAt: nil
        )

        await MainActor.run {
            myChallenges.append(
                Challenge(
                    recordID: saved.recordID.recordName,
                    challengerID: challengerID,
                    opponentID: opponentID,
                    state: .pendingAcceptance,
                    planetStakeID: planetStake.recordID,
                    createdAt: now,
                    editDeadline: deadline
                )
            )
        }
    }
     
    
    // MARK: - Fetch My Challenges
    func fetchMyChallenges(for userID: String) async throws {
        let predicate = NSPredicate(format: "challengerID == %@", userID)
        let query = CKQuery(recordType: "Challenge", predicate: predicate)
        
        let results = try await publicDB.records(matching: query)
        let challenges: [Challenge] = results.matchResults.compactMap { _, result in
            guard let record = try? result.get() else { return nil }
            return parseChallenge(from: record)
        }
        
        await MainActor.run {
            self.myChallenges = challenges
        }
    }
    
    // MARK: - Fetch Incoming Challenges
    func fetchIncomingChallenges(for userID: String) async throws {
        let predicate = NSPredicate(format: "opponentID == %@ AND state == %@", userID, ChallengeState.pendingAcceptance.rawValue)
        let query = CKQuery(recordType: "Challenge", predicate: predicate)
        
        let results = try await publicDB.records(matching: query)
        let challenges: [Challenge] = results.matchResults.compactMap { _, result in
            guard let record = try? result.get() else { return nil }
            return parseChallenge(from: record)
        }
        
        await MainActor.run {
            self.incomingChallenges = challenges
        }
    }
    
    // MARK: - Accept Challenge
    func acceptChallenge(_ challenge: Challenge) async throws {
        guard let recordName = challenge.recordID else { return }
        let recordID = CKRecord.ID(recordName: recordName)
        let record = try await publicDB.record(for: recordID)
        record["state"] = ChallengeState.active.rawValue as CKRecordValue
        _ = try await publicDB.save(record)
        
        await MainActor.run {
            incomingChallenges.removeAll { $0.recordID == challenge.recordID }
        }
    }
    
    // MARK: - Reject Challenge
    func rejectChallenge(_ challenge: Challenge) async throws {
        guard let recordName = challenge.recordID else { return }
        let recordID = CKRecord.ID(recordName: recordName)
        let record = try await publicDB.record(for: recordID)
        record["state"] = ChallengeState.rejected.rawValue as CKRecordValue
        _ = try await publicDB.save(record)
        
        await MainActor.run {
            incomingChallenges.removeAll { $0.recordID == challenge.recordID }
        }
    }
    
    // MARK: - Helper
    private func parseChallenge(from record: CKRecord) -> Challenge {
        Challenge(
            recordID: record.recordID.recordName,
            challengerID: record["challengerID"] as? String ?? "",
            opponentID: record["opponentID"] as? String ?? "",
            state: ChallengeState(rawValue: record["state"] as? String ?? "") ?? .draft,
            planetStakeID: record["planetStakeID"] as? String,
            opponentPlanetID: record["opponentPlanetID"] as? String,
            goalContext: nil, // لاحقاً ممكن تضيف fetch للـ Goal المرتبط
            createdAt: record["createdAt"] as? Date ?? Date(),
            editDeadline: record["editDeadline"] as? Date ?? Date()
        )
    }
}
