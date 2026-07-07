//
//  OrbAchievementStore.swift
//  todoTask
//

import Foundation
import Combine

struct WonPlanetRecord: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var planetName: String
    var planetGradient: [String]
    var planetGlow: Double
    var planetTextureAsset: String
    var planetTextureOpacity: Double
    var wonAt: Date
    var opponentName: String?
}

final class OrbAchievementStore: ObservableObject {
    static let shared = OrbAchievementStore()

    private let storageKey = "orb_won_planets_v1"

    @Published private(set) var wonPlanets: [WonPlanetRecord] = []

    init() { load() }

    func addWonPlanet(from winner: ChallengeWinner, opponentName: String? = nil) {
        let record = WonPlanetRecord(
            planetName: winner.planetName,
            planetGradient: winner.planetGradient,
            planetGlow: winner.planetGlow,
            planetTextureAsset: winner.planetTextureAsset,
            planetTextureOpacity: winner.planetTextureOpacity,
            wonAt: Date(),
            opponentName: opponentName
        )
        wonPlanets.insert(record, at: 0)
        save()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([WonPlanetRecord].self, from: data) else { return }
        wonPlanets = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(wonPlanets) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
