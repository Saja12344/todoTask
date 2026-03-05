//
//  GoalTasksView.swift
//  todoTask
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
                .fill(LinearGradient(colors: [.darkBlu, .dark], startPoint: .bottom, endPoint: .top))
                .ignoresSafeArea()
            Image("Background 4")
                .resizable()
                .ignoresSafeArea()
                .opacity(0.7)
            
            Image("Gliter")
                .resizable()
                .ignoresSafeArea()


            VStack(spacing: 16) {

                // ── Planet + Progress Ring ─────────────────────────
                ZStack {
                    if let goal {
                        PlanetOrbView(
                            size: 150,
                            gradientColors: goal.design.gradientStops.map { $0.swiftUIColor },
                            glow: min(goal.design.glow, 0.15),
                            textureAssetName: goal.design.textureAssetName,
                            textureOpacity: goal.design.textureOpacity
                        )
                        .frame(width: 200, height: 200)
                    }

                    // اذا تحدي: خطين، اذا عادي: خط واحد
                    if let goal, goal.isChallenge, let info = goal.challengeInfo {
                        DualProgressRing(
                            myProgress: goal.progress,
                            friendProgress: info.friendProgress,
                            friendName: info.opponentName
                        )
                        .frame(width: 310, height: 310)
                    } else {
                        ProgressCircle(progress: goal?.progress ?? 0)
                            .frame(width: 200, height: 200)
                            .animation(.easeInOut(duration: 0.4), value: goal?.progress)
                    }
                }
                .padding(.top, 10)

                // ── Winner Banner ──────────────────────────────────
                if let goal, goal.isChallenge, let winnerID = goal.challengeInfo?.winnerID {
                    WinnerBanner(
                        winnerID: winnerID,
                        winnerName: winnerID == goal.challengeInfo?.opponentID
                            ? (goal.challengeInfo?.opponentName ?? "Friend")
                            : "You",
                        isYou: winnerID != goal.challengeInfo?.opponentID
                    )
                    .padding(.horizontal)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                // ── Tasks Panel ───────────────────────────────────
                ZStack(alignment: .bottomTrailing) {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.clear)
                        .glassEffect(.clear, in: .rect(cornerRadius: 20))
                        .frame(height: 370)

                    VStack(alignment: .leading, spacing: 10) {

                        // Title + Challenge badge
                        HStack {
                            Text(goal?.title ?? "")
                                .font(.title2).bold().foregroundColor(.white)
                            if goal?.isChallenge == true {
                                Text("⚡️ Challenge")
                                    .font(.caption.bold())
                                    .foregroundColor(.yellow)
                                    .padding(.horizontal, 8).padding(.vertical, 4)
                                    .background(Capsule().fill(Color.yellow.opacity(0.15)))
                            }
                        }
                        .padding(.top, 55)

                        // Opponent info
                        if let info = goal?.challengeInfo {
                            HStack(spacing: 6) {
                                Image(systemName: "person.fill")
                                    .font(.caption).foregroundColor(.gray)
                                Text("vs \(info.opponentName)")
                                    .font(.caption).foregroundColor(.gray)
                                Spacer()
                                // Friend progress
                                Text("\(info.opponentName): \(Int(info.friendProgress * 100))%")
                                    .font(.caption.bold()).foregroundColor(.orange)
                            }
                        }

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
                                            checkWinner()
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
                            .glassEffect(.clear.tint(.accent.opacity(0.6)))
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
                store.addTask(goalID: goalID, title: title, scheduledDate: Date())
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

    // MARK: - Check Winner
    private func checkWinner() {
        guard var goal = store.goal(with: goalID),
              goal.isChallenge,
              goal.challengeInfo?.winnerID == nil else { return }

        // اذا وصلت 100% أنت الفائز
        if goal.progress >= 1.0 {
            goal.challengeInfo?.winnerID = "me"
            goal.challengeInfo?.isWinner = true
            store.updateGoal(goal)
        }
    }
}

// MARK: - Dual Progress Ring
struct DualProgressRing: View {
    var myProgress:     Double
    var friendProgress: Double
    var friendName:     String

    var body: some View {
        ZStack {
            // الخلفية
            Circle().stroke(.white.opacity(0.08), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .frame(width: 310, height: 310)
            Circle().stroke(.white.opacity(0.08), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .frame(width: 280, height: 280)

            // Progress الصديق - الخط الخارجي (برتقالي)
            Circle()
                .trim(from: 0, to: max(0, min(friendProgress, 1)))
                .stroke(Color.orange, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .frame(width: 310, height: 310)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.4), value: friendProgress)

            // Progress أنا - الخط الداخلي (سيان)
            Circle()
                .trim(from: 0, to: max(0, min(myProgress, 1)))
                .stroke(Color.cyan, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .frame(width: 280, height: 280)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.4), value: myProgress)
        }
        .overlay(alignment: .bottom) {
            // Legend
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Circle().fill(Color.cyan).frame(width: 8, height: 8)
                    Text("You").font(.caption2).foregroundColor(.white.opacity(0.8))
                }
                HStack(spacing: 4) {
                    Circle().fill(Color.orange).frame(width: 8, height: 8)
                    Text(friendName).font(.caption2).foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(6)
            .background(Capsule().fill(.black.opacity(0.4)))
            .offset(y: 20)
        }
    }
}

// MARK: - Winner Banner
struct WinnerBanner: View {
    let winnerID:   String
    let winnerName: String
    let isYou:      Bool

    var body: some View {
        HStack(spacing: 12) {
            Text(isYou ? "🏆" : "😔").font(.title2)
            VStack(alignment: .leading, spacing: 2) {
                Text(isYou ? "You Won the Challenge!" : "\(winnerName) Won!")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                Text(isYou ? "The planet is now yours 🪐" : "Better luck next time!")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isYou ? Color.yellow.opacity(0.2) : Color.gray.opacity(0.2))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(isYou ? Color.yellow.opacity(0.4) : Color.gray.opacity(0.3), lineWidth: 1))
        )
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
//            Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
//                .foregroundColor(task.isDone ? .blue : .gray)
//                .font(.system(size: 26))
//                .onTapGesture { onToggle() }
//                .animation(.easeInOut(duration: 0.2), value: task.isDone)
        }
        .padding(.vertical, 4)
    }
}
