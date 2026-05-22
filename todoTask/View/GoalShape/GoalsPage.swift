//
//  GoalsPage.swift
//  todoTask
//

import SwiftUI


struct GoalsPage: View {
    @EnvironmentObject private var store: OrbGoalStore
    @EnvironmentObject private var lang: LanguageManager

    @State private var navPath = NavigationPath()
    @State private var showDeleteConfirm  = false
    @State private var goalPendingDelete: OrbGoal?
    @State private var draftTitle:        String         = ""
    @State private var chosenType:        GoalType?      = nil
    @State private var chosenSettings:    GoalSettings?  = nil

    @StateObject private var energyVM = DailyEnergyViewModel()

    var body: some View {
        NavigationStack(path: $navPath) {
            GeometryReader { geo in
                ZStack {
                    AppBackground()

                    ScrollView(showsIndicators: false) {
                        if store.goals.isEmpty {
                            VStack(spacing: 16) {
                                Spacer().frame(height: 120)
                                Image(systemName: "moon.stars")
                                    .font(.system(size: 60))
                                    .foregroundColor(.white.opacity(0.2))
                                Text(lang.t(.noOrbsYet))
                                    .font(.title2.bold())
                                    .foregroundColor(.white.opacity(0.4))
                                Text(lang.t(.tapCreateFirst))
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.3))
                            }
                            .frame(width: geo.size.width)
                        } else {
                            SpaceOrbsLayout(
                                goals: store.goals.sorted { $0.createdAt < $1.createdAt },
                                screenWidth: geo.size.width,
                                onDelete: { goal in
                                    goalPendingDelete = goal
                                    DispatchQueue.main.async {
                                        showDeleteConfirm = true
                                    }
                                }
                            )
                            .padding(.bottom, 120)
                        }
                    }
                }
                .overlay(alignment: .bottomTrailing) {
                    GoalFlowAddButton(size: 56, action: startCreation)
                        .padding(.trailing, 24)
                        .padding(.bottom, 24)
                }
            }
            .navigationTitle(lang.t(.tabOrbs))
            .navigationBarTitleDisplayMode(.large)
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
            .onAppear { energyVM.refreshToday() }
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
                            navPath.append(GoalCreationStep.configure(type: nil, draftText: "", openSettings: false))
                        },
                        onCancel: { if !navPath.isEmpty { navPath.removeLast() } }
                    )

                case let .suggested(text, type):
                    SuggestedGoalView(
                        goalText: text,
                        suggestedType: type,
                        onContinue: { chosen in
                            chosenType = chosen
                            navPath.append(GoalCreationStep.configure(type: chosen, draftText: draftTitle, openSettings: true))
                        },
                        onBack: { if !navPath.isEmpty { navPath.removeLast() } }
                    )

                case let .configure(type, draftText, openSettings):
                    GoalShapeView(
                        selectedGoal: type,
                        draftText: draftText,
                        openSettingsDirectly: openSettings,
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

// MARK: - Space Orbs Layout
struct SpaceOrbsLayout: View {
    let goals: [OrbGoal]
    let screenWidth: CGFloat
    let onDelete: (OrbGoal) -> Void

    private func orbSize(for index: Int) -> CGFloat {
        let fractions: [CGFloat] = [0.32, 0.22, 0.28, 0.20, 0.30, 0.24, 0.26, 0.21]
        return screenWidth * fractions[index % fractions.count]
    }

    private func xFraction(for index: Int) -> CGFloat {
        let positions: [CGFloat] = [0.25, 0.72, 0.42, 0.78, 0.20, 0.62, 0.80, 0.38]
        return positions[index % positions.count]
    }

    var body: some View {
        let rowHeight = screenWidth * 0.55
        let totalHeight = CGFloat(goals.count) * rowHeight + 160

        ZStack(alignment: .topLeading) {
            ForEach(Array(goals.enumerated()), id: \.element.id) { index, goal in
                let size = orbSize(for: index)
                let xPos = screenWidth * xFraction(for: index)
                let yPos = CGFloat(index) * rowHeight + rowHeight / 2

                SpaceOrbCard(goal: goal, size: size, onDelete: { onDelete(goal) })
                    .position(x: xPos, y: yPos)
            }
        }
        .frame(width: screenWidth, height: totalHeight)
    }
}

// MARK: - Space Orb Card
struct SpaceOrbCard: View {
    let goal: OrbGoal
    let size: CGFloat
    var onDelete: () -> Void = {}

    @State private var floatY: CGFloat = 0
    @State private var floatX: CGFloat = 0
    @State private var rotation: Double = 0

    var body: some View {
        NavigationLink(value: goal.id) {
            VStack(spacing: 6) {
                PlanetOrbView(
                    size: size,
                    gradientColors: goal.design.gradientStops.map { $0.swiftUIColor },
                    glow: goal.design.glow,
                    textureAssetName: goal.design.textureAssetName,
                    textureOpacity: goal.design.textureOpacity
                )
                .offset(x: floatX, y: floatY)
                .rotationEffect(.degrees(rotation))

                Text(goal.title)
                    .font(.system(size: min(size * 0.13, 15), weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.8), radius: 4)
                    .frame(maxWidth: size * 1.2)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label("Delete Orb", systemImage: "trash")
            }
        }
        .onAppear {
            let duration = Double.random(in: 3...5)
            withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                floatY = CGFloat.random(in: -10...10)
                floatX = CGFloat.random(in: -8...8)
                rotation = Double.random(in: -4...4)
            }
        }
    }
}

// MARK: - Mini Dual Ring
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
