//
//  GoalsPage.swift
//  todoTask
//

import SwiftUI

private enum CreationStep: Hashable {
    case write
    case manual(typePrefill: GoalType?)
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

    var body: some View {
        NavigationStack(path: $path) {
            GeometryReader { geo in
                ZStack {
                    LinearGradient(
                        colors: [Color(hex: "0a0a1a"), Color(hex: "0d1b3e"), Color(hex: "0a0a1a")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()

                    ScrollView(showsIndicators: false) {
                        ZStack(alignment: .top) {

                            ForEach(0..<3, id: \.self) { i in
                                Image("Star")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: geo.size.width, height: geo.size.height * 1.2)
                                    .opacity(0.85 - Double(i) * 0.2)
                                    .offset(y: CGFloat(i) * geo.size.height * 0.9)
                                    .overlay(
                                        LinearGradient(
                                            colors: [
                                                .clear,
                                                Color(hex: "0a0a1a").opacity(Double(i + 1) * 0.4)
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                            }

                            if store.goals.isEmpty {
                                VStack(spacing: 16) {
                                    Spacer().frame(height: geo.size.height * 0.3)
                                    Image(systemName: "moon.stars")
                                        .font(.system(size: 60))
                                        .foregroundColor(.white.opacity(0.2))
                                    Text("No Orbs Yet")
                                        .font(.title2.bold())
                                        .foregroundColor(.white.opacity(0.4))
                                    Text("Tap + to create your first goal")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.3))
                                }
                                .frame(width: geo.size.width)
                            } else {
                                SpaceOrbsLayout(
                                    goals: store.goals,
                                    screenWidth: geo.size.width,
                                    onDelete: { goal in
                                        goalPendingDelete = goal
                                        showDeleteConfirm = true
                                    }
                                )
                                .padding(.bottom, 120)
                            }
                        }
                    }

                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button { startCreation() } label: {
                                Image(systemName: "plus")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 60)
                                    .background(
                                        Circle()
                                            .fill(Color.blue.opacity(0.3))
                                            .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 1))
                                    )
                                    .shadow(color: .blue.opacity(0.5), radius: 20)
                            }
                            .padding(.trailing, 24)
                            .padding(.bottom, 24)
                        }
                    }
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
                        // ✅ مباشرة للـ manual بدون loading أو suggested
                        path.append(.manual(typePrefill: nil))
                    }, onCancel: { _ = path.popLast() })
                    .navigationBarBackButtonHidden(true)

                case let .manual(typePrefill):
                    GoalShapeView(
                        selectedGoal: typePrefill,
                        showSettings: typePrefill != nil,
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

                SpaceOrbCard(goal: goal, size: size)
                    .position(x: xPos, y: yPos)
                    .contextMenu {
                        Button(role: .destructive) {
                            onDelete(goal)
                        } label: {
                            Label("Delete Orb", systemImage: "trash")
                        }
                    }
            }
        }
        .frame(width: screenWidth, height: totalHeight)
    }
}

// MARK: - Space Orb Card
struct SpaceOrbCard: View {
    let goal: OrbGoal
    let size: CGFloat

    @State private var floatY: CGFloat = 0
    @State private var floatX: CGFloat = 0
    @State private var rotation: Double = 0

    var body: some View {
        NavigationLink(destination: GoalTasksView(goalID: goal.id)) {
            VStack(spacing: 0) {
                PlanetOrbView(
                    size: size,
                    gradientColors: goal.design.gradientStops.map { $0.swiftUIColor },
                    glow: goal.design.glow,
                    textureAssetName: goal.design.textureAssetName,
                    textureOpacity: goal.design.textureOpacity
                )
                .offset(x: floatX, y: floatY)
                .rotationEffect(.degrees(rotation))

                VStack(spacing: 2) {
                    Text(goal.title)
                        .font(.system(size: min(size * 0.13, 15), weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .shadow(color: .black.opacity(0.8), radius: 4)

                    Text("\(Int(goal.progress * 100))%")
                        .font(.system(size: min(size * 0.11, 13), weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                        .shadow(color: .black.opacity(0.8), radius: 4)
                }
                .padding(.top, -size * 0.45)
            }
        }
        .buttonStyle(.plain)
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

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}
