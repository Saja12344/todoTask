
import SwiftUI

struct GoalDesign: View {

    @State private var glow: Double = 0.12
    @State private var textureOpacity: Double = 0.85

    @State private var gradientStops: [Color] = PlanetDesignPresets.defaultStops

    private let effects: [String] = PlanetDesignPresets.effects
    @State private var selectedEffectIndex: Int = 0

    @State private var scrollY: CGFloat = 0

    // Keep your type if it exists (or delete this line if unused)
    @State private var selectedGoal: GoalType?

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                AppNavigationBar(
                    title: "Design Your Orb",
                    onBack: {},
                    onNext: {}
                )

                ZStack(alignment: .top) {

                    // ===== ORB behind =====
                    VStack(spacing: 0) {
                        PlanetOrbView(
                            size: 180,
                            gradientColors: gradientStops,
                            glow: glow,
                            textureAssetName: effects[safe: selectedEffectIndex],
                            textureOpacity: textureOpacity
                        )
                        // (Edit 1) lifted up a little:
                        .padding(.top, 40)
                        .offset(y: -12)          // <- lift
                        .padding(.bottom, 30)

                        // Space so scrolling content can pass the orb area
                        Spacer().frame(height: 180)
                    }

                    // ===== SCROLL content =====
                    ScrollView(showsIndicators: false) {

                        // Track scroll offset
                        GeometryReader { proxy in
                            Color.clear
                                .preference(
                                    key: ScrollOffsetKey.self,
                                    value: proxy.frame(in: .named("scroll")).minY
                                )
                        }
                        .frame(height: 0)

                        // Start the card below the orb
                        Spacer().frame(height: 220)

                        // CARD
                        GlassCard {
                            VStack(alignment: .leading, spacing: 18) {

                                // MARK: - Planet Colors
                                SectionHeader(title: "Planet Colors")

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(gradientStops.indices, id: \.self) { i in
                                            GradientStopDot(color: $gradientStops[i]) {
                                                guard gradientStops.count > 2 else { return }
                                                withAnimation(.easeInOut) {
                                                    gradientStops.remove(at: i)
                                                }
                                            }
                                        }

                                        // Add stop
                                        Button {
                                            withAnimation(.easeInOut) {
                                                gradientStops.append(.purple)
                                            }
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

                                    Slider(value: $glow, in: 0...0.25)

                                    Image(systemName: "sun.max.fill")
                                        .foregroundStyle(.white.opacity(0.85))
                                }

                                // MARK: - Effect (uses PNG thumbnails)
                                SectionHeader(title: "Effect")

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(Array(effects.enumerated()), id: \.offset) { i, asset in
                                            EffectThumb(assetName: asset, isSelected: i == selectedEffectIndex)
                                                .onTapGesture {
                                                    withAnimation(.easeInOut) {
                                                        selectedEffectIndex = i
                                                    }
                                                }
                                        }
                                    }
                                    .padding(.vertical, 2)
                                }

                                // Effect intensity
                                HStack {
                                    Text("Intensity")
                                        .foregroundStyle(.white.opacity(0.75))
                                        .font(.system(size: 14, weight: .medium))

                                    Slider(value: $textureOpacity, in: 0...1)
                                }
                                .padding(.top, 6)
                            }
                            .padding(.vertical, 6)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 40)

                        Spacer().frame(height: 200)
                    }
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ScrollOffsetKey.self) { value in
                        scrollY = value
                    }
                }
            }
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

// Preview
struct GoalDesign_Previews: PreviewProvider {
    static var previews: some View {
        GoalDesign()
    }
}
