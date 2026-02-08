import Foundation
import CloudKit
import Combine

// MARK: - Errors (من SocialManager)
enum FriendRequestError: Error {
    case userNotFound
    case requestAlreadySent
    case requestNotFound
    case cloudKitError(Error)
}

// MARK: - FriendRequestViewModel المحسّن
class FriendRequestViewModel: ObservableObject {
    
    // ✅ من FriendRequestViewModel - تنظيم أفضل
    @Published var sentRequests: [FriendRequest] = []
    @Published var receivedRequests: [FriendRequest] = []
    
    // ✅ من SocialManager - error handling
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let container = CKContainer.default()
    private lazy var publicDB = container.publicCloudDatabase  // ✅ Public DB
    

    // MARK: - Send Friend Request

    func sendFriendRequest(to targetUserID: String, from currentUserID: String) async throws {  // ✅ غيرنا الترتيب
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            // 1️⃣ التحقق من وجود المستخدم المستهدف
            let targetRecordID = CKRecord.ID(recordName: targetUserID)
            _ = try await publicDB.record(for: targetRecordID)
            
            // 2️⃣ التحقق من عدم وجود طلب مكرر
            let checkPredicate = NSPredicate(
                format: "from == %@ AND to == %@ AND status == %@",
                currentUserID,
                targetUserID,
                "pending"
            )
            let checkQuery = CKQuery(recordType: "FriendRequest", predicate: checkPredicate)
            let existingRequests = try await publicDB.records(matching: checkQuery)
            
            if !existingRequests.matchResults.isEmpty {
                await MainActor.run {
                    errorMessage = "Friend request already sent"
                }
                return
            }
            
            // 3️⃣ إنشاء الطلب
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
                sentRequests.append(request)
                errorMessage = nil
            }
            
