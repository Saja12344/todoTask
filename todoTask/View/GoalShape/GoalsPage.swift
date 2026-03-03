//
//  GoalsPage.swift
//  todoTask
//

import SwiftUI

private enum CreationStep: Hashable {
    case write
    case loading(shape: GoalShape, text: String)
    case suggested(shape: GoalShape, text: String)
    case manual(typePrefill: GoalType?)
    case form(type: GoalType)
    case design
}

struct GoalsPage: View {
    @EnvironmentObject private var store: OrbGoalStore

    @State private var path:              [CreationStep] = []
    @State private var showDeleteConfirm  = false
    @State private var goalPendingDelete: OrbGoal?
    @State private var draftTitle:        String         = ""
    @State private var chosenType:        GoalType?      = nil
    @State private var chosenSettings:    GoalSettings?  = nil

    @StateObject private var energyVM = DailyEnergyViewModel()
    @State private var selectedTab = 0
    
    private let columns: [GridItem] = [GridItem(.adaptive(minimum: 170), spacing: 16)]

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.darkBlu, .black],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .ignoresSafeArea()
                Image("Background 4").resizable().ignoresSafeArea().opacity(0.35)
                Image("Gliter").resizable().ignoresSafeArea()
                
                VStack(spacing: 16) {
                    
                    Picker("", selection: $selectedTab) {
                        Text("Your Orbs").tag(0)
                        Text("Shared Orbs").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    if selectedTab == 0 {
                        ScrollView(showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Your Orbs")
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 16).padding(.top, 8)
                                
                                LazyVGrid(columns: columns, spacing: 16) {
                                    ForEach(store.goals) { goal in
                                        NavigationLink {
                                            GoalTasksView(goalID: goal.id)
                                        } label: {
                                            GoalGridCard(goal: goal)
                                        }
                                        .buttonStyle(.plain)
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                goalPendingDelete = goal
                                                showDeleteConfirm = true
                                            } label: { Label("Delete Orb", systemImage: "trash") }
                                        }
                                        .onLongPressGesture(minimumDuration: 0.6) {
                                            goalPendingDelete = goal
                                            showDeleteConfirm = true
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                                Spacer().frame(height: 30)
                            }
                        }
                        
                    } else {
                        
                        ScrollView {
                            Text("Shared Orbs")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                            
                            // هنا لاحقاً تضيفي الشيرد أورب
                            Text("Coming soon...")
                                .foregroundColor(.white.opacity(0.6))
                                .padding()
                        }
                        
                    }
                }
            }
                    
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { startCreation() } label: { Image(systemName: "plus") }
                        .foregroundStyle(.white)
                }
            }
            .confirmationDialog("Delete this orb?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    if let g = goalPendingDelete { store.delete(goalID: g.id) }
                    goalPendingDelete = nil
                }
                Button("Cancel", role: .cancel) { goalPendingDelete = nil }
            } message: { Text("This will remove the orb and its progress.") }
            .colorScheme(.dark)
            .onAppear { energyVM.refreshToday() }

            .navigationDestination(for: CreationStep.self) { step in
                switch step {
                case .write:
                    WriteGoalView(onDone: { title, suggestion in
                        draftTitle = title
                        if let shape = suggestion {
                            path.append(.loading(shape: shape, text: title))
                        } else {
                            path.append(.manual(typePrefill: nil))
                        }
                    }, onCancel: { _ = path.popLast() })
                    .navigationBarBackButtonHidden(true)

                case let .suggested(shape, text):
                    SuggestedGoalShapeView(
                        goalText: text, suggestedShape: shape,
                        onFinish: { type in chosenType = type; path.append(.form(type: type)) },
                        onChangeShape: { path.append(.manual(typePrefill: nil)) },
                        onBack: { _ =
//                            path.popLast()
                            path.removeLast(2)
                        }
                    )
                    .navigationBarBackButtonHidden(true)
                    
                case let .loading(shape, text):
                    LoadingGoalShapesView(
                        goalText: text,
                        suggestedShape: shape
                    ) {
                        path.append(.suggested(shape: shape, text: text))
                    }
//                    .navigationBarBackButtonHidden(true)
                case let .manual(typePrefill):
                    GoalShapeView(
                        selectedGoal: typePrefill, showSettings: false,
                        onFinished: { type, settings in chosenType = type; chosenSettings = settings; path.append(.form(type: type)) },
                        onBack: { _ = path.popLast() }
                    )
                    .navigationBarBackButtonHidden(true)

                case let .form(type):
                    GoalShapeView(
                        selectedGoal: type, showSettings: true,
                        onFinished: { type, settings in chosenType = type; chosenSettings = settings; path.append(.design) },
                        onBack: { _ = path.popLast() }
                    )
                    .navigationBarBackButtonHidden(true)

                case .design:
                    GoalDesign { design in
                        var newGoal = OrbGoal(
                            id: UUID(),
                            title: draftTitle.isEmpty ? "New Goal" : draftTitle,
                            design: design,
                            settings: chosenSettings
                        )
                        if let settings = chosenSettings {
                            newGoal.tasks = OrbGoalStore.TaskGenerator.generate(
                                from: settings, goalID: newGoal.id,
                                goalTitle: newGoal.title, scheduledDate: Date()
                            )
                        }
                        store.add(newGoal)
                        path.removeAll()
                    }
                    .environmentObject(store)
//                    .preferredColorScheme(.dark)
                    .navigationBarBackButtonHidden(true)
                }
            }
        }
    }

    private func startCreation() {
        draftTitle = ""; chosenType = nil; chosenSettings = nil
        path = [.write]
    }
}

