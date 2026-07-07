//
//  GoalDesignModel.swift
//  OrbitDemo
//

import SwiftUI

// MARK: - Presets for GoalDesign
public enum PlanetDesignPresets {

    public static let defaultStops: [Color] = OrbPalettePreset.nebula.colors

    public static let effects: [String] = (1...10).map { "effect\($0)" }

    public static let maxGradientStops = 8
}

// MARK: - Curated orb palettes
public struct OrbPalettePreset: Identifiable, Equatable {
    public let id: String
    public let nameEN: String
    public let nameAR: String
    public let colors: [Color]
    public let glow: Double
    public let effectIndex: Int

    func name(for language: AppLanguage) -> String {
        language == .arabic ? nameAR : nameEN
    }

    public static let all: [OrbPalettePreset] = [
        nebula, aurora, sunset, ocean, ember, cosmic, rose, midnight
    ]

    public static let nebula = OrbPalettePreset(
        id: "nebula",
        nameEN: "Nebula",
        nameAR: "سديم",
        colors: [
            Color(red: 0.16, green: 0.26, blue: 0.95),
            Color(red: 0.60, green: 0.50, blue: 0.98),
            Color(red: 0.93, green: 0.30, blue: 0.96)
        ],
        glow: 0.12,
        effectIndex: 2
    )

    public static let aurora = OrbPalettePreset(
        id: "aurora",
        nameEN: "Aurora",
        nameAR: "شفق",
        colors: [
            Color(red: 0.10, green: 0.85, blue: 0.72),
            Color(red: 0.22, green: 0.55, blue: 0.98),
            Color(red: 0.58, green: 0.28, blue: 0.96)
        ],
        glow: 0.14,
        effectIndex: 4
    )

    public static let sunset = OrbPalettePreset(
        id: "sunset",
        nameEN: "Sunset",
        nameAR: "غروب",
        colors: [
            Color(red: 1.00, green: 0.45, blue: 0.18),
            Color(red: 0.98, green: 0.22, blue: 0.45),
            Color(red: 0.55, green: 0.12, blue: 0.62)
        ],
        glow: 0.13,
        effectIndex: 6
    )

    public static let ocean = OrbPalettePreset(
        id: "ocean",
        nameEN: "Ocean",
        nameAR: "محيط",
        colors: [
            Color(red: 0.04, green: 0.35, blue: 0.62),
            Color(red: 0.10, green: 0.62, blue: 0.78),
            Color(red: 0.40, green: 0.88, blue: 0.92)
        ],
        glow: 0.10,
        effectIndex: 1
    )

    public static let ember = OrbPalettePreset(
        id: "ember",
        nameEN: "Ember",
        nameAR: "جمر",
        colors: [
            Color(red: 0.95, green: 0.28, blue: 0.12),
            Color(red: 0.88, green: 0.52, blue: 0.08),
            Color(red: 0.62, green: 0.10, blue: 0.18)
        ],
        glow: 0.11,
        effectIndex: 7
    )

    public static let cosmic = OrbPalettePreset(
        id: "cosmic",
        nameEN: "Cosmic",
        nameAR: "كوني",
        colors: [
            Color(red: 0.08, green: 0.10, blue: 0.28),
            Color(red: 0.35, green: 0.18, blue: 0.72),
            Color(red: 0.68, green: 0.42, blue: 1.00)
        ],
        glow: 0.15,
        effectIndex: 3
    )

    public static let rose = OrbPalettePreset(
        id: "rose",
        nameEN: "Rose",
        nameAR: "وردي",
        colors: [
            Color(red: 0.98, green: 0.55, blue: 0.72),
            Color(red: 0.82, green: 0.28, blue: 0.58),
            Color(red: 0.48, green: 0.12, blue: 0.52)
        ],
        glow: 0.12,
        effectIndex: 5
    )

    public static let midnight = OrbPalettePreset(
        id: "midnight",
        nameEN: "Midnight",
        nameAR: "منتصف الليل",
        colors: [
            Color(red: 0.05, green: 0.08, blue: 0.18),
            Color(red: 0.18, green: 0.28, blue: 0.55),
            Color(red: 0.42, green: 0.55, blue: 0.88)
        ],
        glow: 0.09,
        effectIndex: 0
    )
}

// MARK: - Quick hue picks for inline editing
public enum OrbQuickHues {
    public static let colors: [Color] = [
        Color(red: 0.98, green: 0.28, blue: 0.32),
        Color(red: 1.00, green: 0.52, blue: 0.12),
        Color(red: 1.00, green: 0.82, blue: 0.18),
        Color(red: 0.42, green: 0.88, blue: 0.38),
        Color(red: 0.12, green: 0.82, blue: 0.72),
        Color(red: 0.20, green: 0.62, blue: 0.98),
        Color(red: 0.38, green: 0.34, blue: 0.98),
        Color(red: 0.72, green: 0.28, blue: 0.96),
        Color(red: 0.96, green: 0.34, blue: 0.72),
        Color(red: 0.92, green: 0.92, blue: 0.96),
        Color(red: 0.55, green: 0.58, blue: 0.68),
        Color(red: 0.12, green: 0.14, blue: 0.22)
    ]
}
