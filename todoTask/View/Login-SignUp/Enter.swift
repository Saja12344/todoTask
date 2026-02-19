////
////  Login.swift
////  OrbitDemo
////
////  Created by Jana Abdulaziz Malibari on 06/02/2026.
////
//
////import SwiftUI
////
////struct Enter: View {
////    @State private var showSignUp = false
////    
////    var body: some View {
////        NavigationStack{
////            ZStack{
////                Rectangle()
////                    .fill(LinearGradient(colors: [.color, .dark], startPoint: .bottom, endPoint: .top))
////                    .ignoresSafeArea()
////                Image("Background")
////                    .resizable()
////                    .ignoresSafeArea()
////                Image("Gliter")
////                    .resizable()
////                    .ignoresSafeArea()
////                
////                if showSignUp {
////                    Login() {
////                        showSignUp = false
////                    }
////                } else {
////                    Login() {
////                        showSignUp = true
////                    }
////                }
////            }
////        }
////        .navigationBarBackButtonHidden(true)
////    }
////}
////#Preview {
////    Enter()
////}
////
//
//
import SwiftUI
import AuthenticationServices

struct Enter: View {
    @EnvironmentObject var userVM: UserViewModel
    @State private var showLoginPopup = true
    
    var body: some View {
        
        ZStack{
            SplashView()

            // Content
            VStack(spacing: 20) {

                Text("WELCOME TO ORB.IT")
                    .bold()
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(.top, 120)
                
                Text("Where one goal, Unfolds the world")
                    .foregroundColor(.white)
                Spacer()


                // Login Popup
                if showLoginPopup {

                    VStack(spacing: 16) {
                        Text("Sign in to continue")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                        
                        SignInWithAppleButton(
                            .signIn,
                            onRequest: { request in
                                request.requestedScopes = [.fullName, .email]
                            },
                            onCompletion: { result in
                                switch result {
                                case .success(let authResults):
                                    if let credential = authResults.credential as? ASAuthorizationAppleIDCredential {
                                        
                                                  print(" Apple User ID: \(credential.user)")
                                                  print(" Given Name: \(credential.fullName?.givenName ?? "nil")")
                                                  print(" Family Name: \(credential.fullName?.familyName ?? "nil")")
                                                  print(" Email: \(credential.email ?? "nil")")
                                        
                                        Task {
                                            try await userVM.loginWithApple(
                                                id: credential.user,
                                                name: credential.fullName,
                                                email: credential.email
                                            )
                                        }
                                    }

                                case .failure(let error):
                                    print(error.localizedDescription)
                                }
                            }

                        )
                        .signInWithAppleButtonStyle(.white)
                        .frame(height: 50)
                        .cornerRadius(12)
                     
                    }
                    
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    .padding(.horizontal, 40)
                    .padding(.bottom,120)

                    
                }
            }
            
        }
    }
}

#Preview {
    Enter()
    .environmentObject(UserViewModel())
}
