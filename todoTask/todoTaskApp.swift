import SwiftUI
import FirebaseCore

@main
struct todoTaskApp: App {

    @StateObject private var userVM      = UserViewModel()
    @StateObject private var goalStore   = OrbGoalStore()
    @StateObject private var language    = LanguageManager()
    @StateObject private var achievements = OrbAchievementStore.shared
    @StateObject private var challengeOrbs = ChallengeOrbsManager.shared
    @StateObject private var tabRouter     = OrbitTabRouter()
    @StateObject private var deepLink    = DeepLinkManager.shared
    @State private var showSplash = true

    init() {
        FirebaseApp.configure()
        OrbitAppearance.configure()
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
                    .environmentObject(language)
                    .environmentObject(achievements)
                    .environmentObject(challengeOrbs)
                    .environmentObject(tabRouter)
                    .environmentObject(deepLink)
                    .environment(\.layoutDirection, language.language.layoutDirection)
                    .preferredColorScheme(.dark)
                    .orbitForcedDark()
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
                            .environmentObject(userVM)
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
            if userVM.isLoggedIn {
                Home()
            } else {
                EnterView()
            }
        }
        .animation(.easeInOut(duration: 0.25), value: userVM.isLoggedIn)
    }
}
