//
//  GoalDesignView.swift
//  OrbitDemo
//

import SwiftUI

struct GoalDesign: View {
    @EnvironmentObject private var store: OrbGoalStore
    @EnvironmentObject private var lang: LanguageManager
    @Environment(\.dismiss) private var dismiss
    @State private var goalTitle: String = ""
    @State private var vm = GoalDesignViewModel()
    @State private var showCustomColorPicker = false
    @State private var pickerColor = Color.cyan
    @State private var addingNewStop = false

    let onSaveDesign: ((OrbDesign) -> Void)?

    init(onSaveDesign: ((OrbDesign) -> Void)? = nil) {
        self.onSaveDesign = onSaveDesign
    }

    var body: some View {
        GoalFlowScreen(
            background: { AppBackground() },
            topBar: {
                HStack {
                    GoalFlowBackButton(action: { dismiss() })
                    Spacer()
                    GoalFlowCheckButton(isEnabled: true, action: saveGoal)
                }
            },
            content: {
                GeometryReader { geo in
                    VStack(spacing: 0) {
                        Spacer(minLength: max(8, geo.size.height * 0.04))

                        OrbPreviewStage(
                            size: min(200, geo.size.width * 0.48),
                            gradientColors: vm.gradientStops,
                            glow: vm.glow,
                            textureAssetName: vm.selectedEffectAsset,
                            textureOpacity: vm.textureOpacity
                        )
                        .frame(maxWidth: .infinity)

                        Spacer(minLength: 12)

                        OrbDesignControlPanel(
                            stops: vm.gradientStops,
                            selectedStopIndex: vm.selectedStopIndex,
                            canAddStop: vm.canAddStop,
                            glow: $vm.glow,
                            effects: vm.effects,
                            selectedEffectIndex: vm.selectedEffectIndex,
                            textureOpacity: vm.textureOpacity,
                            onSelectStop: { vm.selectStop(at: $0) },
                            onEditStop: {
                                pickerColor = vm.selectedStopColor
                                addingNewStop = false
                                showCustomColorPicker = true
                            },
                            onDeleteStop: { vm.deleteStop(at: $0) },
                            onAddStop: {
                                pickerColor = vm.selectedStopColor
                                addingNewStop = true
                                showCustomColorPicker = true
                            },
                            onSelectEffect: { vm.selectEffect($0) }
                        )
                        .padding(.horizontal, GoalFlowLayout.horizontalPadding)
                        .padding(.bottom, 12)
                    }
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
                }
            }
        )
        .sheet(isPresented: $showCustomColorPicker) {
            PlanetColorPickerSheet(
                color: $pickerColor,
                previewColors: vm.gradientStops,
                title: lang.t(.customColor),
                addTitle: lang.t(.save),
                cancelTitle: lang.t(.cancel),
                onAdd: {
                    if addingNewStop {
                        vm.appendStop(pickerColor)
                    } else {
                        vm.selectedStopColor = pickerColor
                    }
                    addingNewStop = false
                    showCustomColorPicker = false
                },
                onCancel: {
                    addingNewStop = false
                    showCustomColorPicker = false
                }
            )
        }
        .orbitForcedDark()
    }

    private func saveGoal() {
        let design = OrbDesign(
            glow: vm.glow,
            textureOpacity: vm.textureOpacity,
            textureAssetName: vm.selectedEffectAsset,
            gradientStops: vm.gradientStops.map { RGBAColor.from($0) }
        )

        if let onSaveDesign {
            onSaveDesign(design)
            return
        }

        let title = goalTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let safeTitle = title.isEmpty ? "New Goal" : title
        let goal = OrbGoal(id: UUID(), title: safeTitle, design: design)
        store.add(goal)
        dismiss()
    }
}

// MARK: - Hero orb preview
private struct OrbPreviewStage: View {
    let size: CGFloat
    let gradientColors: [Color]
    let glow: Double
    let textureAssetName: String?
    let textureOpacity: Double

    private var accent: Color { gradientColors.first ?? Color("accent") }

    private var glowStrength: Double { min(max(glow / 0.15, 0), 1) }

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            accent.opacity(0.10 + glowStrength * 0.45),
                            accent.opacity(0.04 + glowStrength * 0.12),
                            .clear
                        ],
                        center: .center,
                        startRadius: size * 0.10,
                        endRadius: size * (0.75 + glowStrength * 0.45)
                    )
                )
                .frame(width: size * (1.5 + glowStrength * 0.9), height: size * (1.5 + glowStrength * 0.9))
                .blur(radius: 8 + glowStrength * 18)

            PlanetOrbView(
                size: size,
                gradientColors: gradientColors,
                glow: glow,
                textureAssetName: textureAssetName,
                textureOpacity: textureOpacity,
                autoSpin: true
            )
            .shadow(color: accent.opacity(0.25 + glowStrength * 0.5), radius: 18 + glowStrength * 40, y: 14)
        }
        .frame(width: size * 1.85, height: size * 1.85)
    }
}

#Preview {
    GoalDesign()
        .environmentObject(LanguageManager())
}
