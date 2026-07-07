//
//  ChallengeOrbGalaxyView.swift
//  todoTask
//

import SwiftUI

/// Challenge planet with two glowing orbit markers (no rockets).
struct ChallengeOrbGalaxyView: View {
    let goal: OrbGoal
    let live: ChallengeLiveState?
    let size: CGFloat

    private var myProgress: Double { live?.myProgress ?? 0 }
    private var opponentProgress: Double { live?.opponentProgress ?? goal.challengeInfo?.friendProgress ?? 0 }
    private var waiting: Bool { live?.waitingForOpponent ?? (goal.challengeInfo != nil) }
    private var orbitRadius: CGFloat { size * 0.58 }
    private var planetSize: CGFloat { size * 0.52 }

    var body: some View {
        ZStack {
            Ellipse()
                .fill(.black.opacity(0.35))
                .frame(width: size * 0.72, height: size * 0.14)
                .blur(radius: 8)
                .offset(y: size * 0.46)

            Circle()
                .stroke(Color("accent").opacity(0.15), lineWidth: 1)
                .frame(width: orbitRadius * 2.15, height: orbitRadius * 2.15)

            Circle()
                .stroke(.white.opacity(0.10), style: StrokeStyle(lineWidth: 1.5, dash: [5, 7]))
                .frame(width: orbitRadius * 2, height: orbitRadius * 2)

            GalaxyOrbitArc(progress: myProgress, radius: orbitRadius, color: Color("accent"))
            GalaxyOrbitArc(progress: opponentProgress, radius: orbitRadius, color: .white.opacity(0.38))
                .opacity(waiting ? 0.3 : 1)

            PlanetOrbView(
                size: planetSize,
                gradientColors: goal.design.gradientStops.map { $0.swiftUIColor },
                glow: min(goal.design.glow + 0.02, 0.15),
                textureAssetName: goal.design.textureAssetName,
                textureOpacity: min(goal.design.textureOpacity, 0.65),
                autoSpin: true
            )

            GalaxyOrbitMarker(
                color: Color("accent"),
                progress: myProgress,
                radius: orbitRadius,
                startOffset: -90,
                label: "●",
                isWinner: live?.iWon == true
            )

            GalaxyOrbitMarker(
                color: .white.opacity(0.55),
                progress: waiting ? 0 : opponentProgress,
                radius: orbitRadius,
                startOffset: 90,
                dimmed: waiting,
                label: "●",
                isWinner: live?.isFinished == true && live?.iWon == false
            )
        }
        .frame(width: size * 1.25, height: size * 1.25)
    }
}

struct GalaxyOrbitArc: View {
    let progress: Double
    let radius: CGFloat
    let color: Color

    var body: some View {
        Circle()
            .trim(from: 0, to: max(0.001, progress))
            .stroke(
                color.opacity(0.55),
                style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
            )
            .frame(width: radius * 2, height: radius * 2)
            .rotationEffect(.degrees(-90))
            .animation(.spring(response: 0.45, dampingFraction: 0.78), value: progress)
    }
}

struct GalaxyOrbitMarker: View {
    let color: Color
    let progress: Double
    let radius: CGFloat
    var startOffset: Double = -90
    var dimmed: Bool = false
    var label: String = "●"
    var isWinner: Bool = false

    @State private var pulse = false

    private var angle: Double { progress * 360 + startOffset }

    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.22))
                .frame(width: pulse ? 26 : 20, height: pulse ? 26 : 20)
                .blur(radius: 2)

            Circle()
                .fill(color)
                .frame(width: 11, height: 11)
                .overlay {
                    Circle()
                        .stroke(.white.opacity(0.55), lineWidth: 1.5)
                }
                .shadow(color: color.opacity(0.7), radius: 6)

            if isWinner {
                Image(systemName: "star.fill")
                    .font(.system(size: 9))
                    .foregroundStyle(.yellow)
                    .offset(y: -16)
            }
        }
        .opacity(dimmed ? 0.35 : 1)
        .offset(x: radius)
        .rotationEffect(.degrees(angle))
        .animation(.spring(response: 0.5, dampingFraction: 0.78), value: progress)
        .onAppear {
            guard !dimmed else { return }
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}
