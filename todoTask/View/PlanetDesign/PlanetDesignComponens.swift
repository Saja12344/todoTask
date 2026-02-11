
import SwiftUI

// MARK: - Track scroll offset
public struct ScrollOffsetKey: PreferenceKey {
    public static var defaultValue: CGFloat = 0
    public static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Gradient Stop Dot (tap to edit, long-press to delete)
public struct GradientStopDot: View {
    @Binding var color: Color
    var onDelete: () -> Void

    public init(color: Binding<Color>, onDelete: @escaping () -> Void) {
        self._color = color
        self.onDelete = onDelete
    }

    public var body: some View {
        ZStack {
            // Clean dot (no icon)
            Circle()
                .fill(color)
                .frame(width: 44, height: 44)
                .overlay(
                    Circle().stroke(Color.white.opacity(0.20), lineWidth: 1)
                )

            // Invisible ColorPicker (still opens on tap)
            ColorPicker("", selection: $color)
                .labelsHidden()
                .opacity(0.02)
                .frame(width: 44, height: 44)
                .contentShape(Circle())
        }
        .contextMenu {
            Button(role: .destructive) { onDelete() } label: {
                Label("Delete Color", systemImage: "trash")
            }
        }
    }
}

// MARK: - Effect thumb (shows the PNG itself)
public struct EffectThumb: View {
    let assetName: String
    let isSelected: Bool

    public init(assetName: String, isSelected: Bool) {
        self.assetName = assetName
        self.isSelected = isSelected
    }

    public var body: some View {
        Image(assetName)
            .resizable()
            .scaledToFill()
            .frame(width: 46, height: 46)
            .clipShape(Circle())
            .overlay(
                Circle().stroke(
                    isSelected ? Color.white.opacity(0.85) : Color.white.opacity(0.15),
                    lineWidth: isSelected ? 2 : 1
                )
            )
            .shadow(color: .black.opacity(0.22), radius: 6, x: 0, y: 3)
    }
}

// MARK: - Orb renderer (Glow matches FIRST gradient stop + effects Hard Light)
public struct PlanetOrbView: View {
    let size: CGFloat
    let gradientColors: [Color]
    let glow: Double                  // 0... (you used 0...0.25)
    let textureAssetName: String?     // "effect1"... etc
    let textureOpacity: Double        // 0...1

    public init(
        size: CGFloat,
        gradientColors: [Color],
        glow: Double,
        textureAssetName: String?,
        textureOpacity: Double
    ) {
        self.size = size
        self.gradientColors = gradientColors
        self.glow = glow
        self.textureAssetName = textureAssetName
        self.textureOpacity = textureOpacity
    }

    private var glowColor: Color { gradientColors.first ?? .purple }
    private var glowSpread: CGFloat { 40 + CGFloat(glow) * 280 } // scaled for 0...0.25 range
    private var auraBlur: CGFloat { 18 + CGFloat(glow) * 120 }
    private var shadowRadius: CGFloat { 10 + CGFloat(glow) * 160 }

    public var body: some View {
        ZStack {
            // OUTER AURA (bigger than orb -> never clipped)
            Circle()
                .fill(glowColor.opacity(0.10 + glow * 1.1))
                .frame(width: size + glowSpread, height: size + glowSpread)
                .blur(radius: auraBlur)

            // MAIN ORB
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: gradientColors.count >= 2 ? gradientColors : [glowColor, glowColor.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                // Sphere depth highlight
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.white.opacity(0.25), .clear],
                            center: .topLeading,
                            startRadius: 10,
                            endRadius: size * 0.6
                        )
                    )
                    .blendMode(.softLight)

                // Effect PNG (ALWAYS hard light)
                if let textureAssetName {
                    Image(textureAssetName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
                        .clipShape(Circle())
                        .blendMode(.hardLight)
                        .opacity(textureOpacity)
                }

                // Edge glow ring tinted by first stop
                Circle()
                    .stroke(glowColor.opacity(0.18 + glow * 1.2), lineWidth: 2)
                    .blur(radius: 8 + glow * 80)
            }
            .frame(width: size, height: size)
            .shadow(
                color: glowColor.opacity(0.15 + glow * 2.0),
                radius: shadowRadius,
                x: 0,
                y: 0
            )
        }
        // EXTRA canvas so glow isn't cropped by parent frames/cards
        .frame(width: size + 160, height: size + 160)
        .drawingGroup()
    }
}
