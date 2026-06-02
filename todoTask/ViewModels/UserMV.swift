//
//  UserMV.swift
//  todoTask
//

import Foundation
import Combine


class UserViewModel: ObservableObject {
    @Published var currentUser: User?

    private let userDefaultsKey = "currentUser"

    var isLoggedIn: Bool { currentUser != nil }

    init() {
        loadLocalUser()

        // سوّي user تلقائي لو ما فيه
        if currentUser == nil {
            let autoUser = User(
                id: UUID().uuidString,
                username: "Player",
                email: "",
                authMode: .guest
            )
            currentUser = autoUser
            saveLocally()
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

    func deleteAccount() async {
        await MainActor.run {
            self.clearLocalUser()
        }
    }
}
