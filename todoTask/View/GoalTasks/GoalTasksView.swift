//
//  GoalTasksView.swift
//  todoTask
//
//  Created by Ruba Alghamdi on 25/08/1447 AH.
//

import SwiftUI
import Foundation

struct GoalTasksView: View {

    @State private var vm = GoalTasksViewModel()
    @FocusState private var inputFocused: Bool
    @State private var isAdding: Bool = false

    // Editing state
    @State private var taskBeingEdited: GoalTask?
    @State private var editedTitle: String = ""
    @State private var showEditAlert: Bool = false
    @State private var showDeleteConfirm: Bool = false
    @State private var taskPendingDelete: GoalTask?

    var body: some View {
        ZStack {
            Rectangle()
                .fill(LinearGradient(colors: [.color, .dark], startPoint: .bottom, endPoint: .top))
                .ignoresSafeArea()

            Image("Background 1")
                .resizable()
                .ignoresSafeArea()

            Image("Gliter")
                .resizable()
                .ignoresSafeArea()

            VStack(spacing: 16) {

                // Planet + Progress
                ZStack {
                    Image("planet")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 235)

                    ProgressCircle(progress: vm.progress) // ✅ full 360
                        .frame(width: 290, height: 290)
                }
                .padding(.top, 10)

                // Glass Card
                ZStack(alignment: .bottomTrailing) {
                    Rectangle()
                        .fill(.clear)
                        .glassEffect(.regular, in: .rect(cornerRadius: 28))
                        .frame(height: 350)

                    VStack(alignment: .leading, spacing: 14) {
                        Text(vm.goalTitle)
                            .font(.title2)
                            .bold()

                        Text("Tasks")
                            .font(.headline)
                            .opacity(0.85)

                        ScrollView {
                            VStack(spacing: 14) {
                                ForEach(vm.tasks) { task in
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            vm.toggle(task)
                                        }
                                    } label: {
                                        TaskRow(title: task.title, isDone: task.isDone)
                                    }
                                    .buttonStyle(.plain)
                                    .contextMenu {
                                        Button {
                                            taskBeingEdited = task
                                            editedTitle = task.title
                                            showEditAlert = true
                                        } label: {
                                            Label("Edit", systemImage: "pencil")
                                        }

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

                        // Add Task row appears only when isAdding is true
                        if isAdding {
                            HStack(spacing: 10) {
                                Circle()
                                    .stroke(.white.opacity(0.35), lineWidth: 2)
                                    .frame(width: 30, height: 30)

                                TextField("Add a task…", text: $vm.newTaskText)
                                    .foregroundStyle(.white)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 14)
                                    .background(.white.opacity(0.10))
                                    .clipShape(Capsule())
                                    .focused($inputFocused)
                                    .submitLabel(.done)
                                    .onAppear {
                                        // Slight delay helps avoid focus being stolen by transitions
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            inputFocused = true
                                        }
                                    }
                                    .onSubmit {
                                        addIfPossibleAndHide()
                                    }

                                Button {
                                    addIfPossibleAndHide()
                                } label: {
                                    Image(systemName: "checkmark")
                                        .font(.title3.weight(.semibold))
                                        .foregroundColor(.white)
                                        .frame(width: 44, height: 44)
                                        .background(Circle().fill(.white.opacity(0.12)))
                                }
                            }
                            .padding(.top, 6)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .animation(.easeInOut(duration: 0.2), value: isAdding)
                        }
                    }
                    .padding(22)

                    // Floating button
                    Button {
                        handleFloatingButtonTap()
                    } label: {
                        Image(systemName: floatingButtonSymbol)
                            .font(.title2.weight(.semibold))
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(Circle().fill(.ultraThinMaterial))
                    }
                    .padding(18)
                    .animation(.easeInOut(duration: 0.15), value: floatingButtonSymbol)
                }
                .padding(.horizontal)

                Spacer(minLength: 0)
            }
        }
        .colorScheme(.dark)
        .preferredColorScheme(.dark)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .alert("Edit Task", isPresented: $showEditAlert) {
            TextField("Task", text: $editedTitle)

            Button("Cancel", role: .cancel) {
                taskBeingEdited = nil
            }

            Button("Save") {
                saveEditedTask()
            }
        } message: {
            Text("Update the task")
        }
        .confirmationDialog("Delete this task?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                deletePendingTask()
            }
            Button("Cancel", role: .cancel) {
                taskPendingDelete = nil
            }
        }
    }

    // MARK: - Floating button behavior

    private var shouldShowPlus: Bool {
        !isAdding && vm.newTaskText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty
    }

    private var floatingButtonSymbol: String {
        shouldShowPlus ? "plus" : "checkmark"
    }

    private func handleFloatingButtonTap() {
        if shouldShowPlus {
            withAnimation(.easeInOut(duration: 0.2)) {
                isAdding = true
            }
            // Focus after the row is visible and animation has started
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                inputFocused = true
            }
        } else {
            addIfPossibleAndHide()
        }
    }

    private func addIfPossibleAndHide() {
        let t = vm.newTaskText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if !t.isEmpty {
            vm.addTask()
        }
        vm.newTaskText = ""
        withAnimation(.easeInOut(duration: 0.2)) {
            isAdding = false
        }
        inputFocused = false
    }

    // MARK: - Edit/Delete helpers

    private func saveEditedTask() {
        guard let task = taskBeingEdited else { return }
        vm.updateTaskTitle(taskID: task.id, newTitle: editedTitle)
        taskBeingEdited = nil
    }

    private func deletePendingTask() {
        guard let task = taskPendingDelete else { return }
        vm.deleteTask(taskID: task.id)
        taskPendingDelete = nil
    }
}

#Preview {
    GoalTasksView()
}
