//
//  FriendsArenaScene.swift
//  todoTask
//

import SwiftUI

struct FriendsArenaView: View {
    @EnvironmentObject private var lang: LanguageManager

    let onCreate: () -> Void
    let onJoin: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 20) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 42))
                    .foregroundStyle(.cyan)
                    .padding(20)
                    .background(Circle().fill(.cyan.opacity(0.12)))

                VStack(spacing: 8) {
                    Text(lang.t(.friendsHeroTitle))
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text(lang.t(.friendsHeroSubtitle))
                        .font(.system(size: 15))
                        .foregroundStyle(.white.opacity(0.55))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 12)
                }
            }

            Spacer()

            VStack(spacing: 12) {
                Button(action: onCreate) {
                    Text(lang.t(.friendsCreate))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color("accent"))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)

                Button(action: onJoin) {
                    Text(lang.t(.friendsJoin))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.9))
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .overlay {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(.white.opacity(0.22), lineWidth: 1)
                        }
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 110)
        }
    }
}
