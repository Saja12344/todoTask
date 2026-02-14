//
//  Login.swift
//  OrbitDemo
//
//  Created by Jana Abdulaziz Malibari on 06/02/2026.
//

import SwiftUI

struct Enter: View {
    @State private var showSignUp = false
    
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
                
                if showSignUp {
                    signup() {
                        showSignUp = false
                    }
                } else {
                    Login() {
                        showSignUp = true
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
#Preview {
    Enter()
}

