//
//  OrbitGalaxyScene.swift
//  todoTask
//

import SwiftUI

// MARK: - Orbs page — deep space with stars & meteors (app theme colors)
struct OrbsSpaceBackground: View {
    @State private var drift = false

    private var accent: Color { Color("accent") }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.01, green: 0.02, blue: 0.08),
                    Color.darkBlu,
                    Color.dark,
                    Color(red: 0.02, green: 0.03, blue: 0.10)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            deepSpaceGlow(accent: accent)

            StarFieldLayer(count: 120, sizeRange: 0.4...1.1, opacity: 0.20...0.55, drift: drift, seed: 3)
            StarFieldLayer(count: 55, sizeRange: 0.9...1.8, opacity: 0.30...0.70, drift: drift, seed: 11)
            StarFieldLayer(count: 22, sizeRange: 1.6...2.8, opacity: 0.45...0.92, drift: drift, seed: 23)

            Image("Gliter")
                .resizable()
                .ignoresSafeArea()
                .opacity(0.18)
                .blendMode(.screen)

            OrbsMeteorLayer(accent: accent)
        }
        .onAppear {
            withAnimation(.linear(duration: 40).repeatForever(autoreverses: true)) {
                drift = true
            }
        }
        .allowsHitTesting(false)
    }

    private func deepSpaceGlow(accent: Color) -> some View {
        GeometryReader { geo in
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.darkBlu.opacity(0.35), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: geo.size.width * 0.55
                        )
                    )
                    .frame(width: geo.size.width * 0.9)
                    .position(x: geo.size.width * 0.5, y: geo.size.height * 0.35)
                    .blur(radius: 30)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [accent.opacity(0.07), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: geo.size.width * 0.35
                        )
                    )
                    .frame(width: geo.size.width * 0.55)
                    .position(x: geo.size.width * 0.88, y: geo.size.height * 0.12)
                    .blur(radius: 28)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [accent.opacity(0.05), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: geo.size.width * 0.28
                        )
                    )
                    .frame(width: geo.size.width * 0.45)
                    .position(x: geo.size.width * 0.10, y: geo.size.height * 0.78)
                    .blur(radius: 24)
            }
        }
        .ignoresSafeArea()
    }
}

/// Legacy alias — Orbs page uses themed background
struct GalaxyBackgroundView: View {
    var body: some View { OrbsSpaceBackground() }
}

private struct OrbsMeteorLayer: View {
    let accent: Color

    var body: some View {
        GeometryReader { geo in
            ForEach(0..<7, id: \.self) { index in
                LoopingMeteor(
                    width: geo.size.width,
                    height: geo.size.height,
                    seed: index,
                    accent: accent
                )
            }
        }
        .ignoresSafeArea()
    }
}

struct SoftStarfieldBackground: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(LinearGradient(colors: [.darkBlu, .dark], startPoint: .bottom, endPoint: .top))
                .ignoresSafeArea()
            StarFieldLayer(count: 65, sizeRange: 0.5...1.3, opacity: 0.18...0.48, drift: false, seed: 11)
            StarFieldLayer(count: 24, sizeRange: 1.0...2.1, opacity: 0.28...0.62, drift: false, seed: 29)
            StarFieldLayer(count: 8, sizeRange: 1.8...2.8, opacity: 0.4...0.8, drift: false, seed: 37)
            Image("Gliter")
                .resizable()
                .ignoresSafeArea()
                .opacity(0.22)
                .blendMode(.screen)
        }
        .allowsHitTesting(false)
    }
}

struct StarFieldLayer: View {
    let count: Int
    let sizeRange: ClosedRange<CGFloat>
    let opacity: ClosedRange<Double>
    let drift: Bool
    let seed: Int

    private var stars: [(x: CGFloat, y: CGFloat, size: CGFloat, twinkle: Double)] {
        var rng = SeededRandomNumberGenerator(seed: UInt64(seed * 9973))
        return (0..<count).map { _ in
            (
                x: CGFloat.random(in: 0...1, using: &rng),
                y: CGFloat.random(in: 0...1, using: &rng),
                size: CGFloat.random(in: sizeRange, using: &rng),
                twinkle: Double.random(in: opacity, using: &rng)
            )
        }
    }

