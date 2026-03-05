//
//  Login.swift
//  OrbitDemo
//
//  Created by Jana Abdulaziz Malibari on 06/02/2026.
//  Edited By saja
//

import SwiftUI
import AuthenticationServices

struct Enter: View {
    @EnvironmentObject var userVM: UserViewModel
    @State private var showLoginPopup = true

    var body: some View {
        ZStack {
            SplashView()

            VStack(spacing: 20) {

                Spacer().frame(height: 300)

                Text("WELCOME TO ORB.IT")
                    .bold()
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(.top, 50)

                Text("Where one goal, Unfolds the world")
                    .foregroundColor(.white)
                    .padding(.bottom, 10)

                Spacer()

                if showLoginPopup {
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
                                print("❌ Apple sign in failed: \(error.localizedDescription)")
                            }
                        }

                    )
                    .signInWithAppleButtonStyle(.white)
                    .frame(height: 50)
                    .cornerRadius(12)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 120)
                }
            }
        }
    }
}

#Preview {
    Enter()
        .environmentObject(UserViewModel())
}
