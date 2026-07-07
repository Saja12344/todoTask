//
//  seplach.swift
//  todoTask
//
//  Created by saja khalid on 13/09/1447 AH.
//
import SwiftUI

struct SplashScreenView: View {

    var onFinished: (() -> Void)?

    init(onFinished: (() -> Void)? = nil) {
        self.onFinished = onFinished
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(LinearGradient(colors: [.darkBlu, .orbitDark], startPoint: .bottom, endPoint: .top))
                .ignoresSafeArea()
            Image("Background 4")
                .resizable()
                .ignoresSafeArea()
                .opacity(0.7)

            Image("Gliter")
                .resizable()
                .ignoresSafeArea()

            HStack(spacing: 6) {
                Text("ORB")
                Text("·")
                Text("IT")
            }
            .font(.system(size: 52, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                onFinished?()
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
