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
    
    struct Login: View {
        @State private var Uname : String = ""
        @State private var Pass : String = ""
        let onSignUp: () -> Void
        
        var body: some View {
            VStack{
                Text("WELCOME TO ORBIT")
                    .bold()
                    .font(Font.largeTitle)
                    .foregroundColor(.white)
                    .padding(.bottom, 40)
                
                Spacer()
                
                VStack(alignment: .leading){
                    Text("Username")
                        .foregroundColor(.white)
                    TextField("Username", text: $Uname)
                        .padding()
                        .frame(width: 296, height: 38)
                        .glassEffect(.regular)
                        .padding(.bottom, 20)
                    
                    Text("Password")
                        .foregroundColor(.white)
                    TextField("Password", text: $Pass)
                        .padding()
                        .frame(width: 296, height: 38)
                        .glassEffect(.regular)
                        .padding(.bottom, -20)
                }
                .padding()
                
                VStack(alignment: .trailing){
                    Button("Forgot Password?"){
                        
                    }
                    .foregroundColor(.white)
                    .padding(.leading, 130)
                }
                .padding(.bottom, 30)
                
                Button("Login"){
                    
                }
                .frame(width: 296, height: 48)
                .cornerRadius(30)
                .foregroundColor(.white)
                .bold()
                .glassEffect(.regular.tint(.white.opacity(0.3)).interactive())
                .padding(.bottom, 40)
                
                HStack{
                    Rectangle()
                        .frame(width: 110.37, height: 2)
                        .foregroundColor(.white.opacity(0.3))
                        .glassEffect()
                    
                    Text("Or Login With")
                        .foregroundColor(.white)
                    
                    Rectangle()
                        .frame(width: 110.37, height: 2)
                        .foregroundColor(.white.opacity(0.3))
                        .glassEffect()
                }
                .padding(.bottom, 40)
                
                HStack(spacing:20){
//                    Button(action: {}) {
//                        ZStack {
//                            Circle()
//                                .fill(Color.white.opacity(0.01))
//                                .frame(width: 42, height: 42)
//                                .glassEffect(.regular.tint(.white.opacity(0.3)).interactive())
//                            
//                            Image("Google")
//                                .font(.system(size: 25, weight: .bold))
//                                .blendMode(.destinationOut)
//                        }
//                    }
//                    .compositingGroup()
                    
                    Button(action: {}) {
                        ZStack {
//                            Circle()
                            Rectangle()
                                .fill(Color.white.opacity(0.01))
                                .frame(width: 296, height: 48)
                                .glassEffect(.regular.tint(.white.opacity(0.3)).interactive())
                            HStack{
                                Image(systemName: "apple.logo")
                                    .font(.system(size: 25, weight: .bold))
                                    
                                Text("Sing In With Apple")
                                    .font(.system(size: 21, weight: .semibold))
                            }
                            .blendMode(.destinationOut)
                        }
                    }
                    .compositingGroup()
                    
//                    Button(action: {}) {
//                        ZStack {
//                            Circle()
//                                .fill(Color.white.opacity(0.01))
//                                .frame(width: 42, height: 42)
//                                .glassEffect(.regular.tint(.white.opacity(0.3)).interactive())
//                            
//                            Image("Facebook")
//                                .font(.system(size: 25, weight: .bold))
//                                .blendMode(.destinationOut)
//                        }
//                    }
//                    .compositingGroup()
                }
                .padding(.bottom, 60)
                HStack{
                    Text("New Here?")
                        .foregroundColor(.white)
                    Button("Create an Account") {
                        onSignUp()
                    }
                    .foregroundColor(.white)
                    .bold()
                    .compositingGroup()
                    
                }
                .padding(.top, 40)
            }
            .padding(.top,60)
            .padding(.bottom, 30)
        }
    }
    
    struct signup: View{
        @State private var Uname : String = ""
        @State private var Uemail : String = ""
        @State private var Pass : String = ""
        let onLogin: () -> Void
        
        var body: some View {
            VStack{
                Text("Create Account")
                    .bold()
                    .font(Font.largeTitle)
                    .foregroundColor(.white)
                    .padding(.bottom, 100)
                
                
                VStack(alignment: .leading){
                    Text("Username")
                        .foregroundColor(.white)
                    TextField("Username", text: $Uname)
                        .padding()
                        .frame(width: 296, height: 38)
                        .glassEffect(.regular)
                        .padding(.bottom, 20)
                    
                    Text("Email")
                        .foregroundColor(.white)
                    TextField("Email", text: $Uemail)
                        .padding()
                        .frame(width: 296, height: 38)
                        .glassEffect(.regular)
                        .padding(.bottom, 20)
                    
                    Text("Password")
                        .foregroundColor(.white)
                    TextField("Password", text: $Pass)
                        .padding()
                        .frame(width: 296, height: 38)
                        .glassEffect(.regular)
                        .padding(.bottom, 40)
                }
                .padding()
                
                
                Button("Sign Up"){
                    
                }
                .frame(width: 296, height: 48)
                .cornerRadius(30)
                .foregroundColor(.white)
                .bold()
                .glassEffect(.regular.tint(.white.opacity(0.3)).interactive())
                .padding(.bottom, 40)
                
                
                HStack{
                    Text("Already Have an Account?")
                        .foregroundColor(.white)
                    Button("Login") {
                        onLogin()
                    }
                    .foregroundColor(.white)
                    .bold()
                    .compositingGroup()
                }
                .padding(.top, 100)
            }
        }
    }
}


#Preview {
    Enter()
}
