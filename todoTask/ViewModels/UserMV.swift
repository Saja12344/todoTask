//
//  UserMV.swift
//  todoTask
//

import Foundation
import CloudKit
import Combine
import AuthenticationServices

class UserViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isGuest: Bool = false
    @Published var isCheckingAuth = false

    private let userDefaultsKey = "currentUser"
    private let container = CKContainer.default()
    private lazy var privateDB = container.privateCloudDatabase
    private lazy var publicDB  = container.publicCloudDatabase

    var isLoggedIn: Bool { currentUser != nil }

    init() {
        loadLocalUser()
        isCheckingAuth = false
    }

    // MARK: - Login / Sign Up with Apple
    @MainActor
    func loginWithApple(id: String, name: PersonNameComponents?, email: String?) async throws {

        let username: String
        if let givenName = name?.givenName, !givenName.isEmpty {
            username = "\(givenName)#\(String(id.suffix(4)))"
        } else {
            username = "User#\(String(id.suffix(4)))"
        }

        // احفظ محلياً أول - عشان التطبيق يشتغل حتى لو CloudKit فشل
        currentUser = User(id: id, username: username, email: email ?? "")
        saveLocally()
        print("✅ user saved locally: \(username)")

        // حاول تحفظ في CloudKit في الخلفية
        Task {
            await saveToCloudKit(id: id, username: username, email: email ?? "")
        }
    }

    // MARK: - Save to CloudKit (background)
    private func saveToCloudKit(id: String, username: String, email: String) async {
        let privateRecordID = CKRecord.ID(recordName: "profile_\(id)")

        do {
            // حاول تجيب البيانات الموجودة
            let record = try await privateDB.record(for: privateRecordID)
            let savedUsername = record["username"] as? String ?? username

            await MainActor.run {
                if var _ = self.currentUser {
                    self.currentUser = User(id: id, username: savedUsername, email: email)
                    self.saveLocally()
                }
            }
            print("✅ CloudKit: existing user loaded: \(savedUsername)")

        } catch let error as CKError where error.code == .unknownItem {
            // مستخدم جديد
            do {
                let newRecord = CKRecord(recordType: "UserProfile", recordID: privateRecordID)
                newRecord["username"] = username as CKRecordValue
                newRecord["email"]    = email as CKRecordValue
                newRecord["appleID"]  = id as CKRecordValue
                _ = try await privateDB.save(newRecord)
                print("✅ CloudKit: new user saved: \(username)")

                // احفظ في Public عشان الأصدقاء
                await saveUsernamePublic(appleID: id, username: username)
            } catch {
                print("⚠️ CloudKit save failed (offline mode): \(error.localizedDescription)")
            }

        } catch {
            print("⚠️ CloudKit unavailable (offline mode): \(error.localizedDescription)")
        }
    }

    // MARK: - Save username publicly
    private func saveUsernamePublic(appleID: String, username: String) async {
        let recordID = CKRecord.ID(recordName: appleID)
        let record = CKRecord(recordType: "Users", recordID: recordID)
        record["username"] = username as CKRecordValue
        _ = try? await publicDB.save(record)
    }

    // MARK: - Fetch Current User
    func fetchCurrentUser() {
        Task {
            guard let userID = currentUser?.id else { return }
            let privateRecordID = CKRecord.ID(recordName: "profile_\(userID)")
            do {
                let record = try await privateDB.record(for: privateRecordID)
                await MainActor.run {
                    self.currentUser = User(
                        id: userID,
                        username: record["username"] as? String ?? "User",
                        email: record["email"] as? String ?? "",
                        authMode: .registered
                    )
                    self.saveLocally()
                }
            } catch {
                print("Fetch error: \(error)")
            }
        }
    }

    // MARK: - Check Apple Credential State
    func checkAppleCredentialState() {
        guard let userID = currentUser?.id else {
            isCheckingAuth = false
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.isCheckingAuth = false
        }

        let provider = ASAuthorizationAppleIDProvider()
        provider.getCredentialState(forUserID: userID) { state, _ in
            DispatchQueue.main.async {
                switch state {
                case .authorized: break
                case .revoked, .notFound: self.clearLocalUser()
                default: break
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
