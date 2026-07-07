//
//  OrbColorStudio.swift
//  todoTask
//

import SwiftUI

// MARK: - Figma-style bottom control panel
struct OrbDesignControlPanel: View {
    @EnvironmentObject private var lang: LanguageManager

    let stops: [Color]
    let selectedStopIndex: Int
    let canAddStop: Bool
    let glow: Binding<Double>
    let effects: [String]
    let selectedEffectIndex: Int
    let textureOpacity: Double

    let onSelectStop: (Int) -> Void
    let onEditStop: () -> Void
    let onDeleteStop: (Int) -> Void
    let onAddStop: () -> Void
    let onSelectEffect: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            OrbPlanetColorsRow(
                stops: stops,
                selectedIndex: selectedStopIndex,
                canAdd: canAddStop,
                onSelect: onSelectStop,
                onEditSelected: onEditStop,
                onDelete: onDeleteStop,
                onAdd: onAddStop
            )

            OrbGlowControl(glow: glow, tint: stops.first ?? Color("accent"))

            OrbTextureCarousel(
                effects: effects,
                selectedIndex: selectedEffectIndex,
                gradientColors: stops,
                glow: glow.wrappedValue,
                textureOpacity: textureOpacity,
                onSelect: onSelectEffect
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(red: 0.02, green: 0.03, blue: 0.10).opacity(0.94))
                .glassEffect(.clear, in: .rect(cornerRadius: 22))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        }
    }
}

// MARK: - Planet Colors (Figma row — scrolls when many stops)
struct OrbPlanetColorsRow: View {
    @EnvironmentObject private var lang: LanguageManager

    let stops: [Color]
    let selectedIndex: Int
    let canAdd: Bool
    let onSelect: (Int) -> Void
    let onEditSelected: () -> Void
    let onDelete: (Int) -> Void
    let onAdd: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(lang.t(.planetColors))
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white.opacity(0.55))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(stops.indices, id: \.self) { index in
                        Button {
                            if selectedIndex == index {
                                onEditSelected()
                            } else {
                                onSelect(index)
                            }
                        } label: {
                            Circle()
                                .fill(stops[index])
                                .frame(width: 44, height: 44)
                                .overlay {
                                    Circle()
                                        .stroke(
                                            .white.opacity(selectedIndex == index ? 0.95 : 0),
                                            lineWidth: 2.5
                                        )
                                }
                                .shadow(
                                    color: stops[index].opacity(selectedIndex == index ? 0.45 : 0.15),
                                    radius: selectedIndex == index ? 8 : 3,
                                    y: 2
                                )
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            if stops.count > 2 {
                                Button(role: .destructive) {
                                    onDelete(index)
                                } label: {
                                    Label(lang.t(.deleteColor), systemImage: "trash")
                                }
                            }
                        }
                    }

                    if canAdd {
                        Button(action: onAdd) {
                            ZStack {
                                Circle()
                                    .stroke(
                                        .white.opacity(0.32),
                                        style: StrokeStyle(lineWidth: 1.5, dash: [5, 4])
                                    )
                                    .frame(width: 44, height: 44)
                                Image(systemName: "plus")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(.white.opacity(0.85))
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }
}

// MARK: - Glow slider
private struct OrbGlowControl: View {
    @EnvironmentObject private var lang: LanguageManager
    @Binding var glow: Double
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(lang.t(.glow))
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white.opacity(0.55))

            HStack(spacing: 12) {
                Image(systemName: "sun.min")
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.45))

                Slider(value: $glow, in: 0...0.15)
                    .tint(tint)

                Image(systemName: "sun.max.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(.white.opacity(0.75))
            }
        }
    }
}

// MARK: - Texture carousel (arrows on title row — Figma)
struct OrbTextureCarousel: View {
    @EnvironmentObject private var lang: LanguageManager

