//
//  GoalDesignComponents.swift
//  OrbitDemo
//

import SwiftUI

// MARK: - Track scroll offset
public struct ScrollOffsetKey: PreferenceKey {
    public static var defaultValue: CGFloat = 0
    public static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Color swatch (display only — picker opens from + button)
public struct ColorStopSwatch: View {
    let color: Color
    var onDelete: () -> Void

    public var body: some View {
        Circle()
            .fill(color)
            .frame(width: 44, height: 44)
            .contextMenu {
                Button(role: .destructive, action: onDelete) {
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
    let glow: Double
    let textureAssetName: String?
    let textureOpacity: Double

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

    public var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [glowColor.opacity(glow * 2.5), glowColor.opacity(0)],
                        center: .center,
                        startRadius: size * 0.2,
                        endRadius: size * 0.65
                    )
                )
                .frame(width: size * 1.3, height: size * 1.3)

            Circle()
                .fill(
                    AngularGradient(
                        gradient: Gradient(
                            colors: gradientColors.count >= 2
                            ? gradientColors
                            : [glowColor, glowColor.opacity(0.7)]
                        ),
                        center: .center
                    )
                )
                .frame(width: size, height: size)
                .overlay(
                    Group {
                        if let name = textureAssetName {
                            Image(name)
                                .resizable()
                                .scaledToFill()
                                .frame(width: size, height: size)
                                .clipShape(Circle())
                                .opacity(textureOpacity)
                                .blendMode(.hardLight)
                        }
                    }
                )
                .shadow(color: glowColor.opacity(0.35), radius: 18, x: 0, y: 8)
        }
    }
}
