//
//  GoalsPage.swift
//  todoTask
//
//  استبدل الملف الموجود بهذا كاملاً
//

import SwiftUI

private enum CreationStep: Hashable {
    case write
    case suggested(shape: GoalShape, text: String)
    case manual(typePrefill: GoalType?)
    case form(type: GoalType)
    case design
}

struct GoalsPage: View {
    @EnvironmentObject private var store: OrbGoalStore

    @State private var path:           [CreationStep] = []
    @State private var showDeleteConfirm = false
    @State private var goalPendingDelete: OrbGoal?
    @State private var draftTitle:     String        = ""
    @State private var chosenType:     GoalType?     = nil
    @State private var chosenSettings: GoalSettings? = nil

    // طاقة اليوم لتعديل عدد المهام
    @StateObject private var energyVM = DailyEnergyViewModel()

    private let columns: [GridItem] = [GridItem(.adaptive(minimum: 170), spacing: 16)]

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Rectangle()
                    .fill(LinearGradient(colors: [Color("color"), Color("dark")], startPoint: .bottom, endPoint: .top))
                    .ignoresSafeArea()
                Image("Background 4").resizable().ignoresSafeArea().opacity(0.35)
                Image("Gliter").resizable().ignoresSafeArea()

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

            // ── Navigation destinations ───────────────────────────
            .navigationDestination(for: CreationStep.self) { step in
                switch step {

                case .write:
                    WriteGoalView(onDone: { title, suggestion in
                        draftTitle = title
                        if let shape = suggestion {
                            path.append(.suggested(shape: shape, text: title))
                        } else {
                            path.append(.manual(typePrefill: nil))
                        }
                    }, onCancel: { _ = path.popLast() })
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
                            chosenType     = type
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
                            chosenType     = type
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

                        // ولّد المهام مرة واحدة فقط
                        if let settings = chosenSettings {
                            newGoal.tasks = TaskGenerator.generate(
                                from: settings,
                                goalID: newGoal.id,
                                goalTitle: newGoal.title,
                                energyFactor: energyFactor(from: energyVM.todayEntry)
                            )
                        }

                        // بعد ما اكتمل الهدف مع مهامه — خزّنه
                        store.add(newGoal)

                        path.removeAll()
                    }
                    .environmentObject(store)
                    .preferredColorScheme(.dark)
                    .navigationBarBackButtonHidden(true)
                }
            }
        }
    }

    private func startCreation() {
        draftTitle     = ""
        chosenType     = nil
        chosenSettings = nil
        path           = [.write]
    }

    private func energyFactor(from entry: DailyEnergyEntry?) -> Double {
        guard let entry else { return 0.7 }
        switch entry.value {
        case "3": return 1.0
        case "1": return 0.5
        default:  return 0.7
        }
    }
}

// MARK: - GoalGridCard
private struct GoalGridCard: View {
    let goal: OrbGoal
    @State private var anim: Double = 0

    var body: some View {
        let float = CGFloat(sin(anim) * 1.4)
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
    }
}

//#Preview {
//    let store = OrbGoalStore()
//    if store.goals.isEmpty { store.add(.mock) }
//    return GoalsPage()
//        .environmentObject(store)
//        .preferredColorScheme(.dark)
//}
//

