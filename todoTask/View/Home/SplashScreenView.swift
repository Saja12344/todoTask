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
    
    // Completion called when splash should go away
    var onFinished: (() -> Void)?
    
    init(onFinished: (() -> Void)? = nil) {
        self.onFinished = onFinished
    }
    
    var body: some View {
        ZStack {
            
            // خلفيتك
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
            
            ZStack {
                
                // الكلمة
                HStack(spacing: split ? 8 : 0) {
                    
                    Text("ORB")
                        .font(.system(size: 48, weight: .semibold, design: .default))
                        .foregroundColor(.white)
                    
                    if split {
                        Text(".")
                            .font(.system(size: 48, weight: .semibold, design: .default))
                            .foregroundColor(.white)
                            .transition(.opacity)
                    }
                    
                    Text("IT")
                        .font(.system(size: 48, weight: .semibold, design: .default))
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
            
            // Trigger fade-out after the sequence completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                onFinished?()
            }
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
            ForEach(0..<15) { _ in
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
