////
////  Splash.swift
////  OrbitDemo
////
////  Created by Jana Abdulaziz Malibari on 06/02/2026.
////
//
import SwiftUI
import AuthenticationServices
//
//struct SplashView: View {
//    @EnvironmentObject var userVM: UserViewModel
//    @State private var showLoginPopup = true
//    
//    var body: some View {
//        ZStack{
//            Rectangle()
//                .fill(LinearGradient(colors: [.darkBlu, .black], startPoint: .bottom, endPoint: .top))
//                .ignoresSafeArea()
//            Image("Background 3")
//                .resizable()
//                .ignoresSafeArea()
//                .opacity(0.5)
////            Image("Gliter")
////                .resizable()
////                .ignoresSafeArea()
//                .onAppear {
//                    requestNotificationPermission()
//                }
//        }
//        
//    }}
struct SplashView: View {
    
    @State private var animate = false
    @State private var goToLogin = false

    
    var body: some View {
        ZStack{
            
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.darkBlu, .black],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .ignoresSafeArea()
            
            Image("Background 3")
                .resizable()
                .scaledToFill()   // ⭐ مهم جدًا
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .opacity(0.5)
            
                // ✨ تكبير أكبر شوي من الشاشة لمنع التكسر
                .scaleEffect(animate ? 1.08 : 1.02)
            
                // ✨ حركة فضائية ناعمة داخل حدود الشاشة
                .offset(y: animate ? -6 : 6)
            
                .animation(
                    .easeInOut(duration: 9)
                    .repeatForever(autoreverses: true),
                    value: animate
                )
                .onAppear {
                    animate = true
                    
                    // وقت الانتقال
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        goToLogin = true
                    }
                }
        }
    }
}
#Preview {
    SplashView()
}
