//
//  CreateChallengeSheet.swift
//  todoTask
//

import SwiftUI

struct CreateChallengeSheet: View {
    @EnvironmentObject private var userVM: UserViewModel
    @EnvironmentObject private var lang: LanguageManager
    @ObservedObject var store: OrbGoalStore
    let onCreated: (String) -> Void

    @State private var isLoading = false
    @State private var error: String?
    @State private var selectedGoalID: UUID?
    @Environment(\.dismiss) private var dismiss

    private let service = ChallengeService()
    private var accent: Color { Color("accent") }

    private var pickableGoals: [OrbGoal] { store.goals.filter { !$0.isChallenge } }

    private var bestGoal: OrbGoal? {
        if let id = selectedGoalID, let g = pickableGoals.first(where: { $0.id == id }) { return g }
        return pickableGoals.first
    }

    var body: some View {
        ZStack {
            ClassicOrbitBackground(includeBackgroundImage: false)

            VStack(spacing: 0) {
                Capsule()
                    .fill(.white.opacity(0.22))
                    .frame(width: 40, height: 4)
                    .padding(.top, 10)
                    .padding(.bottom, 20)

                VStack(spacing: 22) {
                    if let goal = bestGoal {
                        PlanetOrbView(
                            size: 88,
                            gradientColors: goal.design.gradientStops.map { $0.swiftUIColor },
                            glow: goal.design.glow,
                            textureAssetName: goal.design.textureAssetName,
                            textureOpacity: goal.design.textureOpacity,
                            autoSpin: true
                        )

                        Text(goal.title)
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .lineLimit(1)

                        if pickableGoals.count > 1 {
                            planetPicker(current: goal)
                        }
                    } else {
                        Image(systemName: "globe.americas.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(.white.opacity(0.28))
                        Text(lang.t(.challengeNeedGoal))
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.orange)
                            .multilineTextAlignment(.center)
                    }

                    if let error {
                        Text(error)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.red.opacity(0.9))
                            .multilineTextAlignment(.center)
                    }

                    Button {
                        Task { await createAndShare() }
                    } label: {
                        Group {
                            if isLoading {
                                ProgressView().tint(.white)
                            } else {
                                HStack(spacing: 8) {
                                    Image(systemName: "square.and.arrow.up")
                                    Text(lang.t(.challengeCreateSend))
                                }
                                .font(.system(size: 16, weight: .semibold))
                            }
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                    }
                    .background {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(accent.opacity(0.22))
                            .glassEffect(.clear.tint(accent.opacity(0.18)).interactive(), in: .rect(cornerRadius: 16))
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(accent.opacity(0.35), lineWidth: 1)
                    }
                    .disabled(isLoading || bestGoal == nil)
                    .opacity(bestGoal == nil ? 0.45 : 1)

                    Button(lang.t(.cancel)) { dismiss() }
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.45))
                }
                .padding(22)
                .challengeGlassPanel()

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 22)
        }
        .orbitForcedDark()
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
    }

    private func planetPicker(current: OrbGoal) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(pickableGoals) { g in
                    let isSelected = g.id == current.id
                    Button {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.8)) {
                            selectedGoalID = g.id
                        }
                    } label: {
                        PlanetOrbView(
                            size: 40,
                            gradientColors: g.design.gradientStops.map { $0.swiftUIColor },
                            glow: g.design.glow,
                            textureAssetName: g.design.textureAssetName,
                            textureOpacity: g.design.textureOpacity
                        )
                        .frame(width: 48, height: 48)
                        .overlay {
                            Circle()
                                .stroke(accent.opacity(isSelected ? 0.9 : 0), lineWidth: 2)
                                .padding(-2)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 4)
        }
    }

    private func createAndShare() async {
        guard let user = userVM.currentUser else {
            error = lang.t(.challengeLoginRequired)
            return
        }
        guard let goal = bestGoal else {
            error = lang.t(.challengeNeedGoal)
            return
        }
        guard !goal.isChallenge else {
            error = lang.t(.challengeAlreadyActive)
            return
        }

        isLoading = true
        error = nil

        do {
            let roomId = try await service.createRoom(
                userId: user.id,
                userName: user.username,
                orbDesign: goal.design,
                orbTasks: [goal],
                language: lang.language
            )
            store.convertGoalToChallenge(goalID: goal.id, roomId: roomId, myId: user.id)

            let items = DeepLinkManager.shared.shareItems(
                roomId: roomId,
                fromUsername: user.username,
                lang: lang
            )
            onCreated(roomId)
            dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                SharePresenter.present(items: items)
            }
        } catch {
            self.error = lang.t(.challengeErrorGeneric)
        }
        isLoading = false
    }
}

private extension View {
    func challengeGlassPanel(cornerRadius: CGFloat = 24) -> some View {
        background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.black.opacity(0.20))
                .glassEffect(.clear.tint(Color.black.opacity(0.26)), in: .rect(cornerRadius: cornerRadius))
        }
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(.white.opacity(0.10), lineWidth: 1)
        }
    }
}
