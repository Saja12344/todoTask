import SwiftUI
import FirebaseCore

@main
struct todoTaskApp: App {

    @StateObject private var userVM      = UserViewModel()
    @StateObject private var goalStore   = OrbGoalStore()
    @StateObject private var language    = LanguageManager()
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
                        }
                    }
            }
        }
    }
}

// MARK: - Root Router
struct RootRouterView: View {
    var body: some View {
        Home()
    }
}
