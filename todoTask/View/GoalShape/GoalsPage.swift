//
//  GoalsPage.swift
//  todoTask
//

import SwiftUI

struct GoalsPage: View {
    @EnvironmentObject private var store: OrbGoalStore
    @EnvironmentObject private var lang: LanguageManager
    @EnvironmentObject private var challengeOrbs: ChallengeOrbsManager
    @EnvironmentObject private var userVM: UserViewModel

    @State private var navPath = NavigationPath()
    @State private var showDeleteConfirm  = false
    @State private var goalPendingDelete: OrbGoal?
    @State private var draftTitle:        String         = ""
    @State private var chosenType:        GoalType?      = nil
    @State private var chosenSettings:    GoalSettings?  = nil
    @State private var challengeGoalOpen: OrbGoal?

    @StateObject private var energyVM = DailyEnergyViewModel()

    private var sortedGoals: [OrbGoal] {
        store.goals.sorted { lhs, rhs in
            if lhs.isChallenge != rhs.isChallenge { return lhs.isChallenge && !rhs.isChallenge }
            return lhs.createdAt < rhs.createdAt
        }
    }

    var body: some View {
        NavigationStack(path: $navPath) {
            GeometryReader { geo in
                ZStack {
                    GalaxyBackgroundView()

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            if !store.goals.isEmpty {
                                GalaxyHeaderView(goals: sortedGoals)
                                    .padding(.bottom, 8)
                            }

                            if store.goals.isEmpty {
                                GalaxyEmptyStateView()
                                    .frame(minHeight: geo.size.height * 0.72)
                            } else {
                                Color.clear
                                    .frame(height: geo.size.height * 0.32)

                                GalaxyOrbsCanvas(
                                    goals: sortedGoals,
                                    screenWidth: geo.size.width,
                                    onDelete: { goal in
                                        goalPendingDelete = goal
                                        DispatchQueue.main.async {
                                            showDeleteConfirm = true
                                        }
                                    },
                                    onChallengeTap: { goal in
                                        challengeGoalOpen = goal
                                    }
                                )
                                .padding(.bottom, 140)
                            }
                        }
                    }
                }
                .overlay(alignment: .bottomTrailing) {
                    GoalFlowAddButton(size: 58, action: startCreation)
                        .shadow(color: Color("accent").opacity(0.38), radius: 16, y: 6)
                        .padding(.trailing, 22)
                        .padding(.bottom, 22)
                }
            }
            .navigationTitle(lang.t(.tabOrbs))
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.hidden, for: .navigationBar)
            .alert(lang.t(.deleteOrbQuestion), isPresented: $showDeleteConfirm) {
                Button(lang.t(.deleteTask), role: .destructive) {
                    if let g = goalPendingDelete { store.delete(goalID: g.id) }
                    goalPendingDelete = nil
                }
                Button(lang.t(.cancel), role: .cancel) { goalPendingDelete = nil }
            } message: {
                Text(lang.t(.deleteOrbMessage))
            }
            .navigationDestination(for: UUID.self) { goalID in
                GoalTasksView(goalID: goalID)
            }
            .orbitForcedDark()
            .onAppear {
                energyVM.refreshToday()
                challengeOrbs.attach(store: store)
            }
            .fullScreenCover(item: $challengeGoalOpen) { goal in
                ChallengeOrbDetailView(goal: goal, onClose: { challengeGoalOpen = nil })
                    .environmentObject(store)
                    .environmentObject(lang)
                    .environmentObject(challengeOrbs)
                    .environmentObject(userVM)
            }
            .navigationDestination(for: GoalCreationStep.self) { step in
                switch step {

                case .write:
                    WriteGoalView(
                        onDone: { title, suggestion in
                            draftTitle = title
                            navPath.append(GoalCreationStep.suggested(text: title, type: suggestion))
                        },
                        onSkipToManual: {
                            draftTitle = ""
                            navPath.append(GoalCreationStep.configure(
                                type: nil, draftText: "", openSettings: false,
                                milestoneMode: false, streakMode: false
                            ))
                        },
                        onCancel: { if !navPath.isEmpty { navPath.removeLast() } }
                    )

                case let .suggested(text, type):
                    SuggestedGoalView(
                        goalText: text,
                        suggestedType: type,
                        onContinue: { option in
                            chosenType = option.goalType
                            navPath.append(GoalCreationStep.configure(
                                type: option.goalType,
                                draftText: draftTitle,
                                openSettings: true,
                                milestoneMode: option.isMilestoneMode,
                                streakMode: option.isStreakMode
                            ))
                        },
                        onBack: { if !navPath.isEmpty { navPath.removeLast() } }
                    )

                case let .configure(type, draftText, openSettings, milestoneMode, streakMode):
                    GoalShapeView(
                        selectedGoal: type,
                        draftText: draftText,
                        openSettingsDirectly: openSettings,
                        initialMilestoneMode: milestoneMode,
                        initialStreakMode: streakMode,
                        onFinished: { type, settings in
                            chosenType = type
                            chosenSettings = settings
                            navPath.append(GoalCreationStep.design)
                        },
                        onBack: { if !navPath.isEmpty { navPath.removeLast() } }
                    )

                case .design:
                    GoalDesign { design in
                        var newGoal = OrbGoal(
                            id: UUID(),
                            title: draftTitle.isEmpty ? "New Goal" : draftTitle,
                            design: design,
                            settings: chosenSettings
                        )
                        if let settings = chosenSettings {
                            newGoal.tasks = TaskGenerator.generate(
                                from: settings,
                                goalID: newGoal.id,
                                goalTitle: newGoal.title
                            )
                        }
                        store.add(newGoal)
                        navPath = NavigationPath()
                    }
                    .environmentObject(store)
                }
            }
        }
    }

    private func startCreation() {
        draftTitle = ""; chosenType = nil; chosenSettings = nil
        navPath.append(GoalCreationStep.write)
    }
}

// MARK: - Legacy helpers (kept for challenge UI elsewhere)
struct MiniDualRing: View {
    var myProgress:     Double
    var friendProgress: Double

    var body: some View {
        ZStack {
            Circle().stroke(.white.opacity(0.1), style: StrokeStyle(lineWidth: 4, lineCap: .round))
            Circle()
                .trim(from: 0, to: max(0, min(friendProgress, 1)))
                .stroke(Color.orange, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.4), value: friendProgress)
            Circle()
                .trim(from: 0, to: max(0, min(myProgress, 1)))
                .stroke(Color.cyan, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .padding(5)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.4), value: myProgress)
        }
    }
}
