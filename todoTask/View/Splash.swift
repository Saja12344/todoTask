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
                Content()
                
            }
        }
    }
    
    struct Details: View {
        var body: some View{


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
                
                Spacer()
                NavigationLink("Start",destination: Enter())
                    .frame(width: 263, height: 48)
                    .background(Color.white.opacity(0.3))
                    .cornerRadius(30)
                    .bold()
                    .foregroundColor(.white)
                    .glassEffect(.regular.interactive())
                    .padding()
                
                NavigationLink("Continue as Guest",destination: Home())
                    .frame(width: 263, height: 48)
                    .background(Color.white.opacity(0.3))
                    .cornerRadius(30)
                    .bold()
                    .foregroundColor(.white)
                    .glassEffect(.regular.interactive())
            }
            .padding(.top, 100)
            .padding(.bottom, 100)
        }
        
    }
}

#Preview {
    Splash()
}
