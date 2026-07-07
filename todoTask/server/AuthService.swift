//
//  AuthService.swift
//  todoTask
//
//  Firebase-backed authentication: email/password, Sign in with Apple,
//  and linking multiple providers onto a single account.
//

import Foundation
import AuthenticationServices
import CryptoKit
import FirebaseAuth

/// Result describing the signed-in Firebase account.
struct AuthAccount {
    let uid: String
    let email: String
    let displayName: String
}

enum AuthServiceError: LocalizedError {
    case missingAppleToken
    case appleCancelled
    case underlying(String)

    var errorDescription: String? {
        switch self {
        case .missingAppleToken: return "Could not read the Apple identity token. Please try again."
        case .appleCancelled:     return "Apple sign in was cancelled."
        case .underlying(let m):  return m
        }
    }
}

/// Nonce helpers for Sign in with Apple (protects against replay attacks).
enum AppleNonce {
    static func random(length: Int = 32) -> String {
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remaining = length
        while remaining > 0 {
            var byte: UInt8 = 0
            if SecRandomCopyBytes(kSecRandomDefault, 1, &byte) == errSecSuccess,
               byte < UInt8(charset.count) {
                result.append(charset[Int(byte)])
                remaining -= 1
            }
        }
        return result
    }

    static func sha256(_ input: String) -> String {
        SHA256.hash(data: Data(input.utf8))
            .map { String(format: "%02x", $0) }
            .joined()
    }
}

@MainActor
final class AuthService {

    // MARK: - Email / Password

    func signUp(email: String, password: String, username: String) async throws -> AuthAccount {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        if !username.isEmpty {
            let change = result.user.createProfileChangeRequest()
            change.displayName = username
            try? await change.commitChanges()
        }
        return account(from: result.user, fallbackName: username)
    }

    func signIn(email: String, password: String) async throws -> AuthAccount {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return account(from: result.user)
    }

    // MARK: - Sign in with Apple

    /// Finishes the Apple flow with Firebase. If an account is already signed in
    /// (e.g. email/password), the Apple credential is *linked* onto it instead of
    /// creating a separate account.
    func finishAppleSignIn(
        appleCredential: ASAuthorizationAppleIDCredential,
        rawNonce: String
    ) async throws -> AuthAccount {
        guard let tokenData = appleCredential.identityToken,
              let idToken = String(data: tokenData, encoding: .utf8) else {
            throw AuthServiceError.missingAppleToken
        }

        let credential = OAuthProvider.appleCredential(
            withIDToken: idToken,
            rawNonce: rawNonce,
            fullName: appleCredential.fullName
        )
        let name = appleDisplayName(appleCredential)

        // Prefer linking onto the currently signed-in account (account merge).
        if let current = Auth.auth().currentUser, !current.isAnonymous {
            do {
                let linked = try await current.link(with: credential)
                return account(from: linked.user, fallbackName: name)
            } catch let error as NSError {
                // Apple identity already tied to another account → sign into it.
                if error.code == AuthErrorCode.credentialAlreadyInUse.rawValue,
                   let updated = error.userInfo[AuthErrorUserInfoUpdatedCredentialKey] as? AuthCredential {
                    let result = try await Auth.auth().signIn(with: updated)
                    return account(from: result.user)
                }
                throw error
            }
        }

        let result = try await Auth.auth().signIn(with: credential)
        return account(from: result.user, fallbackName: name)
    }

    // MARK: - Session

    func currentAccount() -> AuthAccount? {
        guard let user = Auth.auth().currentUser else { return nil }
        return account(from: user)
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else { return }
        try await user.delete()
    }

    func sendPasswordReset(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }

    // MARK: - Mapping

    private func account(from user: FirebaseAuth.User, fallbackName: String = "") -> AuthAccount {
        let email = user.email ?? ""
        let name = user.displayName?.isEmpty == false
            ? user.displayName!
            : (fallbackName.isEmpty ? emailPrefix(email) : fallbackName)
        return AuthAccount(uid: user.uid, email: email, displayName: name)
    }

    private func emailPrefix(_ email: String) -> String {
        guard let at = email.firstIndex(of: "@") else { return email.isEmpty ? "Player" : email }
        let prefix = String(email[..<at])
        return prefix.isEmpty ? "Player" : prefix
    }

    private func appleDisplayName(_ credential: ASAuthorizationAppleIDCredential) -> String {
        [credential.fullName?.givenName, credential.fullName?.familyName]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
}
