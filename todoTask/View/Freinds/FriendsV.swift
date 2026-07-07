//
//  FriendsV.swift
//  todoTask
//

import SwiftUI

private enum FriendsPanel: String, CaseIterable {
    case start
    case join
}

struct FriendsV: View {
    @EnvironmentObject private var store: OrbGoalStore
    @EnvironmentObject private var lang: LanguageManager
    @EnvironmentObject private var userVM: UserViewModel
    @EnvironmentObject private var tabRouter: OrbitTabRouter

    @State private var panel: FriendsPanel = .start
    @State private var selectedGoalID: UUID?
    @State private var joinCode = ""
    @State private var isCreating = false
    @State private var isJoining = false
    @State private var createError: String?
    @State private var joinError: String?
    @State private var createdRoomId: String?

    private let service = ChallengeService()
    private var accent: Color { Color("accent") }

    private var pickableGoals: [OrbGoal] { store.goals.filter { !$0.isChallenge } }

    private var selectedGoal: OrbGoal? {
        if let id = selectedGoalID, let g = pickableGoals.first(where: { $0.id == id }) { return g }
        return pickableGoals.first
    }

    var body: some View {
        ZStack {
            FriendsChallengeBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    panelPicker

                    switch panel {
                    case .start:
                        startPanel
                    case .join:
                        joinPanel
                    }
                }
                .padding(.horizontal, 22)
                .padding(.top, 8)
                .padding(.bottom, 36)
            }
        }
        .orbitForcedDark()
        .toolbarBackground(.hidden, for: .navigationBar)
        .animation(.easeInOut(duration: 0.25), value: panel)
        .animation(.easeInOut(duration: 0.25), value: createdRoomId)
    }

    // MARK: - Panels

    private var panelPicker: some View {
        Picker("", selection: $panel) {
            Text(lang.t(.friendsCreate)).tag(FriendsPanel.start)
            Text(lang.t(.friendsJoin)).tag(FriendsPanel.join)
        }
        .pickerStyle(.segmented)
    }

    // MARK: - Start challenge

    @ViewBuilder
    private var startPanel: some View {
        if let roomId = createdRoomId {
            createdPanel(roomId: roomId)
        } else {
            createFormPanel
        }
    }

    private var createFormPanel: some View {
        VStack(spacing: 18) {
            if let goal = selectedGoal {
                VStack(spacing: 12) {
                    PlanetOrbView(
                        size: 92,
                        gradientColors: goal.design.gradientStops.map { $0.swiftUIColor },
                        glow: goal.design.glow,
                        textureAssetName: goal.design.textureAssetName,
                        textureOpacity: goal.design.textureOpacity,
                        autoSpin: true
                    )

                    Text(goal.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    if pickableGoals.count > 1 {
                        planetPicker(current: goal)
                    }
                }
            } else {
                VStack(spacing: 10) {
                    Image(systemName: "globe.americas.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(.white.opacity(0.28))
                    Text(lang.t(.challengeNeedGoal))
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.orange)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 12)
            }

            if let createError {
                Text(createError)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.red.opacity(0.9))
                    .multilineTextAlignment(.center)
            }

            Button {
                Task { await createChallenge() }
            } label: {
                Group {
                    if isCreating {
                        ProgressView().tint(.white)
                    } else {
                        Label(lang.t(.challengeCreateSend), systemImage: "bolt.fill")
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
            .buttonStyle(.plain)
            .disabled(isCreating || selectedGoal == nil)
            .opacity(selectedGoal == nil ? 0.45 : 1)
        }
        .padding(20)
        .friendsGlassPanel()
    }

    private func createdPanel(roomId: String) -> some View {
        VStack(spacing: 14) {
            ChallengeCodeCard(
                roomId: roomId,
                fromUsername: userVM.currentUser?.username ?? ""
            )
            .environmentObject(lang)

            Button {
                tabRouter.openOrbs()
            } label: {
                Text(lang.t(.challengeGoToOrbs))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.85))
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
            }
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.white.opacity(0.05))
                    .glassEffect(.clear.interactive(), in: .rect(cornerRadius: 14))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(.white.opacity(0.12), lineWidth: 1)
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .friendsGlassPanel()
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
                        VStack(spacing: 5) {
                            PlanetOrbView(
                                size: 44,
                                gradientColors: g.design.gradientStops.map { $0.swiftUIColor },
                                glow: g.design.glow,
                                textureAssetName: g.design.textureAssetName,
                                textureOpacity: g.design.textureOpacity
                            )
                            .frame(width: 50, height: 50)
                            .overlay {
                                Circle()
                                    .stroke(accent.opacity(isSelected ? 0.9 : 0), lineWidth: 2)
                                    .padding(-2)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Join challenge

    private var joinPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(lang.t(.challengeCodeLabel))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)

            TextField(lang.t(.challengeCodePlaceholder), text: $joinCode)
                .textFieldStyle(.plain)
                .font(.system(size: 18, weight: .semibold, design: .monospaced))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                .background {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(.white.opacity(0.05))
                        .glassEffect(.clear, in: .rect(cornerRadius: 14))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(.white.opacity(0.12), lineWidth: 1)
                }
                .autocorrectionDisabled()
                .textInputAutocapitalization(.characters)

            if let joinError {
                Text(joinError)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.red.opacity(0.9))
            }

            Button {
                Task { await joinChallenge() }
            } label: {
                Group {
                    if isJoining {
                        ProgressView().tint(.white)
                    } else {
                        Text(lang.t(.challengeJoinNow))
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
            .buttonStyle(.plain)
            .disabled(joinCode.trimmingCharacters(in: .whitespaces).isEmpty || isJoining)
            .opacity(joinCode.trimmingCharacters(in: .whitespaces).isEmpty ? 0.45 : 1)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .friendsGlassPanel()
    }

    private func createChallenge() async {
        guard let user = userVM.currentUser else {
            createError = lang.t(.challengeLoginRequired)
            return
        }
        guard let goal = selectedGoal else {
            createError = lang.t(.challengeNeedGoal)
            return
        }
        guard !goal.isChallenge else {
            createError = lang.t(.challengeAlreadyActive)
            return
        }

        isCreating = true
        createError = nil

        do {
            let roomId = try await service.createRoom(
                userId: user.id,
                userName: user.username,
                orbDesign: goal.design,
                orbTasks: [goal],
                language: lang.language
            )
            store.convertGoalToChallenge(goalID: goal.id, roomId: roomId, myId: user.id)
            withAnimation { createdRoomId = roomId }
        } catch {
            createError = lang.t(.challengeErrorGeneric)
        }
        isCreating = false
    }

    private func joinChallenge() async {
        guard let user = userVM.currentUser else {
            joinError = lang.t(.challengeLoginRequired)
            return
        }
        let trimmed = joinCode.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        isJoining = true
        joinError = nil

        do {
            try await service.joinRoom(roomId: trimmed, userId: user.id, userName: user.username)
            let room = try await service.fetchRoom(roomId: trimmed)
            let challengeGoal = ChallengeOrbFactory.fromRoom(room, roomId: trimmed, myId: user.id)
            store.addChallengeOrb(challengeGoal, myId: user.id)
            joinCode = ""
            tabRouter.openOrbs()
        } catch {
            joinError = lang.t(.challengeInvalidCode)
        }
        isJoining = false
    }
}

private extension View {
    func friendsGlassPanel(cornerRadius: CGFloat = 22) -> some View {
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

struct RoomID: Identifiable { let id: String }
