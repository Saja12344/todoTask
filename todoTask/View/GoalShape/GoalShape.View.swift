import SwiftUI

struct GoalShapeView: View {
    @State private var selectedGoal: GoalType?
    @State private var showSettings = false
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.darkBlu, .dark],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .ignoresSafeArea()
            
            Image("Gliter")
                .resizable()
                .scaledToFit()
                .scaleEffect(1.2)
                .opacity(1.3)
                .contrast(1.8)
                .saturation(1.8)
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Button(action: {
                        if showSettings {
                            withAnimation {
                                showSettings = false
                            }
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Color.clear)
                            .glassEffect(.clear.tint(Color.black.opacity(0.4)), in: .rect(cornerRadius: 24))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if !showSettings && selectedGoal != nil {
                            withAnimation {
                                showSettings = true
                            }
                        }
                    }) {
                        Text("Next")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(Color.clear)
                            .glassEffect(.clear.tint(Color.black.opacity(0.4)), in: .rect(cornerRadius: 24))
                    }
                }
                .padding()
                
                Text(showSettings ? getTitle(for: selectedGoal) : "Select Your Goal Shape")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 1)
                
                Spacer()
                
                if !showSettings {
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
                    
                }
                else{

                    ScrollView {
                        VStack(spacing: 16) {
                            Spacer().frame(height: 40)
                            
                            switch selectedGoal {
                            case .finishTotal:
                                FinishTotalContent()
                                
                            case .repeatSchedule:
                                RepeatScheduleContent()
                                
                            case .buildStreak:
                                BuildStreakContent()
                                
                            case .levelUp:
                                LevelUpContent()
                                
                            case .milestones:
                                MilestonesContent()
                                
                            case .reduce:
                                ReduceContent()
                                
                            case .none:
                                EmptyView()
                            }
                            
                            Spacer().frame(height: 40)
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                Spacer()
            }
        }
    }
    
    private func getTitle(for goalType: GoalType?) -> String {
        switch goalType {
        case .finishTotal: return "Finish a Total"
        case .repeatSchedule: return "Repeat on Schedule"
        case .buildStreak: return "Build a Streak"
        case .levelUp: return "Level Up Gradually"
        case .milestones: return "Finish by Milestones"
        case .reduce: return "Reduce Something"
        case .none: return "Settings"
        }
    }
}

#Preview {
    GoalShapeView()
}
