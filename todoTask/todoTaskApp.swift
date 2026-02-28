//
//  todoTaskApp.swift
//  todoTask
//

import SwiftUI

@main
struct todoTaskApp: App {

    @StateObject private var userVM = UserViewModel()
    @StateObject private var goalStore = OrbGoalStore()

    init() {
        NotificationPermissionManager.shared.requestPermissionIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            RootRouterView()
                .environmentObject(userVM)
                .environmentObject(goalStore)
            // ← حذفنا loadLocalUser() من هنا لأنها تُستدعى في init()
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
            // فقط تتحقق من صلاحية Apple في الخلفية
            userVM.checkAppleCredentialState()
        }
    }
}
