//
//  OrbSpectrumStudio.swift
//  todoTask
//

import SwiftUI
import UIKit

// MARK: - Custom ORBIT spectrum picker (replaces system UIColorPicker)
struct OrbSpectrumStudio: View {
    @EnvironmentObject private var lang: LanguageManager
    @Binding var color: Color

    @State private var hue: Double = 0.55
    @State private var saturation: Double = 0.85
    @State private var brightness: Double = 0.95
    @State private var syncingFromBinding = false

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            studioSection(title: lang.t(.orbitHue), icon: "circle.circle") {
                OrbHueRing(hue: $hue)
                    .frame(height: 118)
                    .padding(.horizontal, 28)
            }

            studioSection(title: lang.t(.nebulaBlend), icon: "sparkles") {
                OrbNebulaPad(hue: hue, saturation: $saturation, brightness: $brightness)
                    .frame(height: 148)
            }
        }
        .onAppear { pullFromColor() }
        .onChange(of: hue) { _, _ in pushToColor() }
        .onChange(of: saturation) { _, _ in pushToColor() }
        .onChange(of: brightness) { _, _ in pushToColor() }
        .onChange(of: color) { _, _ in
            guard !syncingFromBinding else { return }
            pullFromColor()
        }
    }

    private func studioSection<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white.opacity(0.62))
                .labelStyle(.titleAndIcon)

            content()
                .padding(12)
                .background {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.white.opacity(0.04))
                        .glassEffect(.clear.tint(Color.black.opacity(0.28)), in: .rect(cornerRadius: 20))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(.white.opacity(0.08), lineWidth: 1)
                }
        }
    }

    private func pullFromColor() {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        guard UIColor(color).getHue(&h, saturation: &s, brightness: &b, alpha: &a) else { return }
        hue = Double(h)
        saturation = Double(s)
        brightness = Double(b)
    }

    private func pushToColor() {
        syncingFromBinding = true
        color = Color(hue: hue, saturation: saturation, brightness: brightness)
        DispatchQueue.main.async { syncingFromBinding = false }
    }
}

// MARK: - Orbital hue ring
private struct OrbHueRing: View {
    @Binding var hue: Double

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let ringWidth: CGFloat = 20
            let radius = max(8, (size - ringWidth) / 2)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)

            ZStack {
                Circle()
                    .stroke(
                        AngularGradient(
                            colors: [
                                Color(hue: 0.00, saturation: 1, brightness: 1),
                                Color(hue: 0.08, saturation: 1, brightness: 1),
                                Color(hue: 0.16, saturation: 1, brightness: 1),
                                Color(hue: 0.25, saturation: 1, brightness: 1),
                                Color(hue: 0.33, saturation: 1, brightness: 1),
                                Color(hue: 0.50, saturation: 1, brightness: 1),
                                Color(hue: 0.58, saturation: 1, brightness: 1),
                                Color(hue: 0.66, saturation: 1, brightness: 1),
                                Color(hue: 0.75, saturation: 1, brightness: 1),
                                Color(hue: 0.83, saturation: 1, brightness: 1),
                                Color(hue: 0.92, saturation: 1, brightness: 1),
                                Color(hue: 1.00, saturation: 1, brightness: 1)
                            ],
                            center: .center
                        ),
                        lineWidth: ringWidth
                    )
                    .shadow(color: Color(hue: hue, saturation: 1, brightness: 1).opacity(0.35), radius: 10)

                Circle()
                    .fill(Color(red: 0.02, green: 0.03, blue: 0.10).opacity(0.92))
                    .frame(width: size - ringWidth * 2.2, height: size - ringWidth * 2.2)
                    .overlay {
                        Circle()
                            .stroke(.white.opacity(0.06), lineWidth: 1)
                    }

                let knob = knobPoint(center: center, radius: radius, hue: hue)
                Circle()
                    .fill(Color(hue: hue, saturation: 1, brightness: 1))
                    .frame(width: 26, height: 26)
                    .overlay {
                        Circle()
                            .stroke(.white.opacity(0.95), lineWidth: 2.5)
                    }
                    .shadow(color: Color(hue: hue, saturation: 1, brightness: 1).opacity(0.65), radius: 8)
                    .position(knob)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        hue = hueFrom(point: value.location, center: center)
                    }
            )
        }
    }

    private func knobPoint(center: CGPoint, radius: CGFloat, hue: Double) -> CGPoint {
        let angle = hue * 2 * Double.pi - Double.pi / 2
        return CGPoint(
            x: center.x + CGFloat(cos(angle)) * radius,
            y: center.y + CGFloat(sin(angle)) * radius
        )
    }

    private func hueFrom(point: CGPoint, center: CGPoint) -> Double {
        let dx = Double(point.x - center.x)
        let dy = Double(point.y - center.y)
        var angle = atan2(dy, dx) + Double.pi / 2
        if angle < 0 { angle += 2 * Double.pi }
        return min(max(angle / (2 * Double.pi), 0), 1)
    }
}

