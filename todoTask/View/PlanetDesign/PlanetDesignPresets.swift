
import SwiftUI

// MARK: - Presets for GoalDesign

public enum PlanetDesignPresets {
    // Default gradient stops (you can change these anytime)
    public static let defaultStops: [Color] = [
        Color(red: 0.16, green: 0.26, blue: 0.95),
        Color(red: 0.60, green: 0.50, blue: 0.98),
        Color(red: 0.93, green: 0.30, blue: 0.96)
    ]

    // Your 10 effects in Assets: effect1 ... effect10
    public static let effects: [String] = (1...10).map { "effect\($0)" }
}
