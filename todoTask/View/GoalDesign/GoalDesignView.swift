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
    @State private var totalTasks: Int = 10
    @State private var vm = GoalDesignViewModel()
    @State private var showAddColorPicker = false
    @State private var pickerColor = Color.cyan
    @State private var commitPickerColor = false

    let onSaveDesign: ((OrbDesign) -> Void)?

    init(onSaveDesign: ((OrbDesign) -> Void)? = nil) {
        self.onSaveDesign = onSaveDesign
    }

    var body: some View {
        GoalFlowScreen(
            background: { AppBackground() },
            topBar: {
                GoalFlowTitleBar(
                    title: lang.t(.designYourOrb),
                    onBack: { dismiss() },
                    onNext: { saveGoal() }
                )
            },
            content: {
                ScrollView(showsIndicators: false) {
                    GoalCreationStepIndicator(current: 4)
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                        .padding(.bottom, 8)

                    GeometryReader { proxy in
                        Color.clear
                            .preference(
                                key: ScrollOffsetKey.self,
                                value: proxy.frame(in: .named("scroll")).minY
                            )
                    }
                    .frame(height: 0)

                    PlanetOrbView(
                        size: 180,
                        gradientColors: vm.gradientStops,
                        glow: vm.glow,
                        textureAssetName: vm.selectedEffectAsset,
                        textureOpacity: vm.textureOpacity
                    )
                    .padding(.top, 0)
                    .padding(.bottom, 10)

                    GlassCard {
                        VStack(alignment: .leading, spacing: 18) {
                            SectionHeader(title: lang.t(.planetColors))
                                .padding(.top, -20)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(vm.gradientStops.indices, id: \.self) { i in
                                        ColorStopSwatch(color: vm.gradientStops[i]) {
                                            vm.deleteStop(at: i)
                                        }
                                    }
                                    Button {
                                        pickerColor = vm.gradientStops.last ?? .cyan
                                        showAddColorPicker = true
                                    } label: {
                                        ZStack {
                                            Circle().fill(Color.white.opacity(0.08))
                                            Image(systemName: "plus")
                                                .font(.system(size: 18, weight: .semibold))
                                                .foregroundStyle(.white.opacity(0.9))
                                        }
                                        .frame(width: 44, height: 44)
                                    }
                                }
                            }

                            SectionHeader(title: lang.t(.glow))
                            HStack {
                                Image(systemName: "sun.min").foregroundStyle(.white.opacity(0.7))
                                Slider(value: $vm.glow, in: 0...0.15)
                                Image(systemName: "sun.max.fill").foregroundStyle(.white.opacity(0.85))
                            }

                            SectionHeader(title: lang.t(.effect))
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(Array(vm.effects.enumerated()), id: \.offset) { i, asset in
                                        EffectThumb(assetName: asset, isSelected: i == vm.selectedEffectIndex)
                                            .onTapGesture { vm.selectEffect(i) }
                                    }
                                }
                                .padding(.vertical, 2)
                            }

                            HStack {
                                Text(lang.t(.intensity))
                                    .foregroundStyle(.white.opacity(0.75))
                                    .font(.system(size: 14, weight: .medium))
                                Slider(value: $vm.textureOpacity, in: 0...1)
                            }
                            .padding(.top, 6)
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 6)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(ScrollOffsetKey.self) { value in
                    vm.scrollY = value
                }
            }
        )
        .sheet(isPresented: $showAddColorPicker) {
            PlanetColorPickerSheet(
                color: $pickerColor,
                title: lang.t(.planetColors),
                addTitle: lang.t(.save),
                cancelTitle: lang.t(.cancel),
                onAdd: {
                    vm.appendStop(pickerColor)
                    showAddColorPicker = false
                },
                onCancel: {
                    showAddColorPicker = false
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

#Preview {
    GoalDesign()
}
