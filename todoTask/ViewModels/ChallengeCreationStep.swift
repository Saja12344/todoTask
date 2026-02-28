//
//  ChallengeCreationStep.swift
//  todoTask
//
//  Created by شهد عبدالله القحطاني on 11/09/1447 AH.
//


//
//  ChallengeFriendV.swift
//  todoTask
//

import SwiftUI

// MARK: - Challenge Creation Step
private enum ChallengeCreationStep: Hashable {
    case write
    case suggested(shape: GoalShape, text: String)
    case manual(typePrefill: GoalType?)
    case form(type: GoalType)
    case design
}

struct ChallengeFriendV: View {
    let friend: User

    @EnvironmentObject private var store: OrbGoalStore
    @ObservedObject var friendRequestVM: FriendRequestViewModel
    @StateObject private var challengeVM = ChallengeViewModel()
    @StateObject private var energyVM = DailyEnergyViewModel()

    @Environment(\.dismiss) private var dismiss

    @State private var path: [ChallengeCreationStep] = []
    @State private var draftTitle: String = ""
    @State private var chosenType: GoalType? = nil
    @State private var chosenSettings: GoalSettings? = nil
    @State private var showSuccess = false
    @State private var isLoading = false
    @State private var errorMsg: String? = nil

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                LinearGradient(colors: [.darkBlu, .dark], startPoint: .bottom, endPoint: .top)
                    .ignoresSafeArea()
                Image("Gliter").resizable().ignoresSafeArea()

                VStack(spacing: 24) {
                    friendHeader

                    VStack(spacing: 12) {
                        Text("Create a goal and challenge \(friend.username) to complete it with you!")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)

                        Button {
                            startFlow()
                        } label: {
                            HStack {
                                Image(systemName: "bolt.fill")
                                Text("Start Challenge").bold()
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .glassEffect(.regular.tint(.purple.opacity(0.4)), in: .capsule)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 30)

                        if let err = errorMsg {
                            Text(err).font(.caption).foregroundColor(.red)
                        }
                    }

                    Spacer()
                }
                .padding(.top, 20)

                if isLoading {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    ProgressView().tint(.white).scaleEffect(1.5)
                }

                if showSuccess { successOverlay }
            }
            .colorScheme(.dark)
            .navigationTitle("Challenge \(friend.username)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }.foregroundColor(.gray)
                }
            }

            // ── Navigation Destinations ──
            .navigationDestination(for: ChallengeCreationStep.self) { step in
                switch step {

                case .write:
                    WriteGoalView(
                        onDone: { title, suggestion in
                            draftTitle = title
                            if let shape = suggestion {
                                path.append(.suggested(shape: shape, text: title))
                            } else {
                                path.append(.manual(typePrefill: nil))
                            }
                        },
                        onCancel: { _ = path.popLast() }
                    )
                    .navigationBarBackButtonHidden(true)

                case let .suggested(shape, text):
                    SuggestedGoalShapeView(
                        goalText: text,
                        suggestedShape: shape,
                        onFinish: { type in
                            chosenType = type
                            path.append(.form(type: type))
                        },
                        onChangeShape: { path.append(.manual(typePrefill: nil)) },
                        onBack: { _ = path.popLast() }
                    )
                    .navigationBarBackButtonHidden(true)

                case let .manual(typePrefill):
                    GoalShapeView(
                        selectedGoal: typePrefill,
                        showSettings: false,
                        onFinished: { type, settings in
                            chosenType = type
                            chosenSettings = settings
                            path.append(.form(type: type))
                        },
                        onBack: { _ = path.popLast() }
                    )
                    .navigationBarBackButtonHidden(true)

                case let .form(type):
                    GoalShapeView(
                        selectedGoal: type,
                        showSettings: true,
                        onFinished: { type, settings in
                            chosenType = type
                            chosenSettings = settings
                            path.append(.design)
                        },
                        onBack: { _ = path.popLast() }
                    )
                    .navigationBarBackButtonHidden(true)

                case .design:
                    GoalDesign { design in
                        Task { await finishChallenge(design: design) }
                    }
                    .environmentObject(store)
                    .preferredColorScheme(.dark)
                    .navigationBarBackButtonHidden(true)
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
                    .frame(width: 60, height: 60)
                Text(String(friend.username.prefix(1)).uppercased())
                    .font(.title2.bold()).foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("Challenging").font(.caption).foregroundColor(.gray)
                Text(friend.username).font(.title2.bold()).foregroundColor(.white)
            }
            Spacer()
            Image(systemName: "bolt.fill")
                .font(.title2).foregroundColor(.yellow).padding(12)
                .glassEffect(.regular.tint(.yellow.opacity(0.2)), in: .circle)
        }
        .padding()
        .glassEffect(.regular.tint(.white.opacity(0.05)), in: .rect(cornerRadius: 20))
        .padding(.horizontal)
    }

    // MARK: - Success Overlay
    var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 90, height: 90)
                    Image(systemName: "bolt.fill").font(.largeTitle).foregroundColor(.white)
                }
                Text("Challenge Sent! 🎉").font(.title2.bold()).foregroundColor(.white)
                Text("Waiting for \(friend.username) to accept your challenge.")
                    .font(.subheadline).foregroundColor(.gray)
                    .multilineTextAlignment(.center).padding(.horizontal, 20)
                Button {
                    dismiss()
                } label: {
                    Text("Done").bold().foregroundColor(.white)
                        .padding(.vertical, 14).padding(.horizontal, 50)
                        .glassEffect(.regular.tint(.purple.opacity(0.4)), in: .capsule)
                }
                .buttonStyle(.plain)
            }
            .padding(30)
            .glassEffect(.regular.tint(.white.opacity(0.05)), in: .rect(cornerRadius: 24))
            .padding(.horizontal, 30)
        }
    }

    // MARK: - Helpers
    private func startFlow() {
        draftTitle = ""
        chosenType = nil
        chosenSettings = nil
        path = [.write]
    }

    private func finishChallenge(design: OrbDesign) async {
        await MainActor.run { isLoading = true }

        // 1️⃣ إنشاء الـ Goal وتخزينه
        var newGoal = OrbGoal(
            id: UUID(),
            title: draftTitle.isEmpty ? "Challenge Goal" : draftTitle,
            design: design,
            settings: chosenSettings
        )

        if let settings = chosenSettings {
            newGoal.tasks = OrbGoalStore.TaskGenerator.generate(
                from: settings,
                goalID: newGoal.id,
                goalTitle: newGoal.title,
                scheduledDate: Date()
            )
        }

        store.add(newGoal)

        // 2️⃣ إرسال التحدي
        guard let currentUserID = friendRequestVM.currentUser?.id else {
            await MainActor.run {
                isLoading = false
                errorMsg = "User not found"
            }
            return
        }

        do {
            let planet = Planet(
                recordID: newGoal.id.uuidString,
                ownerID: currentUserID,
                state: .completed,
                goalID: newGoal.id.uuidString,
                progressPercentage: 0,
                design: nil
            )

            try await challengeVM.createChallenge(
                challengerID: currentUserID,
                opponentID: friend.id,
                planetStake: planet,
                goalTitle: newGoal.title,
                goalCategory: .habit,
                goalType: chosenType ?? .finishTotal,
                goalShape: nil,
                subTasksConfig: newGoal.tasks.map {
                    SubTaskConfig(title: $0.title, description: nil, dependsOn: nil)
                }
            )

            await MainActor.run {
                isLoading = false
                path.removeAll()
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