//
//  GoalTasksView.swift
//  todoTask
//
//  Created by Ruba Alghamdi on 26/08/1447 AH.
//
import SwiftUI
import Foundation

struct GoalTasksView: View {

    @EnvironmentObject private var store: OrbGoalStore

    @State private var vm = GoalTasksViewModel()

    @State private var showDeleteConfirm: Bool = false
    @State private var taskPendingDelete: GoalTask?
    @State private var showAddSheet: Bool = false

    // Accept a goal id so we can fetch live from the store
    private let goalID: UUID?
    @State private var pendingTitle: String?

    // Backward-compatible init: can pass either id or title
    init(goalID: UUID? = nil, goalTitle: String? = nil) {
        self.goalID = goalID
        _vm = State(initialValue: GoalTasksViewModel())
        _pendingTitle = State(initialValue: goalTitle)
    }

    // Resolve current goal if available
    private var currentGoal: OrbGoal? {
        guard let id = goalID else { return nil }
        return store.goal(with: id)
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color("color"), Color("dark")],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .ignoresSafeArea()

            Image("Background 1")
                .resizable()
                .ignoresSafeArea()

            Image("Gliter")
                .resizable()
                .ignoresSafeArea()

            VStack(spacing: 16) {

                ZStack {
                    // Show the same planet design if we have the goal
                    if let goal = currentGoal {
                        PlanetOrbView(
                            size: 235,
                            gradientColors: goal.design.gradientStops.map { $0.swiftUIColor },
                            glow: min(goal.design.glow, 0.15),
                            textureAssetName: goal.design.textureAssetName,
                            textureOpacity: goal.design.textureOpacity
                        )
                        .frame(width: 235, height: 235)
                    } else {
                        Image("planet")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 235)
                    }

                    ProgressCircle(progress: vm.progress)
                        .frame(width: 290, height: 290)
                }
                .padding(.top, 10)

                ZStack(alignment: .bottomTrailing) {

                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .frame(height: 350)

                    VStack(alignment: .leading, spacing: 14) {
                        Text(currentGoal?.title ?? vm.goalTitle)
                            .font(.title2)
                            .bold()
                        
                        Text("\(vm.tasks.count) tasks")
                            .font(.default)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 16)

                        ScrollView {
                            VStack(spacing: 14) {
                                ForEach(vm.tasks) { task in
                                    BulletTaskRow(title: task.title)
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                taskPendingDelete = task
                                                showDeleteConfirm = true
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .scrollIndicators(.hidden)
                    }
                    .padding(22)

                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2.weight(.semibold))
                            .foregroundColor(.white)
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
        .preferredColorScheme(.dark)

        .sheet(isPresented: $showAddSheet) {
            AddTaskSheet(goalTitle: currentGoal?.title ?? vm.goalTitle) { spec in
                vm.addTask(spec: spec)
            }
        }

        .confirmationDialog("Delete this task?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                if let task = taskPendingDelete {
                    vm.deleteTask(taskID: task.id)
                }
                taskPendingDelete = nil
            }
            Button("Cancel", role: .cancel) {
                taskPendingDelete = nil
            }
        }
        .onAppear {
            // Fallback for older call sites that still pass a title
            if let title = pendingTitle, !title.isEmpty {
                vm.goalTitle = title
                pendingTitle = nil
            }
        }
    }
}

#Preview {
    let store = OrbGoalStore()
    if store.goals.isEmpty { store.add(.mock) }
    return NavigationStack {
        GoalTasksView(goalID: store.goals.first?.id)
            .environmentObject(store)
    }
}

