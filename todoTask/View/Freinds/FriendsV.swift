//
//  FriendsV.swift
//  todoTask
//

import SwiftUI

struct FriendsV: View {
    @EnvironmentObject private var store: OrbGoalStore
    @EnvironmentObject private var lang: LanguageManager
    @EnvironmentObject private var userVM: UserViewModel
    @EnvironmentObject private var tabRouter: OrbitTabRouter
    @State private var showCreate = false
    @State private var showJoin   = false
    @State private var bannerMessage: String?
    @State private var activeRoomCode: String?

    var body: some View {
        ZStack {
            ClassicOrbitBackground()

            VStack(spacing: 32) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(Color("accent").opacity(0.14))
                        .frame(width: 118, height: 118)
                    Circle()
                        .stroke(Color("accent").opacity(0.28), lineWidth: 1)
                        .frame(width: 118, height: 118)
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 46, weight: .semibold))
                        .foregroundStyle(Color("accent"))
                }

                VStack(spacing: 10) {
                    Text(lang.t(.friendsHeroTitle))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text(lang.t(.friendsHeroSubtitle))
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white.opacity(0.58))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                }

                if let activeRoomCode {
                    ChallengeCodeCard(roomId: activeRoomCode, subtitle: lang.t(.challengeShareActive))
                        .padding(.horizontal, 24)
                } else if let bannerMessage {
                    Text(bannerMessage)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color("accent"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                VStack(spacing: 14) {
                    Button { showCreate = true } label: {
                        Label(lang.t(.friendsCreate), systemImage: "plus.circle.fill")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .glassEffect(.clear.tint(Color("accent").opacity(0.55)).interactive(), in: .rect(cornerRadius: 16))
                            .overlay {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color("accent").opacity(0.55), lineWidth: 1)
                            }
                    }
                    .buttonStyle(.plain)

                    Button { showJoin = true } label: {
                        Label(lang.t(.friendsJoin), systemImage: "link")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .glassEffect(.clear.interactive(), in: .rect(cornerRadius: 16))
                            .overlay {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(.white.opacity(0.18), lineWidth: 1)
                            }
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 28)

                Text(lang.t(.friendsStep3))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Spacer()
            }
        }
        .orbitForcedDark()
        .sheet(isPresented: $showCreate) {
            CreateChallengeSheet(store: store) { roomId in
                showCreate = false
                activeRoomCode = roomId
                tabRouter.openOrbs()
                bannerMessage = lang.t(.challengeOrbAdded)
            }
            .environmentObject(lang)
            .environmentObject(userVM)
            .environmentObject(store)
        }
        .sheet(isPresented: $showJoin) {
            JoinChallengeSheet(store: store) { roomId in
                showJoin = false
                tabRouter.openOrbs()
                bannerMessage = lang.t(.challengeOrbAdded)
            }
            .environmentObject(lang)
            .environmentObject(userVM)
            .environmentObject(store)
        }
    }
}

struct RoomID: Identifiable { let id: String }
