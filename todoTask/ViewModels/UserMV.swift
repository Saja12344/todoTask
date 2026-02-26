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
