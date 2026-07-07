//
//  ChallengeCodeCard.swift
//  todoTask
//

import SwiftUI

struct ChallengeCodeCard: View {
    @EnvironmentObject private var lang: LanguageManager
    let roomId: String
    var subtitle: String? = nil

    @State private var copied = false

    var body: some View {
        VStack(spacing: 12) {
            Text(subtitle ?? lang.t(.challengeSendCode))
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.55))
                .multilineTextAlignment(.center)

            Text(roomId)
                .font(.system(size: 22, weight: .bold, design: .monospaced))
                .foregroundStyle(Color("accent"))
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.white.opacity(0.08))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color("accent").opacity(0.35), lineWidth: 1)
                        }
                }
                .onTapGesture {
                    UIPasteboard.general.string = roomId
                    copied = true
                }

            Button {
                UIPasteboard.general.string = roomId
                copied = true
            } label: {
                Label(copied ? lang.t(.challengeCopied) : lang.t(.challengeCopyCode), systemImage: copied ? "checkmark" : "doc.on.doc")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(copied ? .green : Color("accent"))
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(0.06))
        }
    }
}
