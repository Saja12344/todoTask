//
//  CreateChallengeSheet.swift
//  todoTask
//

import SwiftUI

private enum CreateChallengeStep {
    case form
    case success(roomId: String)
}

struct CreateChallengeSheet: View {
    @EnvironmentObject private var userVM: UserViewModel
    @EnvironmentObject private var lang: LanguageManager
    @ObservedObject var store: OrbGoalStore
    let onCreated: (String) -> Void

    @State private var step: CreateChallengeStep = .form
    @State private var isLoading = false
    @State private var error: String?
    @State private var selectedGoalID: UUID?
    @Environment(\.dismiss) private var dismiss

    private let service = ChallengeService()

    /// Only the user's own real orbs can be used as a challenge planet.
    private var pickableGoals: [OrbGoal] { store.goals.filter { !$0.isChallenge } }

    private var bestGoal: OrbGoal? {
        if let id = selectedGoalID, let g = pickableGoals.first(where: { $0.id == id }) { return g }
        return pickableGoals.first
    }

    var body: some View {
        ZStack {
            ClassicOrbitBackground(includeBackgroundImage: false)

            switch step {
            case .form:
                formContent
            case .success(let roomId):
                successContent(roomId: roomId)
            }
        }
        .orbitForcedDark()
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private var formContent: some View {
        VStack(spacing: 24) {
            Capsule()
                .fill(Color.white.opacity(0.2))
                .frame(width: 44, height: 4)
                .padding(.top, 16)

            Text(lang.t(.challengeNew))
                .font(.title2.bold())
                .foregroundStyle(.white)

            if let goal = bestGoal {
                ZStack {
                    Ellipse()
                        .stroke(goal.accentColor.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [5, 7]))
                        .frame(width: 180, height: 60)

                    PlanetOrbView(
                        size: 100,
                        gradientColors: goal.design.gradientStops.map { $0.swiftUIColor },
                        glow: goal.design.glow,
                        textureAssetName: goal.design.textureAssetName,
                        textureOpacity: goal.design.textureOpacity,
                        autoSpin: true
                    )
                }

                Text(goal.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text(lang.t(.challengeCompetingFor))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))

                if pickableGoals.count > 1 {
                    planetPicker(current: goal)
                }
            } else {
                VStack(spacing: 10) {
                    Image(systemName: "globe.americas.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.white.opacity(0.3))
                    Text(lang.t(.challengeNeedGoal))
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.orange)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .padding(.vertical, 20)
            }

            if let error {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.subheadline.weight(.medium))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            VStack(spacing: 14) {
                Button {
                    Task { await create() }
                } label: {
                    Group {
                        if isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text(lang.t(.challengeCreateSend))
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                }
                .background(
                    LinearGradient(colors: [Color("accent"), .cyan.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .disabled(isLoading || bestGoal == nil)

                Button(lang.t(.cancel)) { dismiss() }
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(.horizontal, 28)

            Spacer()
        }
    }

    private func planetPicker(current: OrbGoal) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(pickableGoals) { g in
                    let isSelected = g.id == current.id
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.78)) {
                            selectedGoalID = g.id
                        }
                    } label: {
                        VStack(spacing: 6) {
                            PlanetOrbView(
                                size: 48,
                                gradientColors: g.design.gradientStops.map { $0.swiftUIColor },
                                glow: g.design.glow,
                                textureAssetName: g.design.textureAssetName,
                                textureOpacity: g.design.textureOpacity
                            )
                            .frame(width: 54, height: 54)
                            .overlay {
                                Circle()
                                    .stroke(Color("accent").opacity(isSelected ? 0.95 : 0), lineWidth: 2.5)
                                    .padding(-3)
                            }

                            Text(g.title)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(.white.opacity(isSelected ? 0.95 : 0.55))
                                .lineLimit(1)
                                .frame(maxWidth: 66)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 4)
        }
    }

    private func successContent(roomId: String) -> some View {
        VStack(spacing: 28) {
            Capsule()
                .fill(Color.white.opacity(0.2))
                .frame(width: 44, height: 4)
                .padding(.top, 16)

            Text("🪐")
                .font(.system(size: 48))

            Text(lang.t(.challengeCreatedTitle))
                .font(.title2.bold())
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            ChallengeCodeCard(roomId: roomId)
                .padding(.horizontal, 24)

            Text(lang.t(.challengeCreatedHint))
                .font(.caption)
                .foregroundStyle(.white.opacity(0.45))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button {
                onCreated(roomId)
                dismiss()
            } label: {
                Text(lang.t(.challengeGoToOrbs))
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
            }
            .background(Color("accent"))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 28)

            Spacer()
        }
    }

    private func create() async {
        guard let user = userVM.currentUser else {
            error = lang.t(.challengeLoginRequired)
            return
        }
        guard let goal = bestGoal else {
            error = lang.t(.challengeNeedGoal)
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
            let challengeGoal = ChallengeOrbFactory.fromSourceGoal(goal, roomId: roomId, myId: user.id)
            store.addChallengeOrb(challengeGoal, myId: user.id)
            withAnimation { step = .success(roomId: roomId) }
        } catch {
            self.error = lang.t(.challengeErrorGeneric)
        }
        isLoading = false
    }
}
