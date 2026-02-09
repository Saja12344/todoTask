//
//  Splash.swift
//  OrbitDemo
//
//  Created by Jana Abdulaziz Malibari on 06/02/2026.
//

import SwiftUI

struct Splash: View {
    var body: some View {
        NavigationStack{
            ZStack{
                Rectangle()
                    .fill(LinearGradient(colors: [.color, .dark], startPoint: .bottom, endPoint: .top))
                    .ignoresSafeArea()
                Image("Background")
                    .resizable()
                    .ignoresSafeArea()
                Image("Gliter")
                    .resizable()
                    .ignoresSafeArea()
                Content()
                
            }
        }
    }
    
    struct Content: View {
        var body: some View{
            VStack{
                Text("WELCOME TO ORBIT")
                    .bold()
                    .font(Font.largeTitle)
                    .foregroundColor(.white)
                Text("Where one goal, Unfolds the world")
                    .foregroundColor(.white)
                    .padding(.bottom, 250)
                
                NavigationLink("Start",destination: Enter())
                    .frame(width: 263, height: 48)
                    .background(Color(.color).opacity(0.9))
                    .cornerRadius(30)
                    .bold()
                    .foregroundColor(.white)
                    .glassEffect(.regular.interactive())
                    .padding(0.5)
                
                NavigationLink("Continue as Guest",destination: Home())
                    .frame(width: 263, height: 48)
                    .cornerRadius(30)
                    .bold()
                    .foregroundColor(.white)
            }
            .padding(.top, 250)
            .padding(.bottom)
        }
        
    }
}

#Preview {
    Splash()
}
