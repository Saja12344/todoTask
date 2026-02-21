//
//  GoalDesignView.swift
//  OrbitDemo
//
//  Created by Ruba Alghamdi on 07/02/2026.
//

import SwiftUI

struct GoalDesign: View {
    @EnvironmentObject private var store: OrbGoalStore
    @Environment(\.dismiss) private var dismiss
    @State private var goalTitle: String = ""
    @State private var totalTasks: Int = 10

    @State private var vm = GoalDesignViewModel()

    // Optional callback for flow-managed save
    let onSaveDesign: ((OrbDesign) -> Void)?

    // Backward-compatible init: default nil keeps old usages working
    init(onSaveDesign: ((OrbDesign) -> Void)? = nil) {
        self.onSaveDesign = onSaveDesign
    }

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                AppNavigationBar(
                    title: "Design Your Orb",
                    onBack: { dismiss() },
                    onNext: { saveGoal() }
                )


                ZStack(alignment: .top) {

                    // ===== ORB behind =====
                    VStack(spacing: 0) {
                        PlanetOrbView(
                            size: 180,
                            gradientColors: vm.gradientStops,
                            glow: vm.glow,
                            textureAssetName: vm.selectedEffectAsset,
                            textureOpacity: vm.textureOpacity
                        )
                        .padding(.top, 40)
                        .offset(y: -80)
                        .padding(.bottom, 30)

                        Spacer().frame(height: 180)
                    }

                    // ===== SCROLL content =====
                    ScrollView(showsIndicators: false) {

                        GeometryReader { proxy in
                            Color.clear
                                .preference(
                                    key: ScrollOffsetKey.self,
                                    value: proxy.frame(in: .named("scroll")).minY
                                )
                        }
                        .frame(height: 0)

                        Spacer().frame(height: 270)

                        GlassCard {

                            VStack(alignment: .leading, spacing: 18) {

                                // MARK: - Planet Colors
                                SectionHeader(title: "Planet Colors")
                                    .padding(.top, -20)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(vm.gradientStops.indices, id: \.self) { i in
                                            GradientStopDot(color: $vm.gradientStops[i]) {
                                                vm.deleteStop(at: i)
                                            }
                                        }

                                        Button {
                                            vm.addStop()
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

                                // MARK: - Glow
                                SectionHeader(title: "Glow")
                                HStack {
                                    Image(systemName: "sun.min")
                                        .foregroundStyle(.white.opacity(0.7))

                                    Slider(value: $vm.glow, in: 0...0.15)

                                    Image(systemName: "sun.max.fill")
                                        .foregroundStyle(.white.opacity(0.85))
                                }

                                // MARK: - Effect
                                SectionHeader(title: "Effect")

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
                                    Text("Intensity")
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

                        Spacer().frame(height: 200)
                    }
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ScrollOffsetKey.self) { value in
                        vm.scrollY = value
                    }
                }
            }
        }.toolbar(.hidden, for: .tabBar)
    }
    private func saveGoal() {
        let design = OrbDesign(
            glow: vm.glow,
            textureOpacity: vm.textureOpacity,
            textureAssetName: vm.selectedEffectAsset,
            gradientStops: vm.gradientStops.map { RGBAColor.from($0) }
        )

        if let onSaveDesign {
            // Flow-managed save: pass design up
            onSaveDesign(design)
            return
        }

        // Backward compatibility: if used standalone, still save goal here
        let title = goalTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let safeTitle = title.isEmpty ? "New Goal" : title

        let goal = OrbGoal(
            id: UUID(),
            title: safeTitle,
            totalTasks: max(1, totalTasks),
            doneTasks: 0,
            design: design
        )

        store.add(goal)
        dismiss()
    }
        
}

// Preview
struct GoalDesign_Previews: PreviewProvider {
    static var previews: some View {
        GoalDesign()
            .environmentObject(OrbGoalStore())
    }
}
