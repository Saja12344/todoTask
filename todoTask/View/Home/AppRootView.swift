import SwiftUI

struct AppRootView: View {
    @State private var showSplash = true
    @State private var splashOpacity = 1.0

    var body: some View {
        ZStack {
            Home()
                .environmentObject(OrbGoalStore())

            if showSplash {
                SplashScreenView {
                    withAnimation(.easeOut(duration: 0.6)) {  // easeOut here
                        splashOpacity = 0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        showSplash = false
                    }
                }
                .opacity(splashOpacity)
                .transition(.opacity)
            }
        }
    }
}

#Preview {
    AppRootView()
        .environmentObject(OrbGoalStore())
}
