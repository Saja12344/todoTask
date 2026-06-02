//
//  ChallengeOrbitView.swift
//  todoTask
//
//  Created by شهد عبدالله القحطاني on 16/12/1447 AH.
//


//  ChallengeOrbitView.swift
//  todoTask

import SwiftUI

struct ChallengeOrbitView: View {
    @EnvironmentObject private var userVM: UserViewModel
    let winner: ChallengeWinner
    let isMyWin: Bool
    let onDismiss: () -> Void

    @State private var orbitAngle: Double = 0
    @State private var showCard = false
    @State private var saved = false

    private let service = ChallengeService()

    var planetColors: [Color] {
        winner.planetGradient.map { Color(hex: $0) ?? .purple }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            StarsBackgroundView()

            VStack(spacing: 0) {

                // عنوان
                Text(isMyWin ? "فزت بالكوكب!" : "\(winner.name) فاز بالكوكب")
                    .font(.title2.bold())
                    .foregroundColor(isMyWin ? .yellow : .white.opacity(0.6))
                    .padding(.top, 52)

                Text(isMyWin ? winner.planetName : "أكمل أكثر في المرة القادمة")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.45))
                    .padding(.top, 6)

                Spacer()

                // مشهد الـ Orbit
                ZStack {
                    // مدار
                    Circle()
                        .stroke(Color.white.opacity(0.12),
                                style: StrokeStyle(lineWidth: 1, dash: [6, 5]))
                        .frame(width: 270, height: 270)

                    // الكوكب
                    PlanetOrbView(
                        size: 120,
                        gradientColors: planetColors,
                        glow: winner.planetGlow,
                        textureAssetName: winner.planetTextureAsset,
                        textureOpacity: winner.planetTextureOpacity
                    )

                    // صاروخ يدور
                    RocketSprite(
                        color: isMyWin ? .purple : .teal,
                        label: "",
                        progress: 1.0
                    )
                    .rotationEffect(.degrees(-90))
                    .offset(x: 135)
                    .rotationEffect(.degrees(orbitAngle),
                                    anchor: .init(x: 0.5, y: 0.5))
                }
                .frame(width: 290, height: 290)

                Spacer()

                // بطاقة المعلومات
                if showCard {
                    PlanetWinCard(
                        winner: winner,
                        isMyWin: isMyWin,
                        saved: saved
                    )
                    .padding(.horizontal, 24)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                // أزرار
                VStack(spacing: 12) {
                    if isMyWin && !saved {
                        Button {
                            Task { await saveWin() }
                        } label: {
                            Label("احتفظ بالكوكب", systemImage: "star.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity).frame(height: 52)
                        }
                        .background(Color.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 28)
                    }

                    Button("العودة للرئيسية") { onDismiss() }
                        .foregroundColor(.white.opacity(0.5))
                        .font(.subheadline)
                }
                .padding(.bottom, 44)
            }
        }
        .colorScheme(.dark)
        .onAppear {
            // تحريك الصاروخ في المدار
            withAnimation(.linear(duration: 7).repeatForever(autoreverses: false)) {
                orbitAngle = 360
            }
            // ظهور البطاقة
            withAnimation(.spring(duration: 0.7).delay(0.4)) {
                showCard = true
            }
        }
    }

    private func saveWin() async {
        try? await service.savePlanetToWinner(winner: winner)
        withAnimation { saved = true }
    }
}

struct PlanetWinCard: View {
    let winner: ChallengeWinner
    let isMyWin: Bool
    let saved: Bool

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: isMyWin ? "crown.fill" : "figure.walk")
                .font(.system(size: 28))
                .foregroundColor(isMyWin ? .yellow : .white.opacity(0.4))

            VStack(alignment: .leading, spacing: 4) {
                Text(isMyWin ? "الكوكب أصبح ملكك" : "أفضل حظاً المرة القادمة")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                if isMyWin {
                    Text(saved ? "محفوظ في مجموعتك" : winner.planetName)
                        .font(.caption).foregroundColor(.white.opacity(0.5))
                }
            }
            Spacer()
            if saved {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green).font(.system(size: 22))
            }
        }
        .padding(18)
        .glassEffect(.clear.tint(.darkBlu.opacity(0.5)), in: .rect(cornerRadius: 18))
    }
}