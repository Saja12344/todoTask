//
//  PlanetColorPickerSheet.swift
//  todoTask
//

import SwiftUI

struct PlanetColorPickerSheet: View {
    @EnvironmentObject private var lang: LanguageManager

    @Binding var color: Color
    var previewColors: [Color] = []
    let title: String
    let addTitle: String
    let cancelTitle: String
    let onAdd: () -> Void
    let onCancel: () -> Void

    @State private var previewPulse = false

    private var accent: Color { color }

    var body: some View {
        ZStack {
            Color.darkBlu.ignoresSafeArea()
            StarsBackgroundView()
                .opacity(0.55)

            RadialGradient(
                colors: [accent.opacity(0.18), .clear],
                center: .top,
                startRadius: 20,
                endRadius: 320
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack(spacing: 0) {
                sheetHeader

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        previewSection
                        pickerGlassPanel
                        OrbNebulaQuickHues(color: $color)
                        OrbCosmicSeedRow(color: $color)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 28)
                }
            }
        }
        .orbitForcedDark()
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color.darkBlu.opacity(0.96))
        .onAppear { previewPulse = true }
    }

    // MARK: - Header

    private var sheetHeader: some View {
        HStack {
            Button(action: onCancel) {
                Text(cancelTitle)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white.opacity(0.72))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background {
                        Capsule()
                            .fill(.white.opacity(0.08))
                            .glassEffect(.clear, in: .capsule)
                    }
            }
            .buttonStyle(.plain)

            Spacer()

            VStack(spacing: 2) {
                Text(lang.t(.colorStudio))
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.45))
                    .textCase(.uppercase)
                    .tracking(1.2)
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white.opacity(0.92))
            }

            Spacer()

            Button(action: onAdd) {
                Text(addTitle)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [accent, accent.opacity(0.65)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: accent.opacity(0.45), radius: 8, y: 3)
                    }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    // MARK: - Preview

    private var previewSection: some View {
        HStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [accent.opacity(0.35), accent.opacity(0.05), .clear],
                            center: .center,
                            startRadius: 8,
                            endRadius: 72
                        )
                    )
                    .frame(width: 140, height: 140)
                    .blur(radius: 6)
                    .scaleEffect(previewPulse ? 1.04 : 0.96)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: previewPulse)

                PlanetOrbView(
                    size: 88,
                    gradientColors: previewColors.isEmpty ? [color, color.opacity(0.6)] : previewColors,
                    glow: 0.14,
                    textureAssetName: nil,
                    textureOpacity: 0,
                    autoSpin: true
                )
                .shadow(color: accent.opacity(0.55), radius: 20, y: 8)
            }
            .frame(width: 120, height: 120)

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Text(lang.t(.orbitHue))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.55))

                    Spacer(minLength: 0)

                    Text(hexString)
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background {
                            Capsule()
                                .fill(.white.opacity(0.08))
                                .glassEffect(.clear.tint(accent.opacity(0.18)), in: .capsule)
                        }
                        .overlay {
                            Capsule().stroke(.white.opacity(0.12), lineWidth: 1)
                        }
                }

                HStack(spacing: 6) {
                    ForEach(Array((previewColors.isEmpty ? [color] : previewColors).enumerated()), id: \.offset) { _, stop in
                        Circle()
                            .fill(stop)
                            .frame(width: 22, height: 22)
                            .overlay {
                                if colorsMatch(stop, color) {
                                    Circle()
                                        .stroke(.white, lineWidth: 2)
                                        .shadow(color: stop.opacity(0.6), radius: 4)
                                }
                            }
                            .scaleEffect(colorsMatch(stop, color) ? 1.12 : 1)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: color)
                    }
                }

                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: previewColors.isEmpty ? [color, color.opacity(0.5)] : previewColors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 10)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(.white.opacity(0.15), lineWidth: 1)
                    }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 4)
    }

    // MARK: - Picker panel

    private var pickerGlassPanel: some View {
        OrbSpectrumStudio(color: $color)
            .padding(.horizontal, 4)
            .padding(.vertical, 8)
            .background {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(red: 0.03, green: 0.05, blue: 0.14).opacity(0.88))
                    .glassEffect(.clear.tint(accent.opacity(0.12)), in: .rect(cornerRadius: 24))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.16), accent.opacity(0.35), .white.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
    }

    private func colorsMatch(_ a: Color, _ b: Color) -> Bool {
        guard let ra = a.toRGBA(), let rb = b.toRGBA() else { return false }
        return abs(ra.r - rb.r) < 0.04 && abs(ra.g - rb.g) < 0.04 && abs(ra.b - rb.b) < 0.04
    }

    private var hexString: String {
        guard let rgba = color.toRGBA() else { return "#------" }
        let r = Int((rgba.r * 255).rounded())
        let g = Int((rgba.g * 255).rounded())
        let b = Int((rgba.b * 255).rounded())
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