// MARK: - GoalGridCard
struct GoalGridCard: View {
    let goal: OrbGoal
    @State private var anim: Double = 0

    var body: some View {
        let float = CGFloat(sin(anim) * 1.4)
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 4) {
                PlanetOrbView(
                    size: 72,
                    gradientColors: goal.design.gradientStops.map { $0.swiftUIColor },
                    glow: min(goal.design.glow, 0.12),
                    textureAssetName: goal.design.textureAssetName,
                    textureOpacity: goal.design.textureOpacity
                )
                .offset(y: float - 2)
                .onAppear {
                    withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                        anim = 2 * .pi
                    }
                }
                // Mini dual ring اذا تحدي
                .overlay(
                    Group {
                        if goal.isChallenge, let info = goal.challengeInfo {
                            MiniDualRing(myProgress: goal.progress, friendProgress: info.friendProgress)
                                .frame(width: 88, height: 88)
                        }
                    }
                )

                VStack(alignment: .leading, spacing: 8) {
                    Text(goal.title)
                        .font(.system(size: 15, weight: .semibold)).foregroundStyle(.white).lineLimit(1)
                    HStack(spacing: 8) {
                        ProgressView(value: goal.progress)
                            .tint(.white).frame(maxWidth: .infinity).scaleEffect(x: 1, y: 0.9, anchor: .center)
                        Text("\(Int(goal.progress * 100))%")
                            .font(.system(size: 12, weight: .semibold)).foregroundStyle(.white.opacity(0.9))
                            .frame(minWidth: 34, alignment: .trailing)
                    }
                    Text("\(goal.doneTasks)/\(goal.totalTasks) tasks")
                        .font(.system(size: 12, weight: .medium)).foregroundStyle(.white.opacity(0.75))
                }
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 14).fill(.black.opacity(0.28)))
                .offset(y: -65)
            }
            .padding(12).frame(width: 180, height: 208)
            .background(
                RoundedRectangle(cornerRadius: 18).fill(.white.opacity(0.06))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(.white.opacity(0.12), lineWidth: 1))
            )
            .contentShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: .black.opacity(0.22), radius: 8, x: 0, y: 5)

            // ⚡️ Challenge Badge
            if goal.isChallenge {
                Text("⚡️")
                    .font(.caption)
                    .padding(6)
                    .background(Circle().fill(Color.yellow.opacity(0.25)))
                    .padding(8)
            }
        }
    }
}

// MARK: - Mini Dual Ring (للكارد الصغير)
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
