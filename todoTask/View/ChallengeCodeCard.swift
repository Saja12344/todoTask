//
//  ChallengeCodeCard.swift
//  todoTask
//

import SwiftUI

/// Compact glass invite row — used while waiting for opponent on an active challenge.
struct ChallengeCodeCard: View {
    @EnvironmentObject private var lang: LanguageManager
    let roomId: String
    var subtitle: String? = nil
    var fromUsername: String = ""

    @State private var copied = false
    private var accent: Color { Color("accent") }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let subtitle {
                Text(subtitle)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.48))
            }

            HStack(spacing: 10) {
                Button { presentShare() } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                        Text(lang.t(.challengeShareInvite))
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                }
                .background {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(accent.opacity(0.20))
                        .glassEffect(.clear.tint(accent.opacity(0.16)).interactive(), in: .rect(cornerRadius: 14))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(accent.opacity(0.30), lineWidth: 1)
                }
                .buttonStyle(.plain)

                Button { copyInvite() } label: {
                    Text(copied ? "✓" : lang.t(.challengeCopyInvite))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(copied ? .green : .white.opacity(0.85))
                        .frame(width: 64, height: 46)
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
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.black.opacity(0.18))
                .glassEffect(.clear.tint(Color.black.opacity(0.22)), in: .rect(cornerRadius: 18))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.white.opacity(0.10), lineWidth: 1)
        }
    }

    private func copyInvite() {
        UIPasteboard.general.string = DeepLinkManager.shared.inviteMessage(
            roomId: roomId,
            fromUsername: fromUsername,
            lang: lang
        )
        withAnimation(.easeInOut(duration: 0.2)) { copied = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { copied = false }
        }
    }

    private func presentShare() {
        SharePresenter.present(items: DeepLinkManager.shared.shareItems(
            roomId: roomId,
            fromUsername: fromUsername,
            lang: lang
        ))
    }
}
