//
//  GoalDesignViewModel.swift
//  OrbitDemo
//
//  Created by Ruba Alghamdi on 07/02/2026.
//

import SwiftUI
import Observation

@Observable
final class GoalDesignViewModel {

    // Controls
    var glow: Double = 0.12
    var textureOpacity: Double = 0.85

    // Colors
    var gradientStops: [Color] = PlanetDesignPresets.defaultStops

    // Effects
    let effects: [String] = PlanetDesignPresets.effects
    var selectedEffectIndex: Int = 0

    // Scroll tracking (if you use it later)
    var scrollY: CGFloat = 0

    // Keep your type if it exists in project
    var selectedGoal: GoalType?

    // Safe selected effect
    var selectedEffectAsset: String? {
        effects[safe: selectedEffectIndex]
    }

    // Actions
    func addStop() {
        withAnimation(.easeInOut) {
            gradientStops.append(.purple)
        }
    }

    func deleteStop(at index: Int) {
        guard gradientStops.count > 2 else { return }
        guard gradientStops.indices.contains(index) else { return }
        withAnimation(.easeInOut) {
            gradientStops.remove(at: index)
        }
    }

    func selectEffect(_ index: Int) {
        guard effects.indices.contains(index) else { return }
        withAnimation(.easeInOut) {
            selectedEffectIndex = index
        }
    }
}

// MARK: - Safe index helper
private extension Array {
    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}
