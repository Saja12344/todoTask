//
//  GoalTasksView.swift
//  todoTask
//
//  استبدل الملف الموجود بهذا كاملاً
//

import SwiftUI

struct GoalTasksView: View {
    @EnvironmentObject private var store: OrbGoalStore
    @State private var showAddSheet      = false
    @State private var showDeleteConfirm = false
    @State private var taskPendingDelete: GoalTask?

    let goalID: UUID

    private var goal: OrbGoal? { store.goal(with: goalID) }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(LinearGradient(colors: [Color("color"), Color("dark")], startPoint: .bottom, endPoint: .top))
                .ignoresSafeArea()
            Image("Background 1").resizable().ignoresSafeArea()
            Image("Gliter").resizable().ignoresSafeArea()

            VStack(spacing: 16) {

                // ── Planet + Progress Circle ──────────────────────
                ZStack {
                    if let goal {
                        PlanetOrbView(
                            size: 235,
                            gradientColors: goal.design.gradientStops.map { $0.swiftUIColor },
                            glow: min(goal.design.glow, 0.15),
                            textureAssetName: goal.design.textureAssetName,
                            textureOpacity: goal.design.textureOpacity
                        )
                        .frame(width: 235, height: 235)
                    }
                    ProgressCircle(progress: goal?.progress ?? 0)
                        .frame(width: 290, height: 290)
                        .animation(.easeInOut(duration: 0.4), value: goal?.progress)
                }
                .padding(.top, 10)

                // ── Tasks Panel ───────────────────────────────────
                ZStack(alignment: .bottomTrailing) {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(.ultraThinMaterial).frame(height: 390)

                    VStack(alignment: .leading, spacing: 10) {
                        // Title
                        Text(goal?.title ?? "")
                            .font(.title2).bold().foregroundColor(.white)

                        // Progress bar + stats
                        HStack {
                            Text("\(goal?.doneTasks ?? 0) / \(goal?.totalTasks ?? 0) tasks")
                                .font(.subheadline).foregroundColor(.secondary)
                            Spacer()
                            Text("\(Int((goal?.progress ?? 0) * 100))%")
                                .font(.headline.weight(.semibold)).foregroundColor(.cyan)
                        }

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4).fill(.white.opacity(0.15)).frame(height: 6)
                                RoundedRectangle(cornerRadius: 4).fill(Color.cyan)
                                    .frame(width: geo.size.width * (goal?.progress ?? 0), height: 6)
                                    .animation(.easeInOut(duration: 0.4), value: goal?.progress)
                            }
                        }
                        .frame(height: 6).padding(.bottom, 8)

                        // Tasks List
                        ScrollView {
                            VStack(spacing: 10) {
                                if let tasks = goal?.tasks, !tasks.isEmpty {
                                    ForEach(tasks) { task in
                                        TaskCheckRow(task: task) {
                                            store.toggleTask(goalID: goalID, taskID: task.id)
                                        }
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                taskPendingDelete = task
                                                showDeleteConfirm = true
                                            } label: { Label("Delete", systemImage: "trash") }
                                        }
                                    }
                                } else {
                                    VStack(spacing: 8) {
                                        Image(systemName: "tray").font(.system(size: 32)).foregroundColor(.white.opacity(0.3))
                                        Text("No tasks yet — tap + to add")
                                            .foregroundColor(.white.opacity(0.4)).font(.subheadline)
                                    }
                                    .frame(maxWidth: .infinity).padding(.top, 40)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .scrollIndicators(.hidden)
                    }
                    .padding(22)

                    // Add button
                    Button { showAddSheet = true } label: {
                        Image(systemName: "plus")
                            .font(.title2.weight(.semibold)).foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(Circle().fill(.ultraThinMaterial))
                    }
                    .padding(18)
                }
                .padding(.horizontal)

                Spacer(minLength: 0)
            }
        }
        .colorScheme(.dark)
        .sheet(isPresented: $showAddSheet) {
            AddTaskSheet(goalTitle: goal?.title ?? "") { title in
                store.addTask(goalID: goalID, title: title)
            }
        }
        .confirmationDialog("Delete this task?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                if let task = taskPendingDelete { store.deleteTask(goalID: goalID, taskID: task.id) }
                taskPendingDelete = nil
            }
            Button("Cancel", role: .cancel) { taskPendingDelete = nil }
        }
    }
}

// MARK: - TaskCheckRow
struct TaskCheckRow: View {
    let task:     GoalTask
    let onToggle: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("•").font(.title3).foregroundStyle(.white.opacity(0.9))
            Text(task.title)
                .foregroundStyle(.white)
                .opacity(task.isDone ? 0.4 : 0.92)
                .strikethrough(task.isDone, color: .white.opacity(0.4))
                .animation(.easeInOut(duration: 0.2), value: task.isDone)
            Spacer()
            Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                .foregroundColor(task.isDone ? .blue : .gray)
                .font(.system(size: 26))
                .onTapGesture { onToggle() }
                .animation(.easeInOut(duration: 0.2), value: task.isDone)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let store = OrbGoalStore()
    if store.goals.isEmpty { store.add(.mock) }
    return NavigationStack {
        GoalTasksView(goalID: store.goals.first!.id).environmentObject(store)
    }
}
