//
//  JoinChallengeSheet.swift
//  todoTask
//

import SwiftUI

struct JoinChallengeSheet: View {
    @EnvironmentObject private var userVM: UserViewModel
    @EnvironmentObject private var lang: LanguageManager
    @ObservedObject var store: OrbGoalStore
    let onJoined: (String) -> Void

    @State private var code = ""
    @State private var isLoading = false
    @State private var error: String?
    @Environment(\.dismiss) private var dismiss

    private let service = ChallengeService()

    var body: some View {
        ZStack {
            ClassicOrbitBackground(includeBackgroundImage: false)

            VStack(spacing: 24) {
                Capsule()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 44, height: 4)
                    .padding(.top, 16)

                Image(systemName: "link.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.cyan)

                Text(lang.t(.challengeJoin))
                    .font(.title2.bold())
                    .foregroundStyle(.white)

                Text(lang.t(.challengeJoinHint))
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.55))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                TextField(lang.t(.challengeCodePlaceholder), text: $code)
                    .textFieldStyle(.plain)
                    .font(.system(size: 20, weight: .semibold, design: .monospaced))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .padding()
                    .glassEffect(.clear, in: .rect(cornerRadius: 16))
                    .padding(.horizontal, 28)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.characters)

                if let error {
                    Text(error).foregroundStyle(.red).font(.caption)
                }

                Button {
                    Task { await join() }
                } label: {
                    Group {
                        if isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text(lang.t(.challengeJoinNow))
                                .font(.system(size: 17, weight: .semibold))
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                }
                .background(Color("accent"))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .disabled(code.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
                .padding(.horizontal, 28)

                Button(lang.t(.cancel)) { dismiss() }
                    .foregroundStyle(.white.opacity(0.5))

                Spacer()
            }
        }
        .orbitForcedDark()
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func join() async {
        guard let user = userVM.currentUser else {
            error = lang.t(.challengeLoginRequired)
            return
        }
        let trimmed = code.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        isLoading = true
        error = nil
        do {
            try await service.joinRoom(roomId: trimmed, userId: user.id, userName: user.username)
            let room = try await service.fetchRoom(roomId: trimmed)
            let challengeGoal = ChallengeOrbFactory.fromRoom(room, roomId: trimmed, myId: user.id)
            store.addChallengeOrb(challengeGoal, myId: user.id)
            onJoined(trimmed)
        } catch {
            self.error = lang.t(.challengeInvalidCode)
        }
        isLoading = false
    }
}
