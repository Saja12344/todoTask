//
//  FriendRequestError.swift
//  todoTask
//

import Foundation
import CloudKit
import Combine
import SwiftUI

enum FriendRequestError: Error {
    case userNotFound
    case requestAlreadySent
    case requestNotFound
    case cloudKitError(Error)
}

class FriendRequestViewModel: ObservableObject {

    @Published var allUsers: [User] = []
    @Published var receivedRequests: [FriendRequest] = []
    @Published var pendingRequests: [FriendRequest] = []
    @Published var UserClou: [FriendRequest] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var currentUser: User?
    @Published var searchText: String = ""
    @Published var friends: [User] = []

    // MARK: - Init with Test Data
    init() {
        loadTestData()
    }

    func loadTestData() {
        currentUser = User(id: "user_001", username: "Saja", email: "", authMode: .registered)

        allUsers = [
            User(id: "user_002", username: "Ahmed", email: "", authMode: .registered),
            User(id: "user_003", username: "Lina", email: "", authMode: .registered),
            User(id: "user_004", username: "Omar", email: "", authMode: .registered)
        ]

        receivedRequests = [
            FriendRequest(recordID: "req_001", from: "user_002", to: "user_001", status: .pending),
            FriendRequest(recordID: "req_002", from: "user_003", to: "user_001", status: .pending)
        ]

        pendingRequests = [
            FriendRequest(recordID: "req_003", from: "user_001", to: "user_004", status: .pending)
        ]
    }

//    private let container = CKContainer.default()
    private lazy var publicDB = container.publicCloudDatabase

    var filteredFriends: [User] {
        if searchText.isEmpty { return friends }
        return friends.filter { $0.username.lowercased().contains(searchText.lowercased()) }
    }

    // MARK: - Accept Request (dummy data)
    func acceptRequest(_ request: FriendRequest) async throws {
        await MainActor.run {
            receivedRequests.removeAll { $0.id == request.id }
            if let user = allUsers.first(where: { $0.id == request.from }) {
                friends.append(user)
            }
        }
    }

    // MARK: - Reject Request
    func rejectRequest(_ request: FriendRequest) async throws {
        await MainActor.run {
            receivedRequests.removeAll { $0.id == request.id }
        }
    }

