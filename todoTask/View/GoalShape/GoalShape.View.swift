import SwiftUI

struct GoalShapeView: View {
    @State private var selectedGoal: GoalType?
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.color, .dark],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .ignoresSafeArea()
            
            // Background Image
            Image("Gliter")
                .resizable()
                .scaledToFit()
                .scaleEffect(1.9)
                .opacity(1.3)
                .contrast(1.8)
                .saturation(1.8)
                .ignoresSafeArea()
            
            VStack {
                
                HStack {

                    Button(action: {
                        // Back action
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Color.clear)
                            .glassEffect(
                                .clear,
                                in: .rect(cornerRadius: 24)
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    }
                    Spacer()

                    // Next Button
                    Button(action: {
                        // Next action
                    }) {
                        Text("Next")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(Color.clear)
                            .glassEffect(
                                .clear,
                                in: .rect(cornerRadius: 24)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
                .padding()
                // Title
                Text("Select Your Goal Shape")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                Spacer()
                
                // Goal Grid
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 20)
                ], spacing: 15) {
                    GoalCard(
                        icon: "scope",
                        title: "Finish a Total",
                        description: "Reach a set number",
                        isSelected: selectedGoal == .finishTotal
                    ) {
                        selectedGoal = .finishTotal
                    }
                    
                    GoalCard(
                        icon: "calendar.badge.clock",
                        title: "Repeat on Schedule",
                        description: "Do something on certain days each week",
                        isSelected: selectedGoal == .repeatSchedule
                    ) {
                        selectedGoal = .repeatSchedule
                    }
                    
                    GoalCard(
                        icon: "flame.fill",
                        title: "Build a Streak",
                        description: "Do it every day without stopping",
                        isSelected: selectedGoal == .buildStreak
                    ) {
                        selectedGoal = .buildStreak
                    }
                    
                    GoalCard(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Level Up Gradually",
                        description: "Start small and slowly do more",
                        isSelected: selectedGoal == .levelUp
                    ) {
                        selectedGoal = .levelUp
                    }
                    
                    GoalCard(
                        icon: "flag.checkered",
                        title: "Finish by Milestones",
                        description: "Complete a goal step by step",
                        isSelected: selectedGoal == .milestones
                    ) {
                        selectedGoal = .milestones
                    }
                    
                    GoalCard(
                        icon: "arrow.down.circle",
                        title: "Reduce Something",
                        description: "Do less of something or stay under a limit",
                        isSelected: selectedGoal == .reduce
                    ) {
                        selectedGoal = .reduce
                    }
                }
                .padding(.horizontal, 17)
                
                Spacer()
            }
        }
    }
}

// Preview
struct GoalShapeView_Previews: PreviewProvider {
    static var previews: some View {
        GoalShapeView()
    }
}
