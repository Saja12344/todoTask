//
//  GoalTasksComponents.swift
//  todoTask
//
//  Created by Ruba Alghamdi on 25/08/1447 AH.
//

import SwiftUI

struct TaskRow: View {
    var title: String
    var isDone: Bool

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(.white.opacity(0.35), lineWidth: 2)
                    .frame(width: 30, height: 30)

                if isDone {
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.white)
                }
            }

            Text(title)
                .foregroundStyle(.white)
                .opacity(isDone ? 0.6 : 1.0)
                .strikethrough(isDone, color: .white.opacity(0.35))

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
