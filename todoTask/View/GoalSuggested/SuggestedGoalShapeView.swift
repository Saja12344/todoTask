import SwiftUI

struct SuggestedGoalShapeView: View {
    let goalText: String
    let suggestedShape: GoalShape
    // Parent-driven flow
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
                // Top Bar
                HStack {
                    Button(action: { onBack?() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .glassEffect(.clear.tint(Color.black.opacity(0.4)), in: Circle())
                    }

                    Spacer()

                    // Checkmark confirms suggested type → go to its form
                    Button(action: {
                        onFinish(convertedGoalType)
                    }) {
                        Image(systemName: "checkmark")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .glassEffect(.clear.tint(Color.black.opacity(0.4)), in: Circle())
                    }
                }
                .padding()

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

                // Change → go to selection screen
                Button(action: {
                    onChangeShape()
                }) {
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

func convertToGoalType(_ shape: GoalShape) -> GoalType {
    switch shape {
    case .finishTotal: return .finishTotal
    case .repeatOnSchedule: return .repeatSchedule
    case .buildStreak: return .buildStreak
    case .levelUpGradually: return .levelUp
    case .finishByMilestones: return .milestones
    case .reduceSomething: return .reduce
    }
}
