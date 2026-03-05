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
    @State private var showLoginPopup = false
    
    var body: some View {
        NativeTabView()
            .navigationBarBackButtonHidden(true)
            .colorScheme(.dark)
    }
}

@ViewBuilder
func NativeTabView() -> some View {
    TabView{
        Tab.init("Today", systemImage: "checklist"){
            NavigationStack{
                today()
                    .navigationTitle("Goals Of The Day")
            }
        }
        Tab.init("Orbs", systemImage: "globe.americas.fill"){
            NavigationStack{
                GoalsPage()
                    .navigationTitle("Orbit Dashboard")
            }
        }
        Tab.init("Friends", systemImage: "person.2.fill"){
            NavigationStack{
                FriendsV()
                    .navigationTitle("Friends List")
            }
        }
        Tab.init("Settings", systemImage: "gear"){
            NavigationStack{
                Settings()
                    .navigationTitle("Settings")
            }
        }
    }
    .accentColor(.accent)
    
}
#Preview{
    Home()
        .environmentObject(OrbGoalStore())
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

