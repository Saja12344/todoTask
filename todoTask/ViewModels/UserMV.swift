////
////  UserError.swift
////  todoTask
////
////  Created by saja khalid on 20/08/1447 AH.
////
//
//
////
////  Untitled.swift
////  toDotask
////
////  Created by saja khalid on 16/08/1447 AH.
////

import Foundation
import CloudKit
import Combine
import AuthenticationServices
//
//
//enum UserError: Error {
//    case iCloudUnavailable
//    case notGuest
//    case userAlreadyExists
//    case invalidCredentials
//}
//
//class UserViewModel: ObservableObject {
//    
//    @Published var currentUser: User?
//    @Published var isGuest: Bool = false
//    // CloudKit remains for registered users; guest flow will not use it
////    private let container = CKContainer.default()
//    private lazy var publicDB = container.publicCloudDatabase
//    
//    private let userDefaultsKey = "currentUser"
//    
//    // MARK: - Derived state
//    var isLoggedIn: Bool {
//        currentUser != nil
//    }
//    
// 
//    
////    // MARK: - App Entry Point (Guest)
////
////    func startAsGuest() {
////        // Build guest user
////        let guest = User(
////
////            id: UUID().uuidString,
////            username: "Guest",
////            email: "",
////            authMode: .guest,
////            friends: [],
////            ownedPlanets: []
////        )
////        
////        currentUser = guest
////        saveLocally()
////    }
//    
////    // MARK: - Edit Username (Local only; no CloudKit dependency)
////    @MainActor
////    func updateUsername(to newName: String) async {
////        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
////        guard !trimmed.isEmpty else { return }
////        guard var user = currentUser else { return }
////        
////        user.username = trimmed
////        currentUser = user
////        saveLocally()
////        
////        // Note: No CloudKit sync here to avoid using `container`.
////        // If you later enable CloudKit, you can add a sync call conditionally.
////    }
////    
//    // MARK: - Login مباشرة (Registered via iCloud)
//    func loginWithApple(id: String, name: PersonNameComponents?, email: String?) async throws {
//
//
//        let recordID = CKRecord.ID(recordName: id)
//        
//        do {
//            // حاول تجيب المستخدم من الكلاود
//            let record = try await publicDB.record(for: recordID)
//            
//            // ✅ المستخدم موجود → Login
//            let user = User(
//                id: record.recordID.recordName,
//                username: record["username"] as? String ?? "User",
//                email: record["email"] as? String ?? (email ?? ""),
//                authMode: .registered,
//                friends: record["friends"] as? [String] ?? [],
//                ownedPlanets: record["ownedPlanets"] as? [String] ?? []
//            )
//
//            currentUser = user
//            
//        } catch {
//            // ✅ المستخدم مو موجود → Sign Up تلقائي
//            let newRecord = CKRecord(recordType: "User", recordID: recordID)
//            newRecord["username"] = (name?.formatted() ?? "New User") as CKRecordValue
//            newRecord["email"] = (email ?? "") as CKRecordValue
//            // شرط: إذا الحقول موجودة ضعها، إذا لا خليها nil
//                 if let friends: [String] = nil { // حاليا فارغة، خليها nil
//                     newRecord["friends"] = friends as CKRecordValue
//                 }
//
//                 if let ownedPlanets: [String] = nil { // حاليا فارغة، خليها nil
//                     newRecord["ownedPlanets"] = ownedPlanets as CKRecordValue
//                 }
//
//            let saved = try await publicDB.save(newRecord)
//
//            currentUser = User(
//                id: saved.recordID.recordName,
//                username: name?.formatted() ?? "New User",
//                email: email ?? "",
//                authMode: .registered,
//                friends: [],
//                ownedPlanets: []
//            )
//        }
//        
//        saveLocally()
//    }
//    
//    // MARK: - Upgrade Guest → Cloud
//    func upgradeGuestToCloud() async throws {
//        guard var user = currentUser,
//              user.authMode == .guest else {
//            throw UserError.notGuest
//        }
//        
//        let status = try await container.accountStatus()
//        guard status == .available else {
//            throw UserError.iCloudUnavailable
//        }
//        
//        let appleID = try await container.userRecordID()
//        
//        let record = CKRecord(recordType: "User", recordID: appleID)
//        record["username"] = user.username as CKRecordValue
//        record["friends"] = user.friends as CKRecordValue
//        record["ownedPlanets"] = user.ownedPlanets as CKRecordValue
//        
//        let saved = try await publicDB.save(record)
//        
//        user.id = saved.recordID.recordName
//        user.authMode = .registered
//        
//        currentUser = user
//        saveLocally()
//    }
//    
//    // MARK: - Helpers
//    func canUseFriends() -> Bool {
//        return currentUser?.authMode == .registered
//    }
//    
//    private func saveLocally() {
//        if let user = currentUser,
//           let data = try? JSONEncoder().encode(user) {
//            UserDefaults.standard.set(data, forKey: userDefaultsKey)
//        }
//    }
//    
//    func loadLocalUser() {
//        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
//           let user = try? JSONDecoder().decode(User.self, from: data) {
//            currentUser = user
//        } else {
//            currentUser = nil
//        }
//    }
//    
//    // Clear local session (for logout / fresh start)
//    func clearLocalUser() {
//        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
//        currentUser = nil
//    }
//}
// Model


