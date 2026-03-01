//
//  CloudKitManager.swift
//  todoTask
//

import CloudKit
import Foundation

let container = CKContainer.default()

class CloudKitManager {
    private let container = CKContainer.default()
    private lazy var publicDB = container.publicCloudDatabase

    // MARK: - Create User (username = recordID)
    func createUser(username: String) async throws {
        // الـ username نفسه يصير الـ ID - سهل تشاركيه
        let recordID = CKRecord.ID(recordName: username)
        let record = CKRecord(recordType: "User", recordID: recordID)
        record["username"] = username as CKRecordValue
        record["createdAt"] = Date() as CKRecordValue
        try await publicDB.save(record)
    }

    // MARK: - Fetch Current User ID
    func fetchCurrentUserID() async throws -> String {
        let userRecordID = try await container.userRecordID()
        return userRecordID.recordName
    }

    // MARK: - Fetch All Users
    func fetchUsers() async throws -> [CKRecord] {
        let query = CKQuery(recordType: "User", predicate: NSPredicate(value: true))
        let result = try await publicDB.records(matching: query)
        return result.matchResults.compactMap { try? $0.1.get() }
    }

    // MARK: - Check if username exists
    func usernameExists(_ username: String) async throws -> Bool {
        let recordID = CKRecord.ID(recordName: username)
        do {
            _ = try await publicDB.record(for: recordID)
            return true
        } catch {
            return false
        }
    }
}
