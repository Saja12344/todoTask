//
//  todoTaskApp.swift
//  todoTask
//
//  Created by شهد عبدالله القحطاني on 19/08/1447 AH.
//

import SwiftUI


@main
struct todoTaskApp: App {

    @StateObject private var userVM = UserViewModel()

    init() {
        NotificationPermissionManager.shared.requestPermissionIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            RootRouterView()
                .environmentObject(userVM)
                .onAppear {
                    // Restore previously saved local (guest or registered) session if any
                    userVM.loadLocalUser()
                }
        }
        
    }
    
}

// Root router decides which view to show based on user state
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
            userVM.loadLocalUser()
            userVM.checkAppleCredentialState()
        }
    }
}



