//
//  GoalDesignView.swift
//  OrbitDemo
//

import SwiftUI

struct GoalDesign: View {
    @EnvironmentObject private var store: OrbGoalStore
    @Environment(\.dismiss) private var dismiss
    @State private var goalTitle: String = ""
    @State private var totalTasks: Int = 10
    @State private var vm = GoalDesignViewModel()

    let onSaveDesign: ((OrbDesign) -> Void)?

    init(onSaveDesign: ((OrbDesign) -> Void)? = nil) {
        self.onSaveDesign = onSaveDesign
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(LinearGradient(colors: [.darkBlu, .dark], startPoint: .bottom, endPoint: .top))
                .ignoresSafeArea()
            Image("Background 2")
                .resizable()
                .ignoresSafeArea()
                .opacity(0.7)
            
            Image("Gliter")
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                AppNavigationBar(
                    title: "Design Your Orb",
                    onBack: { dismiss() },
                    onNext: { saveGoal() }
                )
                .padding(.top, 30)
                ZStack(alignment: .top) {
                    // Top area with the orb
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

                    // Fixed GlassCard (no scrolling)
                    GlassCard {
                        VStack(alignment: .leading, spacing: 18) {
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

                            SectionHeader(title: "Glow")
                            HStack {
                                Image(systemName: "sun.min").foregroundStyle(.white.opacity(0.7))
                                Slider(value: $vm.glow, in: 0...0.15)
                                Image(systemName: "sun.max.fill").foregroundStyle(.white.opacity(0.85))
                            }

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
                    .padding(.top, 270)   // keep it visually in the same place below the orb
                    .padding(.bottom, 40)

                    // Optional: If you had additional content that must scroll below,
                    // you can keep a ScrollView for that content only. For now, we remove it
                    // since the GlassCard is fixed and there’s no other scrollable section shown.
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
    }

    private func saveGoal() {
        print("✅ saveGoal called")

        let design = OrbDesign(
            glow: vm.glow,
            textureOpacity: vm.textureOpacity,
            textureAssetName: vm.selectedEffectAsset,
            gradientStops: vm.gradientStops.map { RGBAColor.from($0) }
        )

        if let onSaveDesign {
            print("✅ onSaveDesign exists - calling callback")
            onSaveDesign(design)
            return
        }

        print("⚠️ onSaveDesign is nil - saving standalone")
        let title = goalTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let safeTitle = title.isEmpty ? "New Goal" : title

        let goal = OrbGoal(
            id: UUID(),
            title: safeTitle,
            design: design
        )

        store.add(goal)
        dismiss()
    }
}


#Preview {
    GoalDesign()
}
