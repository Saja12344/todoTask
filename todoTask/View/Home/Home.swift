//
//  Home.swift
//  OrbitDemo
//
//  Created by Jana Abdulaziz Malibari on 07/02/2026.
//

import SwiftUI
import UserNotifications

struct Home: View {
    var body: some View {
        ZStack {
            NativeTabView()
                .navigationBarBackButtonHidden(true)
        }
        .colorScheme(.dark)
    }
}

@ViewBuilder
func NativeTabView() -> some View {
    TabView{
        Tab.init("Today", systemImage: "checklist"){
            NavigationStack{
                today()
            }
        }
        Tab.init("Friends", systemImage: "person.2.fill"){
            NavigationStack{

            }
            
        }
        Tab.init("Goals", systemImage: "target"){
            NavigationStack{
                Goals()
            }
        }
        Tab.init("Settings", systemImage: "gear"){
            NavigationStack{
                Settings()
            }
        }
    }
    .accentColor(.accent)
    
}
#Preview {
    Home()
}
