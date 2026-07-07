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
    @State private var orbitAngle: Double = 0
    @State private var appear = false
    @State private var glowPulse = false

    var onFinished: (() -> Void)?

    init(onFinished: (() -> Void)? = nil) {
        self.onFinished = onFinished
    }

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

            ZStack {
                // Soft glow halo behind the wordmark.
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color("accent").opacity(glowPulse ? 0.42 : 0.24), .clear],
                            center: .center,
                            startRadius: 4,
                            endRadius: 190
                        )
                    )
                    .frame(width: 360, height: 360)
                    .blur(radius: 8)

                orbitingWordmark

                CurvedMeteor()
                    .opacity(animateMeteor ? 1 : 0)
            }
            .scaleEffect(appear ? 1 : 0.82)
            .opacity(appear ? 1 : 0)
        }
        .onAppear {
            animateMeteor = true

            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                appear = true
            }
            withAnimation(.linear(duration: 3.4).repeatForever(autoreverses: false)) {
                orbitAngle = 360
            }
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                glowPulse = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                split = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
                onFinished?()
            }
        }
    }

    private var wordmarkGradient: LinearGradient {
        LinearGradient(
            colors: [.white, Color("accent"), .white],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var orbitingWordmark: some View {
        HStack(spacing: split ? 6 : 0) {
            Text("ORB")
                .font(.system(size: 52, weight: .bold, design: .rounded))

            if split {
                Text("·")
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .transition(.opacity.combined(with: .scale))
            }

            Text("IT")
                .font(.system(size: 52, weight: .bold, design: .rounded))
        }
        .foregroundStyle(wordmarkGradient)
        .shadow(color: Color("accent").opacity(0.6), radius: 14)
        .animation(.easeInOut(duration: 0.6), value: split)
        .overlay {
            // A little planet orbiting around the wordmark.
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color("accent"), Color("accent").opacity(0.4)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 8
                        )
                    )
                    .frame(width: 12, height: 12)
                    .shadow(color: Color("accent"), radius: 6)
                    .offset(x: 118)
                    .rotationEffect(.degrees(orbitAngle))
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
            ForEach(0..<15, id: \.self) { _ in
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