    let effects: [String]
    let selectedIndex: Int
    let gradientColors: [Color]
    let glow: Double
    let textureOpacity: Double
    let onSelect: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Text(lang.t(.texture))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.55))

                Spacer(minLength: 0)

                carouselButton(systemName: "chevron.left", enabled: selectedIndex > 0) {
                    onSelect(selectedIndex - 1)
                }
                carouselButton(
                    systemName: "chevron.right",
                    enabled: selectedIndex < effects.count - 1
                ) {
                    onSelect(selectedIndex + 1)
                }
            }

            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(Array(effects.enumerated()), id: \.offset) { index, asset in
                            Button {
                                onSelect(index)
                            } label: {
                                PlanetOrbView(
                                    size: 52,
                                    gradientColors: gradientColors.count >= 2
                                        ? gradientColors
                                        : [.purple, .pink],
                                    glow: glow,
                                    textureAssetName: asset,
                                    textureOpacity: textureOpacity
                                )
                                .overlay {
                                    Circle()
                                        .stroke(
                                            .white.opacity(selectedIndex == index ? 0.9 : 0.12),
                                            lineWidth: selectedIndex == index ? 2 : 1
                                        )
                                        .padding(-2)
                                }
                            }
                            .buttonStyle(.plain)
                            .id(index)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .onChange(of: selectedIndex) { _, newValue in
                    withAnimation(.easeInOut(duration: 0.22)) {
                        proxy.scrollTo(newValue, anchor: .center)
                    }
                }
                .onAppear {
                    proxy.scrollTo(selectedIndex, anchor: .center)
                }
            }
        }
    }

    private func carouselButton(systemName: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white.opacity(enabled ? 0.75 : 0.22))
                .frame(width: 32, height: 32)
                .background {
                    Circle()
                        .fill(.white.opacity(enabled ? 0.08 : 0.04))
                }
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }
}

// MARK: - Palette carousel (optional presets — kept for reuse)
struct OrbPaletteCarousel: View {
    @EnvironmentObject private var lang: LanguageManager
    let activePresetID: String?
    let onSelect: (OrbPalettePreset) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(lang.t(.colorPalettes))
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white.opacity(0.72))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(OrbPalettePreset.all) { preset in
                        OrbPaletteCard(
                            preset: preset,
                            isSelected: activePresetID == preset.id,
                            language: lang.language
                        ) {
                            onSelect(preset)
                        }
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }
}

private struct OrbPaletteCard: View {
    let preset: OrbPalettePreset
    let isSelected: Bool
    let language: AppLanguage
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                PlanetOrbView(
                    size: 52,
                    gradientColors: preset.colors,
                    glow: preset.glow,
                    textureAssetName: PlanetDesignPresets.effects[safe: preset.effectIndex],
                    textureOpacity: 0.75
                )
                .frame(width: 58, height: 58)

                Text(preset.name(for: language))
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(isSelected ? 1 : 0.72))
                    .lineLimit(1)
            }
            .frame(width: 78)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.white.opacity(isSelected ? 0.10 : 0.05))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(
                        isSelected ? preset.colors.first?.opacity(0.85) ?? .cyan : .white.opacity(0.10),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            }
        }
        .buttonStyle(.plain)
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}

