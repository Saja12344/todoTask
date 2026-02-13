//
//  Splash.swift
//  OrbitDemo
//
//  Created by Jana Abdulaziz Malibari on 06/02/2026.
//

import SwiftUI


struct Splash: View {
    var body: some View {
        NavigationStack {
            ZStack{
                Rectangle()
                    .fill(LinearGradient(colors: [.color, .dark], startPoint: .bottom, endPoint: .top))
                    .ignoresSafeArea()
                Image("Background 3")
                    .resizable()
                    .ignoresSafeArea()
                    .opacity(0.5)
                Image("Gliter")
                    .resizable()
                    .ignoresSafeArea()
                Content()
                    .onAppear {
                        requestNotificationPermission()
                    }
            }
        }
    }
    
    struct Content: View {
        var body: some View{
            VStack{
                Text("WELCOME TO ORB.IT")
                    .bold()
                    .font(Font.largeTitle)
                    .foregroundColor(.white)
                Text("Where one goal, Unfolds the world")
                    .foregroundColor(.white)
                    .padding(.bottom, 250)
                
                withAnimation(.easeIn.speed(1.5)) {
                    NavigationLink("Start",destination: Enter())
                        .frame(width: 210, height: 48)
                        .background(Color(.accent).opacity(0.1))
                        .cornerRadius(30)
                        .bold()
                        .foregroundColor(.white)
                        .glassEffect(.clear.interactive())
                        .padding(0.5)
                }
                
                withAnimation(.easeIn.speed(1.5)) {
                    NavigationLink("Continue as Guest",destination: Home())
                        .frame(width: 210, height: 48)
                        .cornerRadius(30)
                        .bold()
                        .foregroundColor(.white)
                }
            }
            .padding(.top, 250)
            .padding(.bottom)
        }
        
    }
}

#Preview {
    Splash()
}

