//
//  GoalTasksComponents.swift
//  todoTask
//
//  Created by Ruba Alghamdi on 25/08/1447 AH.
//
import SwiftUI

struct BulletTaskRow: View {
    var title: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("•")
                .font(.title3)
                .foregroundStyle(.white.opacity(0.9))

            Text(title)
                .foregroundStyle(.white)
                .opacity(0.92)

            Spacer()
        }
        .padding(.vertical, 6)
    }
}

struct ProgressCircle: View {
    var progress: Double // 0...1

    var body: some View {
        let p = max(0, min(progress, 1))

        ZStack {
            Circle()
                .stroke(.white.opacity(0.12),
                        style: StrokeStyle(lineWidth: 16, lineCap: .round))

            Circle()
                .trim(from: 0, to: p)
                .stroke(Color.cyan,
                        style: StrokeStyle(lineWidth: 16, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.25), value: p)
        }
    }
}
