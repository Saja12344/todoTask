//
//  Home.swift
//  OrbitDemo
//
//  Created by Jana Abdulaziz Malibari on 07/02/2026.
//

import SwiftUI
import UserNotifications

struct Home: View {
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var language: LanguageManager
    @State private var showLoginPopup = false

    var body: some View {
        NativeTabView()
            .id(language.language)
            .navigationBarBackButtonHidden(true)
            .orbitForcedDark()
    }
}

struct NativeTabView: View {
    @EnvironmentObject private var lang: LanguageManager
    @EnvironmentObject private var tabRouter: OrbitTabRouter

    var body: some View {
        TabView(selection: $tabRouter.selectedTab) {
            NavigationStack {
                today()
                    .navigationTitle(lang.t(.goalsOfTheDay))
            }
            .tabItem { Label(lang.t(.tabToday), systemImage: "checklist") }
            .tag(0)

            GoalsPage()
                .tabItem { Label(lang.t(.tabOrbs), systemImage: "globe.americas.fill") }
                .tag(1)

            NavigationStack {
                FriendsV()
                    .navigationTitle(lang.t(.tabFriends))
            }
            .tabItem { Label(lang.t(.tabFriends), systemImage: "person.2.fill") }
            .tag(2)

            NavigationStack {
                Settings()
                    .navigationBarHidden(true)
            }
            .tabItem { Label(lang.t(.tabSettings), systemImage: "gear") }
            .tag(3)
        }
        .accentColor(.accent)
    }
}
#Preview{
    Home()
        .environmentObject(OrbGoalStore())
        .environmentObject(LanguageManager())
}

#Preview{
    today()
        .environmentObject(OrbGoalStore())
}

#Preview{
    Settings()
        .environmentObject(UserViewModel())
}

#Preview{
    FriendsV()
        .environmentObject(UserViewModel())
}