// MARK: - Saturation / brightness nebula pad
private struct OrbNebulaPad: View {
    let hue: Double
    @Binding var saturation: Double
    @Binding var brightness: Double

    var body: some View {
        GeometryReader { geo in
            let pad = RoundedRectangle(cornerRadius: 16, style: .continuous)

            ZStack {
                pad
                    .fill(Color(hue: hue, saturation: 1, brightness: 1))
                    .overlay {
                        LinearGradient(
                            colors: [.white, .white.opacity(0)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    }
                    .overlay {
                        LinearGradient(
                            colors: [.clear, .black],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                    .clipShape(pad)

                pad
                    .stroke(.white.opacity(0.14), lineWidth: 1)

                Circle()
                    .fill(Color(hue: hue, saturation: saturation, brightness: brightness))
                    .frame(width: 24, height: 24)
                    .overlay {
                        Circle()
                            .stroke(.white.opacity(0.95), lineWidth: 2)
                    }
                    .shadow(color: .black.opacity(0.35), radius: 5, y: 2)
                    .position(
                        x: saturation * geo.size.width,
                        y: (1 - brightness) * geo.size.height
                    )
            }
            .contentShape(pad)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        saturation = min(max(Double(value.location.x / geo.size.width), 0), 1)
                        brightness = min(max(1 - Double(value.location.y / geo.size.height), 0), 1)
                    }
            )
        }
    }
}

// MARK: - Horizontal glowing quick hues
struct OrbNebulaQuickHues: View {
    @EnvironmentObject private var lang: LanguageManager
    @Binding var color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(lang.t(.quickHues))
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white.opacity(0.62))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(OrbQuickHues.colors.enumerated()), id: \.offset) { _, hue in
                        Button {
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.78)) {
                                color = hue
                            }
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(hue.opacity(0.35))
                                    .frame(width: 52, height: 52)
                                    .blur(radius: 8)

                                Circle()
                                    .fill(hue)
                                    .frame(width: 38, height: 38)
                                    .overlay {
                                        Circle()
                                            .stroke(
                                                .white.opacity(colorsMatch(hue, color) ? 0.95 : 0.18),
                                                lineWidth: colorsMatch(hue, color) ? 2.5 : 1
                                            )
                                    }
                                    .shadow(color: hue.opacity(0.55), radius: colorsMatch(hue, color) ? 10 : 4)
                            }
                            .frame(width: 52, height: 52)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    private func colorsMatch(_ a: Color, _ b: Color) -> Bool {
        guard let ra = a.toRGBA(), let rb = b.toRGBA() else { return false }
        return abs(ra.r - rb.r) < 0.04 && abs(ra.g - rb.g) < 0.04 && abs(ra.b - rb.b) < 0.04
    }
}

// MARK: - Palette seed row
struct OrbCosmicSeedRow: View {
    @EnvironmentObject private var lang: LanguageManager
    @Binding var color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(lang.t(.colorPalettes))
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white.opacity(0.62))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(OrbPalettePreset.all) { preset in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                color = preset.colors.first ?? color
                            }
                        } label: {
                            VStack(spacing: 6) {
                                PlanetOrbView(
                                    size: 44,
                                    gradientColors: preset.colors,
                                    glow: preset.glow,
                                    textureAssetName: PlanetDesignPresets.effects[safe: preset.effectIndex],
                                    textureOpacity: 0.7
                                )
                                .frame(width: 50, height: 50)

                                Text(preset.name(for: lang.language))
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundStyle(.white.opacity(0.72))
                                    .lineLimit(1)
                            }
                            .frame(width: 68)
                            .padding(.vertical, 8)
                            .background {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(.white.opacity(0.05))
                            }
                            .overlay {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(.white.opacity(0.08), lineWidth: 1)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}
