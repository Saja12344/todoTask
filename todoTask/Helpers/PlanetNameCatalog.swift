//
//  PlanetNameCatalog.swift
//  todoTask
//

import Foundation

enum PlanetNameCatalog {
    struct Pair: Equatable {
        let en: String
        let ar: String
    }

    static let all: [Pair] = [
        Pair(en: "Zephyria", ar: "زيفيريا"),
        Pair(en: "Neptara", ar: "نيبتارا"),
        Pair(en: "Cronas", ar: "كروناس"),
        Pair(en: "Velax", ar: "فيلاكس"),
        Pair(en: "Azoria", ar: "أزوريا"),
        Pair(en: "Themyra", ar: "ثيميرا")
    ]

    static func random() -> Pair {
        all.randomElement() ?? all[0]
    }

    static func pair(matching stored: String) -> Pair? {
        all.first { $0.en == stored || $0.ar == stored }
    }

    static func localized(_ stored: String, language: AppLanguage) -> String {
        guard let pair = pair(matching: stored) else { return stored }
        return language == .arabic ? pair.ar : pair.en
    }

    static func display(
        en: String?,
        ar: String?,
        fallback: String,
        language: AppLanguage
    ) -> String {
        switch language {
        case .english:
            if let en, !en.isEmpty { return en }
            return localized(fallback, language: .english)
        case .arabic:
            if let ar, !ar.isEmpty { return ar }
            return localized(fallback, language: .arabic)
        }
    }
}

extension ChallengeRoom {
    func localizedPlanetName(language: AppLanguage) -> String {
        PlanetNameCatalog.display(
            en: planetNameEn,
            ar: planetNameAr,
            fallback: planetName,
            language: language
        )
    }
}

extension ChallengeWinner {
    func localizedPlanetName(language: AppLanguage) -> String {
        PlanetNameCatalog.display(
            en: planetNameEn,
            ar: planetNameAr,
            fallback: planetName,
            language: language
        )
    }
}

extension WonPlanetRecord {
    func displayName(language: AppLanguage) -> String {
        PlanetNameCatalog.display(
            en: planetNameEn,
            ar: planetNameAr,
            fallback: planetName,
            language: language
        )
    }
}