// ViewModel
class UserViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isGuest: Bool = false
    @Published var isCheckingAuth = true

    private let userDefaultsKey = "currentUser"
    private let container = CKContainer.default()
    private lazy var publicDB = container.publicCloudDatabase

    var isLoggedIn: Bool { currentUser != nil }
  
    init() {
        fetchCurrentUser()
    }
    func fetchCurrentUser() {
            let predicate = NSPredicate(value: true)
            let query = CKQuery(recordType: "Users", predicate: predicate)
            
            CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { results, error in
                DispatchQueue.main.async {
                    if let record = results?.first {
                        // تحويل CKRecord إلى User struct
                     
                        
                        self.currentUser = User(
                                       
                            id: record.recordID.recordName,
                            username: "\(record["username"] as? String ?? "User")#\(record.recordID.recordName.suffix(4))",
                             email: record["email"] as? String ?? "",
                             authMode: .registered
                                        )
                        
                    }
                }
            }
        }
    
    // MARK: - Login / Sign Up with Apple
    @MainActor
    func loginWithApple(id: String, name: PersonNameComponents?, email: String?) async throws {

        let recordID = CKRecord.ID(recordName: id)
        
        // توليد username فريد: الاسم + آخر 4 أحرف من Apple ID
        let generatedUsername = "\(name?.givenName ?? "User")#\(String(id.suffix(4)))"

        do {
            let record = try await publicDB.record(for: recordID)

            // المستخدم موجود → login
            let user = User(
                id: record.recordID.recordName,
                username: record["username"] as? String ?? generatedUsername,
                email: record["email"] as? String ?? (email ?? "")
            )

            currentUser = user

        } catch {
            // المستخدم غير موجود → sign up
            let newRecord = CKRecord(recordType: "User", recordID: recordID)
            newRecord["username"] = generatedUsername as CKRecordValue?
            newRecord["email"] = (email ?? "") as CKRecordValue

            let saved = try await publicDB.save(newRecord)

            currentUser = User(
                id: saved.recordID.recordName,
                username: generatedUsername ,
                email: email ?? ""
            )
        }

        saveLocally()
    }
    
    
    func checkAppleCredentialState() {
        guard let userID = currentUser?.id else {
            isCheckingAuth = false
            return
        }

        let provider = ASAuthorizationAppleIDProvider()

        provider.getCredentialState(forUserID: userID) { state, _ in
            DispatchQueue.main.async {
                switch state {
                case .authorized:
                    break
                case .revoked, .notFound:
                    self.clearLocalUser()
                default:
                    break
                }
                self.isCheckingAuth = false
            }
        }
    }

    


    // MARK: - Helpers
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

    func clearLocalUser() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        currentUser = nil
    }
}