            print("✅ Friend request sent successfully")
            
        } catch {
            await MainActor.run {
                errorMessage = "Failed to send request: \(error.localizedDescription)"
            }
            throw error
        }
    }
    
    // MARK: - جلب الطلبات المرسلة (مفقودة في الأصل)
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
            
            await MainActor.run {
                self.sentRequests = requests
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to fetch sent requests: \(error.localizedDescription)"
            }
            throw error
        }
    }
    
    // MARK: - جلب الطلبات المستلمة
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
            
            await MainActor.run {
                self.receivedRequests = requests
            }
        } catch {
            await MainActor.run {
                errorMessage = "Error: \(error.localizedDescription)"
            }
            throw error
        }
    }
    
    // MARK: - قبول طلب
    func acceptRequest(_ request: FriendRequest, userViewModel: UserViewModel) async throws {
        guard let recordName = request.recordID else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let recordID = CKRecord.ID(recordName: recordName)
            let record = try await publicDB.record(for: recordID)
            
            // التحقق من صلاحية الطلب
            guard let toUserID = record["to"] as? String,
                  toUserID == userViewModel.currentUser?.id else {
                throw FriendRequestError.requestNotFound
            }
            
            record["status"] = FriendRequestStatus.accepted.rawValue as CKRecordValue
            record["respondedAt"] = Date() as CKRecordValue
            
            _ = try await publicDB.save(record)
            
            // Update both users' friends lists
            try await addFriendConnection(userID1: request.from, userID2: request.to)
            
            await MainActor.run {
                receivedRequests.removeAll { $0.recordID == request.recordID }
            }
            
        } catch {
            await MainActor.run {
                errorMessage = "Failed to accept request: \(error.localizedDescription)"
            }
            throw error
        }
    }
    
    // MARK: - رفض طلب
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
            await MainActor.run {
                errorMessage = "Failed to reject request: \(error.localizedDescription)"
            }
            throw error
        }
    }
    
    // MARK: - إلغاء طلب مرسل (من SocialManager)
    func cancelSentRequest(_ request: FriendRequest) async throws {
        guard let recordName = request.recordID else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let recordID = CKRecord.ID(recordName: recordName)
            try await publicDB.deleteRecord(withID: recordID)
            
            await MainActor.run {
                sentRequests.removeAll { $0.recordID == request.recordID }
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to cancel request: \(error.localizedDescription)"
            }
            throw error
        }
    }
    
    // MARK: - Helper: Add Friend Connection
    private func addFriendConnection(userID1: String, userID2: String) async throws {
        // جلب السجلين بشكل متوازي
        async let record1Future = publicDB.record(for: CKRecord.ID(recordName: userID1))
        async let record2Future = publicDB.record(for: CKRecord.ID(recordName: userID2))
        
        let (record1, record2) = try await (record1Future, record2Future)
        
        // Update user 1
        var friends1 = record1["friends"] as? [String] ?? []
        if !friends1.contains(userID2) {
            friends1.append(userID2)
            record1["friends"] = friends1 as CKRecordValue
        }
        
        // Update user 2
        var friends2 = record2["friends"] as? [String] ?? []
        if !friends2.contains(userID1) {
            friends2.append(userID1)
            record2["friends"] = friends2 as CKRecordValue
        }
        
        // حفظ كلا السجلين
        _ = try await publicDB.modifyRecords(saving: [record1, record2], deleting: [])
    }
    
    // MARK: - البحث عن مستخدمين
    func searchUsers(by username: String) async throws -> [User] {
        isLoading = true
        defer { isLoading = false }
        
        let predicate = NSPredicate(format: "username CONTAINS[c] %@", username)
        let query = CKQuery(recordType: "User", predicate: predicate)
        
        do {
            let results = try await publicDB.records(matching: query)
            
            return results.matchResults.compactMap { _, result in
                guard let record = try? result.get() else { return nil }
                return User(
                    id: record.recordID.recordName,
                    username: record["username"] as? String ?? "",
                    authMode: .registered,
                    friends: record["friends"] as? [String] ?? [],
                    ownedPlanets: record["ownedPlanets"] as? [String] ?? []
                )
            }
        } catch {
            await MainActor.run {
                errorMessage = "Search failed: \(error.localizedDescription)"
            }
            throw error
        }
    }
    
    // MARK: - جلب قائمة الأصدقاء (من SocialManager)
    func fetchFriends(for userID: String) async throws -> [User] {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let recordID = CKRecord.ID(recordName: userID)
            let record = try await publicDB.record(for: recordID)
            let friendIDs = record["friends"] as? [String] ?? []
            
            var friends: [User] = []
            for friendID in friendIDs {
                let friendRecord = try await publicDB.record(for: CKRecord.ID(recordName: friendID))
                let user = User(
                    id: friendRecord.recordID.recordName,
                    username: friendRecord["username"] as? String ?? "",
                    authMode: .registered,
                    friends: friendRecord["friends"] as? [String] ?? [],
                    ownedPlanets: friendRecord["ownedPlanets"] as? [String] ?? []
                )
                friends.append(user)
            }
            
            return friends
        } catch {
            await MainActor.run {
                errorMessage = "Failed to fetch friends: \(error.localizedDescription)"
            }
            throw error
        }
    }
    
    // MARK: - حذف صديق
    func removeFriend(myUserID: String, friendID: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Remove from my list
            let myRecordID = CKRecord.ID(recordName: myUserID)
            let myRecord = try await publicDB.record(for: myRecordID)
            var myFriends = myRecord["friends"] as? [String] ?? []
            myFriends.removeAll { $0 == friendID }
            myRecord["friends"] = myFriends as CKRecordValue
            _ = try await publicDB.save(myRecord)
            
            // Remove from their list
            let theirRecordID = CKRecord.ID(recordName: friendID)
            let theirRecord = try await publicDB.record(for: theirRecordID)
            var theirFriends = theirRecord["friends"] as? [String] ?? []
            theirFriends.removeAll { $0 == myUserID }
            theirRecord["friends"] = theirFriends as CKRecordValue
            _ = try await publicDB.save(theirRecord)
            
        } catch {
            await MainActor.run {
                errorMessage = "Failed to remove friend: \(error.localizedDescription)"
            }
            throw error
        }
    }
    
    // MARK: - إنشاء dummy user (للتجربة فقط - من SocialManager)
    func createDummyUser(username: String) async -> String? {
        do {
            let uniqueID = UUID().uuidString
            let recordID = CKRecord.ID(recordName: uniqueID)
            
            let record = CKRecord(recordType: "User", recordID: recordID)
            record["username"] = username as CKRecordValue
            record["friends"] = [] as CKRecordValue
            record["ownedPlanets"] = [] as CKRecordValue
            record["createdAt"] = Date() as CKRecordValue
            
            let saved = try await publicDB.save(record)
            print("✅ Dummy User created:", saved.recordID.recordName)
            return saved.recordID.recordName
            
        } catch {
            print("❌ Error creating dummy user:", error)
            await MainActor.run {
                errorMessage = "Error: \(error.localizedDescription)"
            }
            return nil
        }
    }
}
