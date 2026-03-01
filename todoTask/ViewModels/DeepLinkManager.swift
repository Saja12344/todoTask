//
//  DeepLinkManager.swift
//  todoTask
//

import SwiftUI
import Combine

// MARK: - Deep Link Manager
class DeepLinkManager: ObservableObject {
    @Published var pendingChallengeID: String? = nil
    @Published var pendingFromUser: String? = nil
    @Published var shouldOpenChallenge: Bool = false

    static let shared = DeepLinkManager()
    private init() {}

    // Parse: todoTask://challenge?id=CH123&from=Saja
    func handle(url: URL) {
        guard url.scheme == "todoTask",
              url.host == "challenge" else { return }

        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let id   = components?.queryItems?.first(where: { $0.name == "id" })?.value
        let from = components?.queryItems?.first(where: { $0.name == "from" })?.value

        DispatchQueue.main.async {
            self.pendingChallengeID  = id
            self.pendingFromUser     = from
            self.shouldOpenChallenge = true
        }
    }

    // توليد رابط التحدي
    func generateLink(challengeID: String, fromUsername: String) -> URL? {
        var components = URLComponents()
        components.scheme = "todoTask"
        components.host   = "challenge"
        components.queryItems = [
            URLQueryItem(name: "id",   value: challengeID),
            URLQueryItem(name: "from", value: fromUsername)
        ]
        return components.url
    }
}
