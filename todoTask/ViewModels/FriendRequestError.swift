//
//  FriendRequestError.swift
//  todoTask
//
//  Created by saja khalid on 20/08/1447 AH.
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

//    @Published var sentRequests: [FriendRequest] = []
    @Published var allUsers: [User] = []
    @Published var receivedRequests: [FriendRequest] = []
    @Published var pendingRequests: [FriendRequest] = []
    @Published var UserClou: [FriendRequest] = []

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var currentUser: User?
    @Published var searchText: String = ""
    @Published var friends: [User] = []



    init() {
        loadDummyData()
    }

    func loadDummyData() {
        // المستخدم الحالي
        currentUser = User(id: "user_001", username: "Saja", email: "saja@test.com", authMode: .registered, friends: [], ownedPlanets: [])
        
        allUsers = [
             User(id: "user_002", username: "Ahmed", email: "ahmed@test.com", authMode: .registered),
             User(id: "user_003", username: "Lina", email: "lina@test.com", authMode: .registered),
             User(id: "user_004", username: "Omar", email: "omar@test.com", authMode: .registered),
             User(id: "user_005", username: "Mona", email: "mona@test.com", authMode: .registered)
         ]

        friends = [
        ]
        
        // طلبات صديق مستلمة (تم قبولها)
        receivedRequests = [
            FriendRequest(recordID: "req_001", from: "user_002", to: "user_001", status: .accepted),
            FriendRequest(recordID: "req_002", from: "user_003", to: "user_001", status: .accepted)
        ]

        // طلبات صديق معلقة (pending)
        pendingRequests = [
            FriendRequest(recordID: "req_003", from: "user_001", to: "user_005", status: .pending),
            
            FriendRequest(recordID: "req_004",
             from: "user_001", to: "user_003", status: .pending),
      
        ]
    
    }

    // البحث فقط يبحث في الـ friends للعرض التجريبي
    func searchUsersDum(by username: String, currentUserID: String) async -> [User] {
        return friends.filter { $0.username.lowercased().contains(username.lowercased()) && $0.id != currentUserID }
    }


    private let container = CKContainer.default()
    private lazy var publicDB = container.publicCloudDatabase
    
    var filteredFriends: [User] {
        if searchText.isEmpty { return friends }
        return friends.filter { $0.username.lowercased().contains(searchText.lowercased()) }
    }
    // MARK: - Send Friend Request
    func sendFriendRequest(to targetUserID: String, from currentUserID: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        

        do {
            // تحقق من وجود المستخدم المستهدف
            let targetRecordID = CKRecord.ID(recordName: targetUserID)
            _ = try await publicDB.record(for: targetRecordID)

            // تحقق من عدم وجود طلب مكرر
            let checkPredicate = NSPredicate(format: "from == %@ AND to == %@ AND status == %@", currentUserID, targetUserID, "pending")
            let checkQuery = CKQuery(recordType: "FriendRequest", predicate: checkPredicate)
            let existingRequests = try await publicDB.records(matching: checkQuery)
            if !existingRequests.matchResults.isEmpty {
                await MainActor.run { errorMessage = "Friend request already sent" }
                return
            }

            // إنشاء الطلب
            let record = CKRecord(recordType: "FriendRequest")
            record["from"] = currentUserID as CKRecordValue
            record["to"] = targetUserID as CKRecordValue
            record["status"] = FriendRequestStatus.pending.rawValue as CKRecordValue
            record["createdAt"] = Date() as CKRecordValue

            let saved = try await publicDB.save(record)

            let request = FriendRequest(
                recordID: saved.recordID.recordName,
//                username: currentUserID,
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

    // MARK: - Accept Request use with cloudKit not dummy data
    
    
    
//    func acceptRequest(_ request: FriendRequest)
//
//    async throws {
//        guard let recordName = request.recordID else { return }
//
//        isLoading = true
//        defer { isLoading = false }
//
//        do {
//            let recordID = CKRecord.ID(recordName: recordName)
//            let record = try await publicDB.record(for: recordID)
//
//            guard let toUserID = record["to"] as? String,
//                  toUserID == currentUser?.id else {
//                throw FriendRequestError.requestNotFound
//            }
//
//            record["status"] = FriendRequestStatus.accepted.rawValue as CKRecordValue
//            record["respondedAt"] = Date() as CKRecordValue
//            _ = try await publicDB.save(record)
//
//            // تحديث القوائم بالتوازي
//            try await addFriendConnection(userID1: request.from, userID2: request.to)
//
//
//                    await MainActor.run {
//                        receivedRequests.removeAll { $0.id == request.id }
//
//                        if let user = allUsers.first(where: { $0.id == request.from }) {
//                            friends.append(user)
//                        }
//
//            }
//
//        } catch {
//            await MainActor.run { errorMessage = "Failed to accept request: \(error.localizedDescription)" }
//            throw error
//        }
//    }
    
    // MARK: - Accept Request use dummy data
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
        guard let recordName = request.recordID else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let recordID = CKRecord.ID(recordName: recordName)
            let record = try await publicDB.record(for: recordID)
            record["status"] = FriendRequestStatus.rejected.rawValue as CKRecordValue
            record["respondedAt"] = Date() as CKRecordValue
            _ = try await publicDB.save(record)

            await MainActor.run {
                receivedRequests.removeAll { $0.recordID == request.recordID }
            }
        } catch {
            await MainActor.run { errorMessage = "Failed to reject request: \(error.localizedDescription)" }
            throw error
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
            await MainActor.run { errorMessage = "Failed to cancel request: \(error.localizedDescription)" }
            throw error
        }
    }

    // MARK: - Add Friend Connection (Parallel)
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

    // MARK: - Search Users (exclude current)
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

    // MARK: - Fetch Friends (Parallel)
    func fetchFriends(for userID: String) async throws -> [User] {
        isLoading = true
        defer { isLoading = false }

        let userRecord = try await publicDB.record(for: CKRecord.ID(recordName: userID))
        let friendIDs = userRecord["friends"] as? [String] ?? []

        var friends: [User] = []

        // استخدام TaskGroup لجلب السجلات بالتوازي
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
                        print("Failed to fetch friend \(id):", error)
                        return nil
                    }
                }
            }

            for try await user in group {
                if let u = user { friends.append(u) }
            }
        }

        return friends
    }
    


    // MARK: - Remove Friend
    func removeFriend(myUserID: String, friendID: String) async throws {
        isLoading = true
        defer { isLoading = false }

        do {
            let myRecord = try await publicDB.record(for: CKRecord.ID(recordName: myUserID))
            var myFriends = myRecord["friends"] as? [String] ?? []
            myFriends.removeAll { $0 == friendID }
            myRecord["friends"] = myFriends as CKRecordValue
            _ = try await publicDB.save(myRecord)

            let theirRecord = try await publicDB.record(for: CKRecord.ID(recordName: friendID))
            var theirFriends = theirRecord["friends"] as? [String] ?? []
            theirFriends.removeAll { $0 == myUserID }
            theirRecord["friends"] = theirFriends as CKRecordValue
            _ = try await publicDB.save(theirRecord)
        } catch {
            await MainActor.run { errorMessage = "Failed to remove friend: \(error.localizedDescription)" }
            throw error
        }
    }

    // MARK: - Create Dummy User
    func createDummyUser(username: String) async -> String? {
        do {
            let uniqueID = UUID().uuidString
            let recordID = CKRecord.ID(recordName: uniqueID)
            let record = CKRecord(recordType: "User", recordID: recordID)
            record["username"] = username as CKRecordValue
            record["createdAt"] = Date() as CKRecordValue
            // لا تدخل القوائم الفارغة
            let saved = try await publicDB.save(record)
            print("✅ Dummy User created:", saved.recordID.recordName)
            return saved.recordID.recordName
        } catch {
            print("❌ Error creating dummy user:", error)
            await MainActor.run { errorMessage = "Error: \(error.localizedDescription)" }
            return nil
        }
    }
}
