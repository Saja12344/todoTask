//
//  UserError.swift
//  todoTask
//
//  Created by saja khalid on 20/08/1447 AH.
//


//
//  Untitled.swift
//  toDotask
//
//  Created by saja khalid on 16/08/1447 AH.
//

import Foundation
import CloudKit
import Combine


enum UserError: Error {
    case iCloudUnavailable
    case notGuest
}

class UserViewModel: ObservableObject {
    
    @Published var currentUser: User?
    
    // CloudKit remains for registered users; guest flow will not use it
//    private let container = CKContainer.default()
    private lazy var publicDB = container.publicCloudDatabase
    
    private let userDefaultsKey = "currentUser"
    
    // MARK: - Derived state
    var isLoggedIn: Bool {
        currentUser != nil
    }
    
    // MARK: - Random token helper (Base62)
    private func randomToken(length: Int) -> String {
        let charset = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789")
        var rng = SystemRandomNumberGenerator()
        return String((0..<length).compactMap { _ in charset.randomElement(using: &rng) })
    }
    
    // MARK: - App Entry Point (Guest)
    // Creates a guest with:
    // - id: 8-char token
    // - username: "Guest-" + 6-char token (e.g., Guest-A23SSW)
    func startAsGuest() {
        // Generate tokens
        let randomID = randomToken(length: 8)
        let usernameSuffix = randomToken(length: 6)
        let guestUsername = "Guest-\(usernameSuffix)"
        
        // Build guest user
        let guest = User(
            id: randomID,
            username: guestUsername,
            authMode: .guest,
            friends: [],
            ownedPlanets: []
        )
        
        currentUser = guest
        saveLocally()
    }
    
    // MARK: - Edit Username (Local only; no CloudKit dependency)
    @MainActor
    func updateUsername(to newName: String) async {
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard var user = currentUser else { return }
        
        user.username = trimmed
        currentUser = user
        saveLocally()
        
        // Note: No CloudKit sync here to avoid using `container`.
        // If you later enable CloudKit, you can add a sync call conditionally.
    }
    
    // MARK: - Login مباشرة (Registered via iCloud)
    func loginWithiCloud() async throws {
        let status = try await container.accountStatus()
        guard status == .available else {
            throw UserError.iCloudUnavailable
        }
        
        let appleID = try await container.userRecordID()
        
        do {
            let record = try await publicDB.record(for: appleID)
            
            currentUser = User(
                id: record.recordID.recordName,
                username: record["username"] as? String ?? "User",
                authMode: .registered,
                friends: record["friends"] as? [String] ?? [],
                ownedPlanets: record["ownedPlanets"] as? [String] ?? []
            )
            
        } catch {
            let newRecord = CKRecord(recordType: "User", recordID: appleID)
            newRecord["username"] = "New User" as CKRecordValue
            newRecord["friends"] = [] as CKRecordValue
            newRecord["ownedPlanets"] = [] as CKRecordValue
            
            let saved = try await publicDB.save(newRecord)
            
            currentUser = User(
                id: saved.recordID.recordName,
                username: "New User",
                authMode: .registered,
                friends: [],
                ownedPlanets: []
            )
        }
        
        saveLocally()
    }
    
    // MARK: - Upgrade Guest → Cloud
    func upgradeGuestToCloud() async throws {
        guard var user = currentUser,
              user.authMode == .guest else {
            throw UserError.notGuest
        }
        
        let status = try await container.accountStatus()
        guard status == .available else {
            throw UserError.iCloudUnavailable
        }
        
        let appleID = try await container.userRecordID()
        
        let record = CKRecord(recordType: "User", recordID: appleID)
        record["username"] = user.username as CKRecordValue
        record["friends"] = user.friends as CKRecordValue
        record["ownedPlanets"] = user.ownedPlanets as CKRecordValue
        
        let saved = try await publicDB.save(record)
        
        user.id = saved.recordID.recordName
        user.authMode = .registered
        
        currentUser = user
        saveLocally()
    }
    
    // MARK: - Helpers
    func canUseFriends() -> Bool {
        return currentUser?.authMode == .registered
    }
    
    private func saveLocally() {
        if let user = currentUser,
           let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
    
    func loadLocalUser() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            currentUser = user
        } else {
            currentUser = nil
        }
    }
    
    // Clear local session (for logout / fresh start)
    func clearLocalUser() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        currentUser = nil
    }
}
