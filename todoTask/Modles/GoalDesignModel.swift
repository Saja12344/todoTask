//
//  GoalDesignModel.swift
//  OrbitDemo
//
//  Created by Ruba Alghamdi on 07/02/2026.
//

import SwiftUI

// MARK: - Presets for GoalDesign
public enum PlanetDesignPresets {

    // Default gradient stops
    public static let defaultStops: [Color] = [
        Color(red: 0.16, green: 0.26, blue: 0.95),
        Color(red: 0.60, green: 0.50, blue: 0.98),
        Color(red: 0.93, green: 0.30, blue: 0.96)
    ]

    // Effects in Assets: effect1 ... effect10
    public static let effects: [String] = (1...10).map { "effect\($0)" }
}
