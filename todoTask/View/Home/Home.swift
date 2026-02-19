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
        Tab.init("Goals", systemImage: "target"){
            NavigationStack{
                Goals()
                    .navigationTitle("Achived Goals")
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
#Preview {
    Home()
    .environmentObject(UserViewModel())

}
