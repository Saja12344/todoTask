//
//  LoadingGoalShapesView.swift
//  todoTask
//

import SwiftUI

struct LoadingGoalShapesView: View {
    
    let goalText: String
    let suggestedShape: GoalShape
    let onFinish: () -> Void
    
    @State private var selectedShapes: [GoalShape] = []
    @State private var currentIndex = 0
    
    private let allShapes: [GoalShape] = [
        .finishTotal,
        .repeatOnSchedule,
        .buildStreak,
        .levelUpGradually,
        .finishByMilestones,
        .reduceSomething
    ]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
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
            
            VStack(spacing: 30) {
                Text("Finding Best Orb Shape...")
                    .foregroundColor(.white)
                    .font(.title3.bold())
                
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(selectedShapes.indices, id: \.self) { index in
                        GoalShapeLoadingCard(
                            shape: selectedShapes[index],
                            isActive: index == currentIndex
                        )
                    }
                }
                .padding(.horizontal, 28)
            }
        }
        .onAppear {
            generateRandomShapes()
            startAnimationCycle()
        }
    }
    
    private func generateRandomShapes() {
        selectedShapes = Array(allShapes.shuffled())
    }
    
    private func startAnimationCycle() {
        var count = 0
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in
            count += 1
            // ✅ تأكد إن currentIndex ما يتجاوز الحدود
            if count < selectedShapes.count {
                currentIndex = count
            } else {
                timer.invalidate()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            onFinish()
        }
    }
}

struct GoalShapeLoadingCard: View {
    
    let shape: GoalShape
    let isActive: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon(for: shape))
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(.white)
            
            Text(title(for: shape))
                .foregroundColor(.white)
                .font(.subheadline)
        }
        .frame(maxWidth: 200)
        .frame(height: 120)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(
                            isActive ? .white : .white.opacity(0.1),
                            lineWidth: isActive ? 2 : 1
                        )
                )
        )
        .scaleEffect(isActive ? 1.03 : 1)
        .animation(.easeInOut(duration: 0.35), value: isActive)
    }
    
    func icon(for shape: GoalShape) -> String {
        switch shape {
        case .finishTotal: return "scope"
        case .repeatOnSchedule: return "calendar"
        case .buildStreak: return "flame"
        case .levelUpGradually: return "chart.line.uptrend.xyaxis"
        case .finishByMilestones: return "flag.checkered"
        case .reduceSomething: return "arrow.down.circle"
        }
    }
    
    func title(for shape: GoalShape) -> String {
        switch shape {
        case .finishTotal: return "Finish Total"
        case .repeatOnSchedule: return "Schedule"
        case .buildStreak: return "Streak"
        case .levelUpGradually: return "Level Up"
        case .finishByMilestones: return "Milestones"
        case .reduceSomething: return "Reduce"
        }
    }
}