// MARK: - Quick hue grid (used in color picker sheet)
struct OrbHueQuickPicker: View {
    @EnvironmentObject private var lang: LanguageManager
    @Binding var color: Color
    var showsCustomButton: Bool = true
    let onCustom: () -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 6)

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(lang.t(.quickHues))
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white.opacity(0.72))

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(Array(OrbQuickHues.colors.enumerated()), id: \.offset) { _, hue in
                    Button {
                        withAnimation(.easeInOut(duration: 0.16)) { color = hue }
                    } label: {
                        Circle()
                            .fill(hue)
                            .frame(height: 28)
                            .overlay {
                                if colorsMatch(hue, color) {
                                    Circle().stroke(.white, lineWidth: 2)
                                }
                            }
                    }
                    .buttonStyle(.plain)
                }

                if showsCustomButton {
                    Button(action: onCustom) {
                        ZStack {
                            Circle()
                                .fill(
                                    AngularGradient(
                                        colors: [.red, .orange, .yellow, .green, .cyan, .blue, .purple, .red],
                                        center: .center
                                    )
                                )
                                .frame(height: 28)
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func colorsMatch(_ a: Color, _ b: Color) -> Bool {
        guard let ra = a.toRGBA(), let rb = b.toRGBA() else { return false }
        return abs(ra.r - rb.r) < 0.04 && abs(ra.g - rb.g) < 0.04 && abs(ra.b - rb.b) < 0.04
    }
}

// MARK: - HSB helpers for orbital picker
struct OrbHSB {
    var h: Double
    var s: Double
    var b: Double

    var color: Color { Color.fromHSB(h: h, s: s, b: b) }

    static func from(_ color: Color) -> OrbHSB {
        guard let rgba = color.toRGBA() else { return OrbHSB(h: 0.55, s: 0.85, b: 0.95) }
        return OrbHSB.fromRGB(r: rgba.r, g: rgba.g, b: rgba.b)
    }

    static func fromRGB(r: Double, g: Double, b: Double) -> OrbHSB {
        let maxC = max(r, g, b)
        let minC = min(r, g, b)
        let delta = maxC - minC

        var hue: Double = 0
        let sat = maxC == 0 ? 0 : delta / maxC
        let bri = maxC

        if delta > 0.0001 {
            if maxC == r {
                hue = (g - b) / delta
            } else if maxC == g {
                hue = 2 + (b - r) / delta
            } else {
                hue = 4 + (r - g) / delta
            }
            hue /= 6
            if hue < 0 { hue += 1 }
        }

        return OrbHSB(h: hue, s: sat, b: bri)
    }
}

extension Color {
    static func fromHSB(h: Double, s: Double, b: Double) -> Color {
        let hue = h - floor(h)
        let c = b * s
        let x = c * (1 - abs((hue * 6).truncatingRemainder(dividingBy: 2) - 1))
        let m = b - c

        let (rp, gp, bp): (Double, Double, Double)
        switch Int(hue * 6) % 6 {
        case 0: (rp, gp, bp) = (c, x, 0)
        case 1: (rp, gp, bp) = (x, c, 0)
        case 2: (rp, gp, bp) = (0, c, x)
        case 3: (rp, gp, bp) = (0, x, c)
        case 4: (rp, gp, bp) = (x, 0, c)
        default: (rp, gp, bp) = (c, 0, x)
        }

        return Color(.sRGB, red: rp + m, green: gp + m, blue: bp + m, opacity: 1)
    }
}

// MARK: - Orbital hue ring + saturation/brightness pad
struct OrbitColorPickerCore: View {
    @EnvironmentObject private var lang: LanguageManager
    @Binding var color: Color

    @State private var hsb = OrbHSB(h: 0.55, s: 0.85, b: 0.95)
    @State private var isDraggingRing = false
    @State private var isDraggingPad = false
    @State private var ringPulse = false

    private let ringOuter: CGFloat = 108
    private let ringInner: CGFloat = 82

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                OrbitHueRing(
                    hue: hsb.h,
                    outerRadius: ringOuter,
                    innerRadius: ringInner,
                    isActive: isDraggingRing
                )

                OrbitSaturationBrightnessPad(
                    hue: hsb.h,
                    saturation: $hsb.s,
                    brightness: $hsb.b,
                    size: CGSize(width: ringInner * 1.55, height: ringInner * 1.55),
                    isActive: isDraggingPad,
                    onDragChanged: { isDraggingPad = true },
                    onDragEnded: { isDraggingPad = false }
                )

                Circle()
                    .fill(hsb.color)
                    .frame(width: 34, height: 34)
                    .overlay {
                        Circle()
                            .stroke(.white.opacity(0.9), lineWidth: 2)
                    }
                    .shadow(color: hsb.color.opacity(0.65), radius: ringPulse ? 14 : 8)
                    .scaleEffect(ringPulse ? 1.06 : 1)
                    .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: ringPulse)
            }
            .frame(width: ringOuter * 2 + 8, height: ringOuter * 2 + 8)
            .contentShape(Rectangle())
            .gesture(ringDragGesture)
            .overlay { hueIndicator }

            HStack(spacing: 10) {
                OrbitColorSlider(
                    label: lang.language == .arabic ? "التشبع" : "Saturation",
                    value: $hsb.s,
                    gradient: [.white, Color.fromHSB(h: hsb.h, s: 1, b: 1)],
                    tint: hsb.color
                )
                OrbitColorSlider(
                    label: lang.language == .arabic ? "السطوع" : "Brightness",
                    value: $hsb.b,
                    gradient: [.black, Color.fromHSB(h: hsb.h, s: hsb.s, b: 1)],
                    tint: hsb.color
                )
            }
        }
        .onAppear {
            syncFromBinding()
            ringPulse = true
        }
        .onChange(of: color) { _, _ in
            guard !isDraggingRing, !isDraggingPad else { return }
            syncFromBinding()
        }
        .onChange(of: hsb.h) { _, _ in publishColor() }
        .onChange(of: hsb.s) { _, _ in publishColor() }
        .onChange(of: hsb.b) { _, _ in publishColor() }
    }

    private var hueIndicator: some View {
        let angle = hsb.h * 2 * .pi - .pi / 2
        let radius = (ringOuter + ringInner) / 2
        return Circle()
            .fill(.white)
            .frame(width: isDraggingRing ? 20 : 16, height: isDraggingRing ? 20 : 16)
            .overlay {
                Circle()
                    .stroke(hsb.color, lineWidth: 3)
            }
            .shadow(color: hsb.color.opacity(0.8), radius: isDraggingRing ? 10 : 5)
            .offset(x: cos(angle) * radius, y: sin(angle) * radius)
            .animation(.spring(response: 0.28, dampingFraction: 0.72), value: isDraggingRing)
    }

    private var ringDragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                isDraggingRing = true
                let center = CGPoint(x: ringOuter + 4, y: ringOuter + 4)
                let dx = value.location.x - center.x
                let dy = value.location.y - center.y
                let dist = sqrt(dx * dx + dy * dy)
                guard dist > ringInner * 0.72 else { return }
                var angle = atan2(dy, dx) + .pi / 2
                if angle < 0 { angle += 2 * .pi }
                hsb.h = angle / (2 * .pi)
            }
            .onEnded { _ in
                isDraggingRing = false
            }
    }
    private func syncFromBinding() {
        hsb = OrbHSB.from(color)
    }

    private func publishColor() {
        let next = hsb.color
        guard !colorsMatch(next, color) else { return }
        color = next
    }

    private func colorsMatch(_ a: Color, _ b: Color) -> Bool {
        guard let ra = a.toRGBA(), let rb = b.toRGBA() else { return false }
        return abs(ra.r - rb.r) < 0.02 && abs(ra.g - rb.g) < 0.02 && abs(ra.b - rb.b) < 0.02
    }
}

