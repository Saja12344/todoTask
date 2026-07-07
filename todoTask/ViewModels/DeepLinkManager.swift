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
    private static let inviteWebBase = "https://todotask-6fc38.web.app/join"

    private init() {}

    // todoTask://challenge?id=…  or  https://todotask-6fc38.web.app/join?id=…
    func handle(url: URL) {
        guard let payload = Self.parseChallengeURL(url) else { return }
        DispatchQueue.main.async {
            self.pendingChallengeID  = payload.id
            self.pendingFromUser     = payload.from
            self.shouldOpenChallenge = true
        }
    }

    /// https link — WhatsApp / iMessage show this as a tappable blue link.
    func generateLink(challengeID: String, fromUsername: String) -> URL {
        var components = URLComponents(string: Self.inviteWebBase)!
        components.queryItems = [
            URLQueryItem(name: "id", value: challengeID),
            URLQueryItem(name: "from", value: fromUsername)
        ]
        return components.url ?? URL(string: "\(Self.inviteWebBase)?id=\(challengeID)")!
    }

    func inviteMessage(roomId: String, fromUsername: String, lang: LanguageManager) -> String {
        let link = generateLink(challengeID: roomId, fromUsername: fromUsername).absoluteString
        return lang.challengeShareMessage(roomId: roomId, from: fromUsername, link: link)
    }

    /// Single text item so messengers linkify the https URL once (no duplicate todoTask://).
    func shareItems(roomId: String, fromUsername: String, lang: LanguageManager) -> [Any] {
        [inviteMessage(roomId: roomId, fromUsername: fromUsername, lang: lang)]
    }

    private static func parseChallengeURL(_ url: URL) -> (id: String?, from: String?)? {
        if url.scheme?.lowercased() == "todotask", url.host?.lowercased() == "challenge" {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            return (
                components?.queryItems?.first(where: { $0.name == "id" })?.value,
                components?.queryItems?.first(where: { $0.name == "from" })?.value
            )
        }

        guard url.scheme?.lowercased() == "https",
              url.host?.contains("todotask-6fc38") == true,
              url.path.hasPrefix("/join") else { return nil }

        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        return (
            components?.queryItems?.first(where: { $0.name == "id" })?.value,
            components?.queryItems?.first(where: { $0.name == "from" })?.value
        )
    }
}
