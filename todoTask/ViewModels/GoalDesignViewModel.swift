//
//  GoalDesignViewModel.swift
//  OrbitDemo
//

import SwiftUI
import Observation

@Observable
final class GoalDesignViewModel {

    var glow: Double = 0.12
    var textureOpacity: Double = 0.85

    var gradientStops: [Color] = PlanetDesignPresets.defaultStops
    var selectedStopIndex: Int = 0
    var activePresetID: String? = OrbPalettePreset.nebula.id

    let effects: [String] = PlanetDesignPresets.effects
    var selectedEffectIndex: Int = 2

    var scrollY: CGFloat = 0
    var selectedGoal: GoalType?

    var selectedEffectAsset: String? {
        effects[safe: selectedEffectIndex]
    }

    var canAddStop: Bool {
        gradientStops.count < PlanetDesignPresets.maxGradientStops
    }

    var selectedStopColor: Color {
        get { gradientStops[safe: selectedStopIndex] ?? gradientStops.first ?? .cyan }
        set { updateStop(at: selectedStopIndex, color: newValue) }
    }

    func applyPreset(_ preset: OrbPalettePreset) {
        withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) {
            gradientStops = preset.colors
            glow = preset.glow
            selectedEffectIndex = preset.effectIndex
            activePresetID = preset.id
            selectedStopIndex = 0
        }
    }

    func selectStop(at index: Int) {
        guard gradientStops.indices.contains(index) else { return }
        withAnimation(.easeInOut(duration: 0.18)) {
            selectedStopIndex = index
            activePresetID = nil
        }
    }

    func updateStop(at index: Int, color: Color) {
        guard gradientStops.indices.contains(index) else { return }
        withAnimation(.easeInOut(duration: 0.18)) {
            gradientStops[index] = color
            activePresetID = nil
        }
    }

    func appendStop(_ color: Color) {
        guard canAddStop else { return }
        withAnimation(.spring(response: 0.34, dampingFraction: 0.82)) {
            gradientStops.append(color)
            selectedStopIndex = gradientStops.count - 1
            activePresetID = nil
        }
    }

    func deleteStop(at index: Int) {
        guard gradientStops.count > 2 else { return }
        guard gradientStops.indices.contains(index) else { return }
        withAnimation(.easeInOut(duration: 0.22)) {
            gradientStops.remove(at: index)
            selectedStopIndex = min(selectedStopIndex, gradientStops.count - 1)
            activePresetID = nil
        }
    }

    func selectEffect(_ index: Int) {
        guard effects.indices.contains(index) else { return }
        withAnimation(.easeInOut) {
            selectedEffectIndex = index
            activePresetID = nil
        }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}
