//
//  ChallengeOrbitView.swift
//  todoTask
//

import SwiftUI

struct ChallengeOrbitView: View {
    @EnvironmentObject private var lang: LanguageManager
    let winner: ChallengeWinner
    let isMyWin: Bool
    let onDismiss: () -> Void

    @State private var orbitAngle: Double = 0
    @State private var showCard = false
    @State private var saved = false
    @State private var burst = false

    private let service = ChallengeService()

    var planetColors: [Color] {
        winner.planetGradient.map { Color(hex: $0) ?? .purple }
    }

    var body: some View {
        ZStack {
            ClassicOrbitBackground()

            WinBackdrop(tint: planetColors.first ?? .purple)

            VStack(spacing: 0) {
                Text(isMyWin ? lang.t(.challengeYouWon) : lang.challengeFriendWon(winner.name))
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(isMyWin ? .yellow : .white.opacity(0.75))
                    .padding(.top, 56)

                Text(isMyWin ? winner.localizedPlanetName(language: lang.language) : lang.t(.challengeTryAgain))
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.top, 6)

                Spacer()

                ZStack {
                    ForEach(0..<3, id: \.self) { ring in
                        Circle()
                            .stroke(
                                (planetColors.first ?? .purple).opacity(0.12 + Double(ring) * 0.06),
                                style: StrokeStyle(lineWidth: 1, dash: [5, 6])
                            )
                            .frame(width: 250 + CGFloat(ring * 40), height: 250 + CGFloat(ring * 40))
                            .scaleEffect(burst ? 1.04 : 0.96)
                    }

                    PlanetOrbView(
                        size: 130,
                        gradientColors: planetColors,
                        glow: winner.planetGlow + (isMyWin ? 0.04 : 0),
                        textureAssetName: winner.planetTextureAsset,
                        textureOpacity: winner.planetTextureOpacity
                    )
                    .shadow(color: (planetColors.first ?? .purple).opacity(0.5), radius: 28, y: 10)

                    RocketSprite(color: isMyWin ? .purple : .teal, label: "", progress: 1.0)
                        .scaleEffect(0.9)
                        .rotationEffect(.degrees(-90))
                        .offset(x: 145)
                        .rotationEffect(.degrees(orbitAngle))
                }
                .frame(width: 300, height: 300)

                Spacer()

                if showCard {
                    PlanetWinCard(winner: winner, isMyWin: isMyWin, saved: saved, lang: lang)
                        .padding(.horizontal, 24)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                VStack(spacing: 12) {
                    if isMyWin && !saved {
                        Button {
                            Task { await saveWin() }
                        } label: {
                            Label(lang.t(.challengeKeepPlanet), systemImage: "star.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                        }
                        .background(
                            LinearGradient(colors: [.yellow.opacity(0.85), .orange.opacity(0.75)], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 28)
                    }

                    Button(lang.t(.challengeBackHome), action: onDismiss)
                        .foregroundColor(.white.opacity(0.5))
                        .font(.subheadline)
                }
                .padding(.bottom, 44)
            }
        }
        .overlay(alignment: .topLeading) {
            Button(action: onDismiss) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .bold))
                    Text(lang.t(.challengeBackHome))
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(Capsule().fill(.white.opacity(0.12)))
                .overlay(Capsule().stroke(.white.opacity(0.18), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .padding(.leading, 16)
            .padding(.top, 14)
        }
        .orbitForcedDark()
        .onAppear {
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                orbitAngle = 360
            }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                burst = true
            }
            withAnimation(.spring(duration: 0.7).delay(0.4)) {
                showCard = true
            }
        }
    }

    private func saveWin() async {
        try? await service.savePlanetToWinner(winner: winner)
        OrbAchievementStore.shared.addWonPlanet(from: winner)
        withAnimation { saved = true }
    }
}

/// Celebratory "Background 3" artwork framed behind the winning planet.
private struct WinBackdrop: View {
    let tint: Color

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height) * 1.05
            ZStack {
                RadialGradient(
                    colors: [tint.opacity(0.35), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: side * 0.55
                )

                Image("Background 3")
                    .resizable()
                    .scaledToFill()
                    .frame(width: side, height: side)
                    .clipped()
                    .opacity(0.5)
                    .blendMode(.screen)
                    .mask(
                        RadialGradient(
                            stops: [
                                .init(color: .white, location: 0.0),
                                .init(color: .white.opacity(0.6), location: 0.55),
                                .init(color: .clear, location: 1.0)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: side * 0.5
                        )
                    )
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .position(x: geo.size.width / 2, y: geo.size.height * 0.46)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

struct PlanetWinCard: View {
    let winner: ChallengeWinner
    let isMyWin: Bool
    let saved: Bool
    let lang: LanguageManager

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: isMyWin ? "crown.fill" : "figure.walk")
                .font(.system(size: 28))
                .foregroundStyle(isMyWin ? .yellow : .white.opacity(0.4))

            VStack(alignment: .leading, spacing: 4) {
                Text(isMyWin ? lang.t(.challengePlanetYours) : lang.t(.challengeTryAgain))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                if isMyWin {
                    Text(saved ? lang.t(.save) + " ✓" : winner.localizedPlanetName(language: lang.language))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
            Spacer()
            if saved {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.system(size: 22))
            }
        }
        .padding(18)
        .glassEffect(.clear.tint(.darkBlu.opacity(0.5)), in: .rect(cornerRadius: 18))
    }
}