    var body: some View {
        GeometryReader { geo in
            ForEach(Array(stars.enumerated()), id: \.offset) { index, star in
                TwinklingStar(
                    size: star.size,
                    baseOpacity: star.twinkle,
                    delay: Double(index % 17) * 0.12
                )
                .position(
                    x: star.x * geo.size.width + (drift ? CGFloat(index % 5) - 2 : 0),
                    y: star.y * geo.size.height + (drift ? CGFloat(index % 3) - 1 : 0)
                )
            }
        }
        .ignoresSafeArea()
    }
}

private struct TwinklingStar: View {
    let size: CGFloat
    let baseOpacity: Double
    let delay: Double
    @State private var lit = false

    var body: some View {
        Circle()
            .fill(.white)
            .frame(width: size, height: size)
            .opacity(lit ? baseOpacity : baseOpacity * 0.35)
            .shadow(color: .white.opacity(lit ? 0.5 : 0.1), radius: lit ? 3 : 1)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: Double.random(in: 1.4...2.8))
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    lit = true
                }
            }
    }
}

private struct SeededRandomNumberGenerator: RandomNumberGenerator {
    var state: UInt64
    init(seed: UInt64) { state = seed == 0 ? 1 : seed }
    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1
        return state
    }
}

// MARK: - Deep space decoration
struct DeepSpaceDecorLayer: View {
    private let distantPlanets: [(x: CGFloat, y: CGFloat, size: CGFloat, colors: [Color], blur: CGFloat)] = [
        (0.12, 0.22, 54, [Color.purple.opacity(0.35), Color.indigo.opacity(0.15)], 8),
        (0.88, 0.18, 42, [Color.cyan.opacity(0.28), Color.blue.opacity(0.12)], 6),
        (0.08, 0.68, 36, [Color.orange.opacity(0.22), Color.red.opacity(0.08)], 5),
        (0.92, 0.74, 48, [Color.pink.opacity(0.25), Color.purple.opacity(0.1)], 7),
        (0.50, 0.08, 28, [Color.white.opacity(0.15), Color.cyan.opacity(0.08)], 4)
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(Array(distantPlanets.enumerated()), id: \.offset) { _, planet in
                    Circle()
                        .fill(
                            AngularGradient(
                                colors: planet.colors + [planet.colors.first ?? .purple],
                                center: .center
                            )
                        )
                        .frame(width: planet.size, height: planet.size)
                        .blur(radius: planet.blur)
                        .opacity(0.35)
                        .position(
                            x: geo.size.width * planet.x,
                            y: geo.size.height * planet.y
                        )
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

private struct ShootingStarLayer: View {
    var body: some View {
        GeometryReader { geo in
            ForEach(0..<8, id: \.self) { index in
                LoopingMeteor(
                    width: geo.size.width,
                    height: geo.size.height,
                    seed: index
                )
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

private struct LoopingMeteor: View {
    let width: CGFloat
    let height: CGFloat
    let seed: Int
    var accent: Color = Color("accent")

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30, paused: false)) { timeline in
            let elapsed = timeline.date.timeIntervalSinceReferenceDate + Double(seed) * 1.7
            let cycle = 6.0 + Double(seed) * 0.9
            let phase = elapsed.truncatingRemainder(dividingBy: cycle) / cycle
            let active = phase < 0.2
            let progress = phase / 0.2

            Capsule()
                .fill(
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.85), accent.opacity(0.65), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 64 + CGFloat(seed * 10), height: 2)
                .rotationEffect(.degrees(-34 - Double(seed) * 6))
                .opacity(active ? Double(1 - progress) * 0.9 : 0)
                .shadow(color: accent.opacity(active ? 0.4 : 0), radius: 4)
                .position(
                    x: width * (0.06 + progress * 0.78 + Double(seed) * 0.03),
                    y: height * (0.08 + progress * 0.42 + Double(seed) * 0.04)
                )
        }
    }
}

// MARK: - Galaxy header
struct GalaxyHeaderView: View {
    @EnvironmentObject private var lang: LanguageManager
    let goals: [OrbGoal]

    private var themeAccent: Color { Color("accent") }

    private var averageProgress: Double {
        guard !goals.isEmpty else { return 0 }
        return goals.reduce(0) { $0 + $1.progress } / Double(goals.count)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(lang.t(.orbsGalaxySubtitle))
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white.opacity(0.62))

            HStack(spacing: 10) {
                galaxyStatChip(
                    icon: "globe.americas.fill",
                    text: lang.orbsWorldsCount(goals.count),
                    tint: themeAccent
                )
                galaxyStatChip(
                    icon: "sparkles",
                    text: "\(Int(averageProgress * 100))%",
                    tint: themeAccent
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 22)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    private func galaxyStatChip(icon: String, text: String, tint: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
            Text(text)
                .font(.system(size: 12, weight: .semibold))
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(Capsule().fill(tint.opacity(0.12)))
        .overlay(Capsule().stroke(tint.opacity(0.22), lineWidth: 1))
    }
}

// MARK: - Empty state
struct GalaxyEmptyStateView: View {
    @EnvironmentObject private var lang: LanguageManager
    @State private var breathe = false

    private var themeAccent: Color { Color("accent") }
    private var themeOrbColors: [Color] {
        [themeAccent, themeAccent.opacity(0.72), Color.darkBlu]
    }

    var body: some View {
        VStack(spacing: 28) {
            ZStack {
                Circle()
                    .stroke(themeAccent.opacity(0.18), style: StrokeStyle(lineWidth: 1, dash: [6, 8]))
                    .frame(width: 168, height: 168)
                    .scaleEffect(breathe ? 1.04 : 0.96)

                PlanetOrbView(
                    size: breathe ? 88 : 80,
                    gradientColors: themeOrbColors,
                    glow: breathe ? 0.13 : 0.09,
                    textureAssetName: "effect2",
                    textureOpacity: 0.55
                )
            }
            .frame(height: 200)

            VStack(spacing: 10) {
                Text(lang.t(.noOrbsYet))
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text(lang.t(.orbsEmptyPoem))
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white.opacity(0.55))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Text(lang.t(.tapCreateFirst))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(themeAccent.opacity(0.9))
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
        .onAppear {
            withAnimation(.easeInOut(duration: 3.2).repeatForever(autoreverses: true)) {
                breathe = true
            }
        }
    }
}

// MARK: - Vertical scroll orbs
struct GalaxyOrbsCanvas: View {
    let goals: [OrbGoal]
    let screenWidth: CGFloat
    let onDelete: (OrbGoal) -> Void
    var onChallengeTap: ((OrbGoal) -> Void)? = nil

    var body: some View {
        LazyVStack(spacing: screenWidth * 0.10) {
            ForEach(Array(goals.enumerated()), id: \.element.id) { index, goal in
                HStack(alignment: .center, spacing: 0) {
                    if index.isMultiple(of: 2) { Spacer(minLength: 0) }

                    GalaxyOrbNode(
                        goal: goal,
                        size: orbSize(for: goal),
                        index: index,
                        onChallengeTap: onChallengeTap
                    ) {
                        onDelete(goal)
                    }

                    if !index.isMultiple(of: 2) { Spacer(minLength: 0) }
                }
                .padding(.horizontal, 32)
            }
        }
        .padding(.top, 12)
        .padding(.bottom, 24)
    }

    private func orbSize(for goal: OrbGoal) -> CGFloat {
        let seed = abs(goal.id.hashValue) % 1000
        let normalized = Double(seed) / 1000.0
        let taskBoost = min(Double(goal.totalTasks), 12) / 12.0 * 0.025
        let baseFactor = 0.15 + normalized * 0.12 + taskBoost
        let progressBoost = min(goal.progress, 1) * 0.02
        return screenWidth * CGFloat(baseFactor + progressBoost)
    }
}

// MARK: - Orb node
struct GalaxyOrbNode: View {
    @EnvironmentObject private var lang: LanguageManager
    @EnvironmentObject private var challengeOrbs: ChallengeOrbsManager
    let goal: OrbGoal
    let size: CGFloat
    let index: Int
    var onChallengeTap: ((OrbGoal) -> Void)? = nil
    var onDelete: () -> Void

    @State private var floatY: CGFloat = 0

    private var themeAccent: Color { Color("accent") }
    private var progress: Double { max(0, min(goal.progress, 1)) }
    private var live: ChallengeLiveState? { challengeOrbs.liveState(for: goal) }

    var body: some View {
        Group {
            if goal.isChallenge {
                Button {
                    onChallengeTap?(goal)
                } label: {
                    orbContent
                }
                .buttonStyle(GalaxyOrbButtonStyle())
            } else {
                NavigationLink(value: goal.id) {
                    orbContent
                }
                .buttonStyle(GalaxyOrbButtonStyle())
            }
        }
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label(lang.t(.deleteOrbLabel), systemImage: "trash")
            }
        }
        .onAppear {
            let duration = Double.random(in: 3.8...5.2)
            withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                floatY = CGFloat.random(in: -6...6)
            }
        }
    }

    private var orbContent: some View {
        VStack(spacing: 16) {
            ZStack {
                if goal.isChallenge {
                    ChallengeOrbGalaxyView(goal: goal, live: live, size: size)
                        .offset(y: floatY)
                } else {
                    regularOrbStack
                        .offset(y: floatY)
                }
            }

            VStack(spacing: 5) {
                Text(goal.title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)

                if goal.isChallenge {
                    Text(challengeSubtitle(live))
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(themeAccent.opacity(0.9))
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                } else {
                    Text("\(Int(progress * 100))% · \(goal.doneTasks)/\(max(goal.totalTasks, 1))")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(themeAccent.opacity(0.9))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background {
                Capsule()
                    .fill(.black.opacity(0.28))
                    .glassEffect(.clear, in: .capsule)
            }
            .overlay {
                Capsule().stroke(themeAccent.opacity(0.2), lineWidth: 1)
            }
            .frame(maxWidth: size * 1.55)
        }
        .contentShape(Rectangle())
    }

    private var regularOrbStack: some View {
        ZStack {
            Ellipse()
                .fill(.black.opacity(0.35))
                .frame(width: size * 0.72, height: size * 0.14)
                .blur(radius: 8)
                .offset(y: size * 0.46)

            Circle()
                .stroke(.white.opacity(0.10), lineWidth: max(1.5, size * 0.016))
                .frame(width: size * 1.08, height: size * 1.08)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    themeAccent.opacity(0.75),
                    style: StrokeStyle(lineWidth: max(2.5, size * 0.022), lineCap: .round)
                )
                .frame(width: size * 1.08, height: size * 1.08)
                .rotationEffect(.degrees(-90))

            PlanetOrbView(
                size: size,
                gradientColors: goal.design.gradientStops.map { $0.swiftUIColor },
                glow: min(goal.design.glow + 0.02, 0.15),
                textureAssetName: goal.design.textureAssetName,
                textureOpacity: min(goal.design.textureOpacity, 0.65),
                autoSpin: true
            )
        }
    }

    private func challengeSubtitle(_ live: ChallengeLiveState?) -> String {
        if let live {
            if live.waitingForOpponent {
                if let code = goal.challengeInfo?.challengeID {
                    return code
                }
                return lang.t(.challengeWaiting)
            }
            if live.isFinished {
                return live.iWon ? lang.t(.challengeYouWon) : lang.challengeFriendWon(live.opponentName)
            }
            return "\(Int(live.myProgress * 100))% \(lang.t(.raceVS)) \(Int(live.opponentProgress * 100))%"
        }
        return goal.challengeInfo?.challengeID ?? lang.t(.challengeWaiting)
    }
}

private struct GalaxyOrbButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .animation(.spring(response: 0.28, dampingFraction: 0.72), value: configuration.isPressed)
    }
}
