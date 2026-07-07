//
//  OrbAchievementStore.swift
//  todoTask
//

import Foundation
import Combine

struct WonPlanetRecord: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var planetName: String
    var planetNameEn: String?
    var planetNameAr: String?
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
        let pair = PlanetNameCatalog.pair(matching: winner.planetName)
        let record = WonPlanetRecord(
            planetName: winner.planetName,
            planetNameEn: winner.planetNameEn ?? pair?.en,
            planetNameAr: winner.planetNameAr ?? pair?.ar,
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
              var decoded = try? JSONDecoder().decode([WonPlanetRecord].self, from: data) else { return }

        var migrated = false
        for index in decoded.indices {
            let pair = PlanetNameCatalog.pair(matching: decoded[index].planetName)
            if decoded[index].planetNameEn == nil, let en = pair?.en {
                decoded[index].planetNameEn = en
                migrated = true
            }
            if decoded[index].planetNameAr == nil, let ar = pair?.ar {
                decoded[index].planetNameAr = ar
                migrated = true
            }
        }
        wonPlanets = decoded
        if migrated { save() }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(wonPlanets) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
