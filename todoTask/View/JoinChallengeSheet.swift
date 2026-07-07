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
    private var accent: Color { Color("accent") }

    var body: some View {
        ZStack {
            ClassicOrbitBackground(includeBackgroundImage: false)

            VStack(spacing: 0) {
                Capsule()
                    .fill(.white.opacity(0.22))
                    .frame(width: 40, height: 4)
                    .padding(.top, 10)
                    .padding(.bottom, 20)

                VStack(spacing: 20) {
                    Image(systemName: "link")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(accent)

                    Text(lang.t(.challengeJoin))
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    TextField(lang.t(.challengeCodePlaceholder), text: $code)
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

                    if let error {
                        Text(error)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.red.opacity(0.9))
                    }

                    Button {
                        Task { await join() }
                    } label: {
                        Group {
                            if isLoading {
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
                    .disabled(code.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
                    .opacity(code.trimmingCharacters(in: .whitespaces).isEmpty ? 0.45 : 1)

                    Button(lang.t(.cancel)) { dismiss() }
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.45))
                }
                .padding(22)
                .joinGlassPanel()

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 22)
        }
        .orbitForcedDark()
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
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
            dismiss()
        } catch {
            self.error = lang.t(.challengeInvalidCode)
        }
        isLoading = false
    }
}

private extension View {
    func joinGlassPanel(cornerRadius: CGFloat = 24) -> some View {
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
