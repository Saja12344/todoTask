//
//  SuggestedGoalShapeView.swift
//  todoTask
//

import SwiftUI

struct SuggestedGoalShapeView: View {
    let goalText: String
    let suggestedShape: GoalShape
    let onFinish: (GoalType) -> Void
    let onChangeShape: () -> Void
    let onBack: (() -> Void)?

    private var convertedGoalType: GoalType {
        convertToGoalType(suggestedShape)
    }

    var body: some View {
        ZStack {
            AppBackground()

            Image("Background 2")
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button(action: { onBack?() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .glassEffect(.clear.tint(Color.black.opacity(0.4)), in: Circle())
                    }
                    Spacer()
                    Button(action: { onFinish(convertedGoalType) }) {
                        Image(systemName: "checkmark")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .glassEffect(.clear.tint(Color.black.opacity(0.4)), in: Circle())
                    }
                }
                .padding(.top, 60)
                .padding(.horizontal, 20)

                Spacer()

                VStack(spacing: 20) {
                    Text(goalText)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    VStack(spacing: 12) {
                        Text("your suggested goal shape is to")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.8))

                        Text(suggestedShape.rawValue)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)

                        Text(GoalSuggestionData.getDescription(suggestedShape))
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.bottom, 40)

                Spacer()

                Button(action: { onChangeShape() }) {
                    Text("Change")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .glassEffect(.clear.tint(Color.black.opacity(0.4)), in: .rect(cornerRadius: 25))
                }
                .padding(.bottom, 50)
            }
        }
        .toolbar(.hidden, for: .tabBar)
    }
}

// ✅ محدث للـ 4 cases الجديدة
func convertToGoalType(_ shape: GoalShape) -> GoalType {
    switch shape {
    case .finishTotal:        return .reachTarget
    case .repeatOnSchedule:   return .buildHabit
    case .buildStreak:        return .buildHabit
    case .levelUpGradually:   return .levelUp
    case .finishByMilestones: return .reachTarget
    case .reduceSomething:    return .reduce
    }
}
