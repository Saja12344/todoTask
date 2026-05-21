import SwiftUI

struct AppRootView: View {
    var body: some View {
        Home()
            .environmentObject(OrbGoalStore())
    }
}

#Preview {
    AppRootView()
        .environmentObject(OrbGoalStore())
}
