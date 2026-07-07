//
//  UserMV.swift
//  todoTask
//

import Foundation
import Combine
import AuthenticationServices
import FirebaseAuth

@MainActor
class UserViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var authError: String?
    @Published var isBusy = false

    private let userDefaultsKey = "currentUser"
    private let auth = AuthService()
    private var authStateHandle: AuthStateDidChangeListenerHandle?

    /// Offline reviewer account. Match these in App Store Connect →
    /// App Review Information → demo account notes.
    static let demoUsername = "OrinDemo"
    static let demoPassword = "Orin2026!"

    var isLoggedIn: Bool { currentUser != nil }

    init() {
        restoreSession()
        observeFirebaseAuth()
    }

    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    // MARK: - Session restore

    private func restoreSession() {
        // A live Firebase session takes precedence over any cached local user.
        if let account = auth.currentAccount() {
            currentUser = mapped(account)
            saveLocally()
        } else {
            loadLocalUser()
        }
    }

    /// Keeps `currentUser` in sync if Firebase drops/refreshes the session.
    private func observeFirebaseAuth() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, fbUser in
            guard let self else { return }
            Task { @MainActor in
                if let fbUser {
                    // Ignore anonymous sessions; we manage guests locally.
                    guard !fbUser.isAnonymous else { return }
                    if let account = self.auth.currentAccount() {
                        self.currentUser = self.mapped(account)
                        self.saveLocally()
                    }
                } else if self.currentUser?.authMode == .registered,
                          self.currentUser?.id != "orin-demo-review" {
                    // Firebase session ended for a real account → return to login.
                    self.currentUser = nil
                    UserDefaults.standard.removeObject(forKey: self.userDefaultsKey)
                }
            }
        }
    }

    // MARK: - Email / Password

    func signUp(username: String, email: String, password: String) async {
        let name = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let mail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let pass = password

        guard !mail.isEmpty, !pass.isEmpty else {
            authError = "Please enter your email and a password."
            return
        }

        await run {
            let account = try await self.auth.signUp(email: mail, password: pass, username: name)
            self.currentUser = self.mapped(account)
            self.saveLocally()
        }
    }

    func signInWithEmail(email: String, password: String) async {
        let mail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let pass = password

        guard !mail.isEmpty, !pass.isEmpty else {
            authError = "Please enter your email and password."
            return
        }

        await run {
            let account = try await self.auth.signIn(email: mail, password: pass)
            self.currentUser = self.mapped(account)
            self.saveLocally()
        }
    }

    // MARK: - Sign in with Apple

    func signInWithApple(credential: ASAuthorizationAppleIDCredential, rawNonce: String) async {
        await run {
            let account = try await self.auth.finishAppleSignIn(
                appleCredential: credential,
                rawNonce: rawNonce
            )
            self.currentUser = self.mapped(account)
            self.saveLocally()
        }
    }

    func sendPasswordReset(email: String) async {
        let mail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !mail.isEmpty else {
            authError = "Enter your email to reset the password."
            return
        }
        await run { try await self.auth.sendPasswordReset(email: mail) }
    }

    // MARK: - Guest / demo (kept for App Store review)

    func loginAsGuest() {
        authError = nil
        currentUser = User(
            id: "guest_\(UUID().uuidString)",
            username: "Player",
            email: "",
            authMode: .guest
        )
        saveLocally()
    }

    /// Offline reviewer login. Works without any network so App Review always passes.
    @discardableResult
    func login(username: String, password: String) -> Bool {
        let trimmedUser = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPass = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedUser.isEmpty, !trimmedPass.isEmpty else {
            authError = "Please enter username and password."
            return false
        }

        let matchesDemo =
            trimmedUser.caseInsensitiveCompare(Self.demoUsername) == .orderedSame
            && trimmedPass == Self.demoPassword

        guard matchesDemo else {
            authError = "Invalid username or password."
            return false
        }

        authError = nil
        currentUser = User(
            id: "orin-demo-review",
            username: "Orin Demo",
            email: "review@orin.app",
            authMode: .registered
        )
        saveLocally()
        return true
    }

    // MARK: - Sign out / delete

    func logOut() {
        try? auth.signOut()
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        currentUser = nil
        authError = nil
    }

    func deleteAccount() async {
        try? await auth.deleteAccount()
        logOut()
    }

    func clearLocalUser() {
        logOut()
    }

    // MARK: - Helpers

    private func run(_ work: @escaping () async throws -> Void) async {
        isBusy = true
        authError = nil
        defer { isBusy = false }
        do {
            try await work()
        } catch let error as AuthServiceError {
            if case .appleCancelled = error { return }
            authError = error.errorDescription
        } catch {
            authError = friendlyMessage(error)
        }
    }

    private func friendlyMessage(_ error: Error) -> String {
        let ns = error as NSError
        if let code = AuthErrorCode(rawValue: ns.code) {
            switch code {
            case .emailAlreadyInUse:      return "That email already has an account. Try signing in."
            case .invalidEmail:           return "That email address looks invalid."
            case .weakPassword:           return "Use a stronger password (at least 6 characters)."
            case .wrongPassword:          return "Incorrect password. Please try again."
            case .userNotFound:           return "No account found for that email."
            case .networkError:           return "Network problem. Check your connection and retry."
            case .tooManyRequests:        return "Too many attempts. Please wait a moment."
            default:                      break
            }
        }
        return ns.localizedDescription
    }

    private func mapped(_ account: AuthAccount) -> User {
        User(
            id: account.uid,
            username: account.displayName.isEmpty ? "Player" : account.displayName,
            email: account.email,
            authMode: .registered
        )
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
}