    // MARK: - Cancel Sent Request
    func cancelSentRequest(_ request: FriendRequest) async throws {
        guard let recordName = request.recordID else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let recordID = CKRecord.ID(recordName: recordName)
            try await publicDB.deleteRecord(withID: recordID)
            await MainActor.run {
                pendingRequests.removeAll { $0.recordID == request.recordID }
            }
        } catch {
            await MainActor.run {
                pendingRequests.removeAll { $0.recordID == request.recordID }
            }
        }
    }

    // MARK: - Remove Friend
    func removeFriend(myUserID: String, friendID: String) async throws {
        await MainActor.run {
            friends.removeAll { $0.id == myUserID }
        }
    }

    // MARK: - Send Friend Request
    func sendFriendRequest(to targetUserID: String, from currentUserID: String) async throws {
        isLoading = true
        defer { isLoading = false }

        do {
            let targetRecordID = CKRecord.ID(recordName: targetUserID)
            _ = try await publicDB.record(for: targetRecordID)

            let checkPredicate = NSPredicate(format: "from == %@ AND to == %@ AND status == %@", currentUserID, targetUserID, "pending")
            let checkQuery = CKQuery(recordType: "FriendRequest", predicate: checkPredicate)
            let existingRequests = try await publicDB.records(matching: checkQuery)
            if !existingRequests.matchResults.isEmpty {
                await MainActor.run { errorMessage = "Friend request already sent" }
                return
            }

            let record = CKRecord(recordType: "FriendRequest")
            record["from"] = currentUserID as CKRecordValue
            record["to"] = targetUserID as CKRecordValue
            record["status"] = FriendRequestStatus.pending.rawValue as CKRecordValue
            record["createdAt"] = Date() as CKRecordValue

            let saved = try await publicDB.save(record)

            let request = FriendRequest(
                recordID: saved.recordID.recordName,
                from: currentUserID,
                to: targetUserID,
                status: .pending
            )

            await MainActor.run {
                pendingRequests.append(request)
                errorMessage = nil
            }
        } catch {
            await MainActor.run { errorMessage = "Failed to send request: \(error.localizedDescription)" }
            throw error
        }
    }

    // MARK: - Fetch Sent Requests
    func fetchSentRequests(for userID: String) async throws {
        isLoading = true
        defer { isLoading = false }

        let predicate = NSPredicate(format: "from == %@ AND status == %@", userID, "pending")
        let query = CKQuery(recordType: "FriendRequest", predicate: predicate)

        do {
            let results = try await publicDB.records(matching: query)
            let requests: [FriendRequest] = results.matchResults.compactMap { _, result in
                guard let record = try? result.get() else { return nil }
                return FriendRequest(
                    recordID: record.recordID.recordName,
                    from: record["from"] as? String ?? "",
                    to: record["to"] as? String ?? "",
                    status: FriendRequestStatus(rawValue: record["status"] as? String ?? "") ?? .pending
                )
            }
            await MainActor.run { pendingRequests = requests }
        } catch {
            await MainActor.run { errorMessage = "Failed to fetch sent requests: \(error.localizedDescription)" }
            throw error
        }
    }

    // MARK: - Fetch Received Requests
    func fetchReceivedRequests(for userID: String) async throws {
        isLoading = true
        defer { isLoading = false }

        let predicate = NSPredicate(format: "to == %@ AND status == %@", userID, "pending")
        let query = CKQuery(recordType: "FriendRequest", predicate: predicate)

        do {
            let results = try await publicDB.records(matching: query)
            let requests: [FriendRequest] = results.matchResults.compactMap { _, result in
                guard let record = try? result.get() else { return nil }
                return FriendRequest(
                    recordID: record.recordID.recordName,
                    from: record["from"] as? String ?? "",
                    to: record["to"] as? String ?? "",
                    status: FriendRequestStatus(rawValue: record["status"] as? String ?? "") ?? .pending
                )
            }
            await MainActor.run { receivedRequests = requests }
        } catch {
            await MainActor.run { errorMessage = "Error: \(error.localizedDescription)" }
            throw error
        }
    }

    // MARK: - Search Users
    func searchUsers(by username: String, currentUserID: String) async throws -> [User] {
        isLoading = true
        defer { isLoading = false }

        let predicate = NSPredicate(format: "username CONTAINS[c] %@", username)
        let query = CKQuery(recordType: "User", predicate: predicate)

        do {
            let results = try await publicDB.records(matching: query)
            return results.matchResults.compactMap { _, result in
                guard let record = try? result.get(),
                      record.recordID.recordName != currentUserID else { return nil }
                return User(
                    id: record.recordID.recordName,
                    username: record["username"] as? String ?? "",
                    email: record["email"] as? String ?? "",
                    authMode: .registered,
                    friends: record["friends"] as? [String] ?? [],
                    ownedPlanets: record["ownedPlanets"] as? [String] ?? []
                )
            }
        } catch {
            await MainActor.run { errorMessage = "Search failed: \(error.localizedDescription)" }
            throw error
        }
    }

    // MARK: - Fetch Friends
    func fetchFriends(for userID: String) async throws -> [User] {
        isLoading = true
        defer { isLoading = false }

        let userRecord = try await publicDB.record(for: CKRecord.ID(recordName: userID))
        let friendIDs = userRecord["friends"] as? [String] ?? []

        var fetchedFriends: [User] = []

        try await withThrowingTaskGroup(of: User?.self) { group in
            for id in friendIDs {
                group.addTask {
                    do {
                        let record = try await self.publicDB.record(for: CKRecord.ID(recordName: id))
                        return User(
                            id: record.recordID.recordName,
                            username: record["username"] as? String ?? "",
                            email: record["email"] as? String ?? "",
                            authMode: .registered,
                            friends: record["friends"] as? [String] ?? [],
                            ownedPlanets: record["ownedPlanets"] as? [String] ?? []
                        )
                    } catch {
                        return nil
                    }
                }
            }
            for try await user in group {
                if let u = user { fetchedFriends.append(u) }
            }
        }

        return fetchedFriends
    }

    // MARK: - Create Dummy User
    func createDummyUser(username: String) async -> String? {
        do {
            let uniqueID = UUID().uuidString
            let recordID = CKRecord.ID(recordName: uniqueID)
            let record = CKRecord(recordType: "User", recordID: recordID)
            record["username"] = username as CKRecordValue
            record["createdAt"] = Date() as CKRecordValue
            let saved = try await publicDB.save(record)
            return saved.recordID.recordName
        } catch {
            await MainActor.run { errorMessage = "Error: \(error.localizedDescription)" }
            return nil
        }
    }

    // MARK: - Add Friend Connection
    private func addFriendConnection(userID1: String, userID2: String) async throws {
        async let record1 = publicDB.record(for: CKRecord.ID(recordName: userID1))
        async let record2 = publicDB.record(for: CKRecord.ID(recordName: userID2))

        let (r1, r2) = try await (record1, record2)

        var friends1 = r1["friends"] as? [String] ?? []
        if !friends1.contains(userID2) { friends1.append(userID2) }
        r1["friends"] = friends1 as CKRecordValue

        var friends2 = r2["friends"] as? [String] ?? []
        if !friends2.contains(userID1) { friends2.append(userID1) }
        r2["friends"] = friends2 as CKRecordValue

        _ = try await publicDB.modifyRecords(saving: [r1, r2], deleting: [])
    }

    func searchUsersDum(by username: String, currentUserID: String) async -> [User] {
        return friends.filter { $0.username.lowercased().contains(username.lowercased()) && $0.id != currentUserID }
    }
}
