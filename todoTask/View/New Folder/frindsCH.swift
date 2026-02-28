//
//  ChallengeFriendV.swift
//  todoTask
//

import SwiftUI
import CloudKit

struct ChallengeFriendV: View {
    let friend: User
    
    @StateObject private var challengeVM = ChallengeViewModel()
    @ObservedObject var friendRequestVM: FriendRequestViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    // Goal Setup
    @State private var goalTitle: String = ""
    @State private var selectedCategory: GoalCategory = .habit
    @State private var selectedType: GoalType = .finishTotal
    @State private var selectedShape: GoalShape? = nil
    
    // Planet Selection
    @State private var selectedPlanet: Planet? = nil
    @State private var showPlanetPicker = false
    
    // SubTasks
    @State private var subTaskConfigs: [SubTaskConfig] = []
    @State private var newSubTaskTitle: String = ""
    
    // UI State
    @State private var isLoading = false
    @State private var showSuccess = false
    @State private var errorMsg: String? = nil
    @State private var currentStep: Int = 1
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.darkBlu, .dark], startPoint: .bottom, endPoint: .top)
                    .ignoresSafeArea()
                Image("Gliter")
                    .resizable()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    friendHeader
                    stepIndicator.padding(.vertical, 16)
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            switch currentStep {
                            case 1: goalInfoStep
                            case 2: planetStep
                            case 3: subTasksStep
                            default: EmptyView()
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 100)
                    }
                }
                
                VStack {
                    Spacer()
                    bottomButtons.padding()
                }
                
                if showSuccess { successOverlay }
                
                if isLoading {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    ProgressView().tint(.white).scaleEffect(1.5)
                }
            }
            .colorScheme(.dark)
            .navigationTitle("Challenge")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }.foregroundColor(.gray)
                }
            }
        }
    }
    
    // MARK: - Friend Header
    var friendHeader: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 56, height: 56)
                Text(String(friend.username.prefix(1)).uppercased())
                    .font(.title2.bold())
                    .foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("Challenge").font(.caption).foregroundColor(.gray)
                Text(friend.username).font(.title3.bold()).foregroundColor(.white)
            }
            Spacer()
            Image(systemName: "bolt.fill")
                .font(.title2).foregroundColor(.yellow).padding(12)
                .glassEffect(.regular.tint(.yellow.opacity(0.2)), in: .circle)
        }
        .padding()
        .glassEffect(.regular.tint(.white.opacity(0.05)), in: .rect(cornerRadius: 20))
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    // MARK: - Step Indicator
    var stepIndicator: some View {
        HStack(spacing: 0) {
            ForEach(1...3, id: \.self) { step in
                HStack(spacing: 0) {
                    ZStack {
                        Circle()
                            .fill(step <= currentStep ? Color.purple : Color.white.opacity(0.1))
                            .frame(width: 32, height: 32)
                        if step < currentStep {
                            Image(systemName: "checkmark").font(.caption.bold()).foregroundColor(.white)
                        } else {
                            Text("\(step)").font(.caption.bold())
                                .foregroundColor(step == currentStep ? .white : .gray)
                        }
                    }
                    if step < 3 {
                        Rectangle()
                            .fill(step < currentStep ? Color.purple : Color.white.opacity(0.1))
                            .frame(height: 2).frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(.horizontal, 40)
    }
    
    // MARK: - Step 1: Goal Info
    var goalInfoStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Define the Goal").font(.headline).foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Goal Title").font(.caption).foregroundColor(.gray)
                TextField("e.g. Read 10 pages daily", text: $goalTitle)
                    .padding(12)
                    .glassEffect(.regular.tint(.white.opacity(0.05)), in: .rect(cornerRadius: 12))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Category").font(.caption).foregroundColor(.gray)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(GoalCategory.allCases, id: \.self) { cat in
                            Button {
                                selectedCategory = cat
                            } label: {
                                Text(cat.rawValue.capitalized)
                                    .font(.caption.bold())
                                    .padding(.vertical, 8).padding(.horizontal, 14)
                                    .glassEffect(
                                        .regular.tint(selectedCategory == cat ? .purple.opacity(0.4) : .white.opacity(0.05)),
                                        in: .capsule
                                    )
                                    .foregroundColor(selectedCategory == cat ? .purple : .white)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Goal Type").font(.caption).foregroundColor(.gray)
                goalTypeGrid
            }
        }
        .padding()
        .glassEffect(.regular.tint(.white.opacity(0.03)), in: .rect(cornerRadius: 20))
    }
    
    // منفصلة لتجنب خطأ الـ compiler
    var goalTypeGrid: some View {
        HStack(spacing: 8) {
            ForEach(GoalType.allCases, id: \.self) { type in
                Button {
                    selectedType = type
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: iconForGoalType(type)).font(.title3)
                        Text(labelForGoalType(type)).font(.caption2).multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .glassEffect(
                        .regular.tint(selectedType == type ? .blue.opacity(0.3) : .white.opacity(0.05)),
                        in: .rect(cornerRadius: 14)
                    )
                    .foregroundColor(selectedType == type ? .cyan : .white)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private func iconForGoalType(_ type: GoalType) -> String {
        switch type {
        case .finishTotal:    return "checkmark.circle.fill"
        case .repeatSchedule: return "repeat.circle.fill"
        case .buildStreak:    return "flame.fill"
        case .levelUp:        return "arrow.up.circle.fill"
        case .milestones:     return "flag.fill"
        case .reduce:         return "minus.circle.fill"
        }
    }
    
    private func labelForGoalType(_ type: GoalType) -> String {
        switch type {
        case .finishTotal:    return "Finish"
        case .repeatSchedule: return "Repeat"
        case .buildStreak:    return "Streak"
        case .levelUp:        return "Level Up"
        case .milestones:     return "Milestones"
        case .reduce:         return "Reduce"
        }
    }
    
    // MARK: - Step 2: Planet
    var planetStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Stake a Planet").font(.headline).foregroundColor(.white)
            Text("Select a completed planet to put at stake. If you lose the challenge, your friend wins it!")
                .font(.caption).foregroundColor(.gray).multilineTextAlignment(.leading)
            
            if let planet = selectedPlanet {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.purple, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 50, height: 50)
                        Image(systemName: "globe.americas.fill").font(.title2).foregroundColor(.white)
                    }
                    VStack(alignment: .leading) {
                        Text("Planet \(planet.id.prefix(6))").font(.subheadline.bold()).foregroundColor(.white)
                        Text("Completed · Ready to stake").font(.caption).foregroundColor(.green)
                    }
                    Spacer()
                    Button {
                        selectedPlanet = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill").foregroundColor(.gray)
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                .glassEffect(.regular.tint(.purple.opacity(0.2)), in: .rect(cornerRadius: 16))
                
            } else {
                Button {
                    showPlanetPicker = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.dashed").font(.title2)
                        Text("Choose a Planet").font(.subheadline.bold())
                        Spacer()
                        Image(systemName: "chevron.right").font(.caption).foregroundColor(.gray)
                    }
                    .padding()
                    .glassEffect(.regular.tint(.white.opacity(0.05)), in: .rect(cornerRadius: 16))
                    .foregroundColor(.white)
                }
                .buttonStyle(.plain)
            }
            
            HStack(spacing: 12) {
                Image(systemName: "info.circle.fill").foregroundColor(.yellow)
                Text("Only completed planets can be staked in a challenge.")
                    .font(.caption).foregroundColor(.gray)
            }
            .padding(12)
            .glassEffect(.regular.tint(.yellow.opacity(0.05)), in: .rect(cornerRadius: 12))
        }
        .padding()
        .glassEffect(.regular.tint(.white.opacity(0.03)), in: .rect(cornerRadius: 20))
    }
    
    // MARK: - Step 3: SubTasks
    var subTasksStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Sub Tasks").font(.headline).foregroundColor(.white)
                Spacer()
                Text("\(subTaskConfigs.count) tasks").font(.caption).foregroundColor(.gray)
            }
            Text("Break the goal into steps. Both you and your friend must complete these.")
                .font(.caption).foregroundColor(.gray)
            
            HStack(spacing: 10) {
                TextField("Add a task...", text: $newSubTaskTitle)
                    .padding(10)
                    .glassEffect(.regular.tint(.white.opacity(0.05)), in: .rect(cornerRadius: 10))
                    .foregroundColor(.white)
                Button {
                    addSubTask()
                } label: {
                    Image(systemName: "plus").foregroundColor(.white).padding(10)
                        .glassEffect(.regular.tint(.purple.opacity(0.3)), in: .circle)
                }
                .buttonStyle(.plain)
                .disabled(newSubTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            
            if subTaskConfigs.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "checklist").font(.largeTitle).foregroundColor(.gray.opacity(0.5))
                        Text("No tasks yet").font(.caption).foregroundColor(.gray)
                    }
                    .padding(.vertical, 20)
                    Spacer()
                }
            } else {
                ForEach(Array(subTaskConfigs.enumerated()), id: \.element.title) { index, task in
                    HStack {
                        Text("\(index + 1)").font(.caption.bold()).foregroundColor(.purple)
                            .frame(width: 24, height: 24)
                            .background(Circle().fill(Color.purple.opacity(0.2)))
                        Text(task.title).foregroundColor(.white).font(.subheadline)
                        Spacer()
                        Button {
                            subTaskConfigs.remove(at: index)
                        } label: {
                            Image(systemName: "trash").font(.caption).foregroundColor(.red.opacity(0.8))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(12)
                    .glassEffect(.regular.tint(.white.opacity(0.03)), in: .rect(cornerRadius: 12))
                }
            }
            
            if let err = errorMsg {
                Text(err).font(.caption).foregroundColor(.red).padding(10)
                    .glassEffect(.regular.tint(.red.opacity(0.1)), in: .rect(cornerRadius: 10))
            }
        }
        .padding()
        .glassEffect(.regular.tint(.white.opacity(0.03)), in: .rect(cornerRadius: 20))
    }
    
    // MARK: - Bottom Buttons
    var bottomButtons: some View {
        HStack(spacing: 12) {
            if currentStep > 1 {
                Button {
                    withAnimation { currentStep -= 1 }
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 14)
                    .glassEffect(.regular.tint(.white.opacity(0.05)), in: .capsule)
                }
                .buttonStyle(.plain)
            }
            
            Button {
                if currentStep < 3 {
                    if validateCurrentStep() { withAnimation { currentStep += 1 } }
                } else {
                    Task { await sendChallenge() }
                }
            } label: {
                HStack {
                    Text(currentStep < 3 ? "Next" : "Send Challenge").bold()
                    Image(systemName: currentStep < 3 ? "chevron.right" : "bolt.fill")
                }
                .foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 14)
                .glassEffect(
                    .regular.tint(currentStep < 3 ? .blue.opacity(0.3) : .purple.opacity(0.4)),
                    in: .capsule
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Success Overlay
    var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 80, height: 80)
                    Image(systemName: "bolt.fill").font(.largeTitle).foregroundColor(.white)
                }
                Text("Challenge Sent!").font(.title2.bold()).foregroundColor(.white)
                Text("Waiting for \(friend.username) to accept.")
                    .font(.subheadline).foregroundColor(.gray).multilineTextAlignment(.center)
                Button {
                    dismiss()
                } label: {
                    Text("Done").bold().foregroundColor(.white)
                        .padding(.vertical, 14).padding(.horizontal, 40)
                        .glassEffect(.regular.tint(.purple.opacity(0.4)), in: .capsule)
                }
                .buttonStyle(.plain)
            }
            .padding(30)
            .glassEffect(.regular.tint(.white.opacity(0.05)), in: .rect(cornerRadius: 24))
            .padding(.horizontal, 40)
        }
    }
    
    // MARK: - Helpers
    private func addSubTask() {
        let title = newSubTaskTitle.trimmingCharacters(in: .whitespaces)
        guard !title.isEmpty else { return }
        subTaskConfigs.append(SubTaskConfig(title: title, description: nil, dependsOn: nil))
        newSubTaskTitle = ""
    }
    
    private func validateCurrentStep() -> Bool {
        errorMsg = nil
        switch currentStep {
        case 1:
            if goalTitle.trimmingCharacters(in: .whitespaces).isEmpty {
                errorMsg = "Please enter a goal title."
                return false
            }
        case 2:
            if selectedPlanet == nil {
                errorMsg = "Please select a planet to stake."
                return false
            }
        default: break
        }
        return true
    }
    
    private func sendChallenge() async {
        guard let planet = selectedPlanet,
              let currentUserID = friendRequestVM.currentUser?.id else {
            errorMsg = "Missing required info."
            return
        }
        isLoading = true
        errorMsg = nil
        do {
            try await challengeVM.createChallenge(
                challengerID: currentUserID,
                opponentID: friend.id,
                planetStake: planet,
                goalTitle: goalTitle,
                goalCategory: selectedCategory,
                goalType: selectedType,
                goalShape: selectedShape,
                subTasksConfig: subTaskConfigs
            )
            await MainActor.run {
                isLoading = false
                showSuccess = true
            }
        } catch {
            await MainActor.run {
                isLoading = false
                errorMsg = error.localizedDescription
            }
        }
    }
}
