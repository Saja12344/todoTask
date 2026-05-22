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

    var body: some View {
        TabView {
            Tab(lang.t(.tabToday), systemImage: "checklist") {
                NavigationStack {
                    today()
                        .navigationTitle(lang.t(.goalsOfTheDay))
                }
            }
            Tab(lang.t(.tabOrbs), systemImage: "globe.americas.fill") {
                GoalsPage()
            }
            Tab(lang.t(.tabFriends), systemImage: "person.2.fill") {
                NavigationStack {
                    FriendsV()
                        .navigationTitle(lang.t(.tabFriends))
                }
            }
            Tab(lang.t(.tabSettings), systemImage: "gear") {
                NavigationStack {
                    Settings()
                        .navigationTitle(lang.t(.settingsTitle))
                }
            }
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

