//
//  EnterComponents.swift
//  todoTask
//
//  Created by Jana Abdulaziz Malibari on 11/02/2026.
//

import SwiftUI
import AuthenticationServices

struct EnterView: View {
    @EnvironmentObject private var userVM: UserViewModel
    @EnvironmentObject private var lang: LanguageManager

    var body: some View {
        ZStack {
            Rectangle()
                .fill(LinearGradient(colors: [.darkBlu, .dark], startPoint: .bottom, endPoint: .top))
                .ignoresSafeArea()
            Image("Background 4")
                .resizable()
                .ignoresSafeArea()
                .opacity(0.7)
            Image("Gliter")
                .resizable()
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                Login(onSignUp: {})
            }
        }
        .orbitForcedDark()
    }
}

struct Login: View {
    @EnvironmentObject private var userVM: UserViewModel
    @EnvironmentObject private var lang: LanguageManager

    @State private var isSignUp = false
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var appleNonce: String?

    let onSignUp: () -> Void

    private var isArabic: Bool { lang.language == .arabic }
    private let fieldWidth: CGFloat = 300

    var body: some View {
        VStack(spacing: 0) {
            Text("WELCOME TO ORBIT")
                .bold()
                .font(.largeTitle)
                .foregroundColor(.white)
                .padding(.top, 60)
                .padding(.bottom, 28)

            modeSwitch
                .padding(.bottom, 26)

            VStack(alignment: .leading, spacing: 18) {
                if isSignUp {
                    labeledField(title: isArabic ? "الاسم" : "Name") {
                        TextField(isArabic ? "اسمك" : "Your name", text: $username)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled()
                    }
                }

                labeledField(title: isArabic ? "البريد الإلكتروني" : "Email") {
                    TextField(isArabic ? "you@email.com" : "you@email.com", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                labeledField(title: isArabic ? "كلمة المرور" : "Password") {
                    SecureField("••••••••", text: $password)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
            }

            if !isSignUp {
                HStack {
                    Spacer()
                    Button(isArabic ? "نسيت كلمة المرور؟" : "Forgot Password?") {
                        Task { await userVM.sendPasswordReset(email: email) }
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                }
                .frame(width: fieldWidth)
                .padding(.top, 10)
            }

            primaryButton
                .padding(.top, 22)

            Button(lang.t(.continueAsGuest)) {
                userVM.loginAsGuest()
            }
            .frame(width: fieldWidth, height: 46)
            .foregroundColor(.white.opacity(0.9))
            .font(.system(size: 16, weight: .semibold))
            .padding(.top, 6)

            dividerRow
                .padding(.vertical, 26)

            appleButton
                .padding(.bottom, 60)
        }
        .frame(maxWidth: .infinity)
        .disabled(userVM.isBusy)
        .overlay {
            if userVM.isBusy {
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.2)
                    .frame(width: 60, height: 60)
                    .background(.black.opacity(0.35), in: RoundedRectangle(cornerRadius: 16))
            }
        }
        .alert(
            isArabic ? "تنبيه" : "Notice",
            isPresented: Binding(
                get: { userVM.authError != nil },
                set: { if !$0 { userVM.authError = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(userVM.authError ?? lang.t(.invalidCredentials))
        }
    }

    // MARK: - Mode switch (Sign In / Sign Up)

    private var modeSwitch: some View {
        HStack(spacing: 0) {
            segment(title: isArabic ? "تسجيل دخول" : "Sign In", active: !isSignUp) {
                withAnimation(.easeInOut(duration: 0.2)) { isSignUp = false }
            }
            segment(title: isArabic ? "حساب جديد" : "Sign Up", active: isSignUp) {
                withAnimation(.easeInOut(duration: 0.2)) { isSignUp = true }
            }
        }
        .padding(4)
        .frame(width: fieldWidth)
        .background(Color.white.opacity(0.08), in: Capsule())
        .glassEffect(.clear, in: .capsule)
    }

    private func segment(title: String, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(active ? .black : .white.opacity(0.75))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background {
                    if active {
                        Capsule().fill(Color("accent"))
                    }
                }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Fields

    private func labeledField<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            content()
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .frame(width: fieldWidth, height: 48, alignment: .leading)
                .glassEffect(.clear, in: .rect(cornerRadius: 16))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.12), lineWidth: 1)
                }
        }
        .frame(width: fieldWidth)
    }

    // MARK: - Primary action

    private var primaryButton: some View {
        Button(action: submit) {
            Text(isSignUp
                 ? (isArabic ? "إنشاء الحساب" : "Create Account")
                 : (isArabic ? "تسجيل الدخول" : "Log In"))
                .frame(width: fieldWidth, height: 50)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.black)
                .background(Color("accent"), in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private func submit() {
        if isSignUp {
            Task { await userVM.signUp(username: username, email: email, password: password) }
            return
        }

        // Offline reviewer bypass (App Store review demo account).
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.caseInsensitiveCompare(UserViewModel.demoUsername) == .orderedSame {
            _ = userVM.login(username: trimmed, password: password)
            return
        }

        Task { await userVM.signInWithEmail(email: email, password: password) }
    }

    // MARK: - Divider

    private var dividerRow: some View {
        HStack(spacing: 12) {
            Rectangle()
                .frame(width: 90, height: 1)
                .foregroundColor(.white.opacity(0.25))
            Text(isArabic ? "أو تابع بواسطة" : "Or continue with")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.7))
            Rectangle()
                .frame(width: 90, height: 1)
                .foregroundColor(.white.opacity(0.25))
        }
    }

    // MARK: - Sign in with Apple

    private var appleButton: some View {
        SignInWithAppleButton(.continue) { request in
            let nonce = AppleNonce.random()
            appleNonce = nonce
            request.requestedScopes = [.fullName, .email]
            request.nonce = AppleNonce.sha256(nonce)
        } onCompletion: { result in
            switch result {
            case .success(let authorization):
                if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
                    Task {
                        await userVM.signInWithApple(
                            credential: credential,
                            rawNonce: appleNonce ?? ""
                        )
                    }
                }
            case .failure(let error):
                if (error as? ASAuthorizationError)?.code != .canceled {
                    userVM.authError = error.localizedDescription
                }
            }
        }
        .signInWithAppleButtonStyle(.white)
        .frame(width: fieldWidth, height: 50)
        .clipShape(Capsule())
    }
}
