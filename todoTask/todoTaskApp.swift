//
//  todoTaskApp.swift
//  todoTask
//

import SwiftUI

@main
struct todoTaskApp: App {

    @StateObject private var userVM    = UserViewModel()
    @StateObject private var goalStore = OrbGoalStore()
    @StateObject private var deepLink  = DeepLinkManager.shared
    @State private var showSplash = true

    init() {
        NotificationPermissionManager.shared.requestPermissionIfNeeded()
    }

    var body: some Scene {
            WindowGroup {
                
                if showSplash {
                    SplashScreenView()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                showSplash = false
                            }
                        }
                } else {
                    RootRouterView()
                        .environmentObject(userVM)
                        .environmentObject(goalStore)
                        .environmentObject(deepLink)
                        .onOpenURL { url in
                            DeepLinkManager.shared.handle(url: url)
                        }
                        .sheet(isPresented: $deepLink.shouldOpenChallenge) {
                            if let challengeID = deepLink.pendingChallengeID {
                                ChallengeInviteView(
                                    challengeID: challengeID,
                                    fromUsername: deepLink.pendingFromUser ?? "Friend"
                                )
                                .environmentObject(goalStore)
                            }
                        }
                }
            }
        }
    }

// MARK: - Root Router
struct RootRouterView: View {
    @EnvironmentObject private var userVM: UserViewModel

    var body: some View {
        Group {
            if userVM.isCheckingAuth {
                ProgressView()
            } else if userVM.currentUser == nil {
                Enter()
            } else {
                Home()
            }
        }
        .onAppear {
            userVM.checkAppleCredentialState()
        }
    }
}
