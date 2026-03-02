//
//  seplach.swift
//  todoTask
//
//  Created by saja khalid on 13/09/1447 AH.
//
import SwiftUI

struct SplashScreenView: View {
    
    @State private var split = false
    @State private var animateMeteor = false
    @State private var zoomBackground = false
    @State private var goNext = false
    
    var body: some View {
        ZStack {
            
            // خلفيتك
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.darkBlu, .black],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .ignoresSafeArea()
            
            Image("Background")
                .resizable()
                .scaledToFill()   // ⭐ مهم جدًا
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .opacity(0.5)
            
//                .scaleEffect(zoomBackground ? 1.3 : 3.0) // ⭐ الزوم
//                .animation(.easeInOut(duration: 1.2), value: zoomBackground)
//            
//            
            
            ZStack {
                
                // الكلمة
                HStack(spacing: split ? 8 : 0) {
                    
                    Text("ORB")
                        .font(.system(size: 48, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    
                    if split {
                        Text(".")
                            .font(.system(size: 48, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .transition(.opacity)
                    }
                    
                    Text("it")
                        .font(.system(size: 48, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                }
                .animation(.easeInOut(duration: 0.6), value: split)
                
                
                CurvedMeteor()
                    .opacity(animateMeteor ? 1 : 0)
            }
        }
        .onAppear {
            animateMeteor = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                split = true
            }
//            // ⭐ بعد انفصال الكلمات → زوم + انتقال
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
//                withAnimation {
//                    zoomBackground = true
//                }
//            }
        }
    }
    
}
#Preview {
    SplashScreenView()
}

struct CurvedMeteor: View {
    
    @State private var move = false
    
    var body: some View {
        ZStack {

            // نجوم صغيرة
            ForEach(0..<15) { i in
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 4, height: 2)
                    .offset(
                        x: CGFloat.random(in: -40...60),
                        y: CGFloat.random(in: -50...40)
                    )
                    .opacity(move ? 0 : 1)
                    .animation(.easeOut(duration: 3), value: move)
            }
        }
        .onAppear {
            move = true
        }
    }
}