private struct OrbitHueRing: View {
    let hue: Double
    let outerRadius: CGFloat
    let innerRadius: CGFloat
    let isActive: Bool

    private var spectrum: [Color] {
        (0...12).map { Color.fromHSB(h: Double($0) / 12, s: 1, b: 1) }
    }

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(
                    AngularGradient(colors: spectrum + [spectrum[0]], center: .center),
                    lineWidth: outerRadius - innerRadius
                )
                .frame(width: outerRadius * 2, height: outerRadius * 2)
                .opacity(isActive ? 1 : 0.92)

            Circle()
                .stroke(.white.opacity(isActive ? 0.22 : 0.10), lineWidth: 1)
                .frame(width: outerRadius * 2, height: outerRadius * 2)

            Circle()
                .stroke(.white.opacity(0.06), lineWidth: 1)
                .frame(width: innerRadius * 2, height: innerRadius * 2)
        }
        .shadow(color: Color.fromHSB(h: hue, s: 0.9, b: 1).opacity(0.35), radius: isActive ? 18 : 10)
    }
}

private struct OrbitSaturationBrightnessPad: View {
    let hue: Double
    @Binding var saturation: Double
    @Binding var brightness: Double
    let size: CGSize
    let isActive: Bool
    var onDragChanged: () -> Void = {}
    var onDragEnded: () -> Void = {}

    private var pureHue: Color { Color.fromHSB(h: hue, s: 1, b: 1) }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size.width / 2, style: .continuous)
                .fill(
                    LinearGradient(colors: [.white, pureHue], startPoint: .leading, endPoint: .trailing)
                )
            RoundedRectangle(cornerRadius: size.width / 2, style: .continuous)
                .fill(
                    LinearGradient(colors: [.clear, .black], startPoint: .top, endPoint: .bottom)
                )

            Circle()
                .strokeBorder(.white, lineWidth: isActive ? 2.5 : 2)
                .background(Circle().fill(pureHue))
                .frame(width: isActive ? 18 : 14, height: isActive ? 18 : 14)
                .shadow(color: .black.opacity(0.35), radius: 3, y: 1)
                .position(
                    x: CGFloat(saturation) * size.width,
                    y: (1 - CGFloat(brightness)) * size.height
                )
        }
        .frame(width: size.width, height: size.height)
        .clipShape(RoundedRectangle(cornerRadius: size.width / 2, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: size.width / 2, style: .continuous)
                .stroke(.white.opacity(0.14), lineWidth: 1)
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    onDragChanged()
                    let x = min(max(value.location.x, 0), size.width)
                    let y = min(max(value.location.y, 0), size.height)
                    saturation = Double(x / size.width)
                    brightness = 1 - Double(y / size.height)
                }
                .onEnded { _ in onDragEnded() }
        )
    }
}

private struct OrbitColorSlider: View {
    let label: String
    @Binding var value: Double
    let gradient: [Color]
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white.opacity(0.5))

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(LinearGradient(colors: gradient, startPoint: .leading, endPoint: .trailing))
                        .frame(height: 8)
                        .overlay {
                            Capsule().stroke(.white.opacity(0.12), lineWidth: 1)
                        }

                    Circle()
                        .fill(.white)
                        .frame(width: 16, height: 16)
                        .shadow(color: tint.opacity(0.5), radius: 4)
                        .offset(x: max(0, min(geo.size.width - 16, CGFloat(value) * (geo.size.width - 16))))
                }
                .frame(height: 16)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { drag in
                            let w = max(geo.size.width - 16, 1)
                            value = min(1, max(0, Double(drag.location.x / w)))
                        }
                )
            }
            .frame(height: 16)
        }
        .frame(maxWidth: .infinity)
    }
}
