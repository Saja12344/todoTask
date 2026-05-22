//
//  GoalTasksView.swift
//  todoTask
//

import SwiftUI

struct GoalTasksView: View {
    @EnvironmentObject private var store: OrbGoalStore
    @EnvironmentObject private var lang: LanguageManager
    @State private var showAddSheet      = false
    @State private var showDeleteConfirm = false
    @State private var taskPendingDelete: GoalTask?
    @State private var showAllTasks = false

    let goalID: UUID

    private let tasksPreviewLimit = 10

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

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    planetSection

                    if let goal, goal.isChallenge, let winnerID = goal.challengeInfo?.winnerID {
                        WinnerBanner(
                            winnerID: winnerID,
                            winnerName: winnerID == goal.challengeInfo?.opponentID
                                ? (goal.challengeInfo?.opponentName ?? "Friend")
                                : "You",
                            isYou: winnerID != goal.challengeInfo?.opponentID
                        )
                    }

                    progressTasksCard
                }
                .padding(.horizontal, GoalFlowLayout.horizontalPadding)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle(goal?.title ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .orbitForcedDark()
        .sheet(isPresented: $showAddSheet) {
            AddTaskSheet(
                goalTitle: goal?.title ?? "",
                defaultUnit: goal?.settings?.unit ?? ""
            ) { title, quantity in
                store.addTask(
                    goalID: goalID,
                    title: title,
                    scheduledDate: Date(),
                    targetAmount: max(1, quantity)
                )
            }
        }
        .confirmationDialog(lang.t(.deleteTaskQuestion), isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button(lang.t(.deleteTask), role: .destructive) {
                if let task = taskPendingDelete { store.deleteTask(goalID: goalID, taskID: task.id) }
                taskPendingDelete = nil
            }
            Button(lang.t(.cancel), role: .cancel) { taskPendingDelete = nil }
        }
    }

    // MARK: - Planet

    @ViewBuilder
    private var planetSection: some View {
        if let goal {
            PlanetOrbView(
                size: 140,
                gradientColors: goal.design.gradientStops.map { $0.swiftUIColor },
                glow: min(goal.design.glow, 0.15),
                textureAssetName: goal.design.textureAssetName,
                textureOpacity: goal.design.textureOpacity
            )
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Progress + tasks card

    private var progressTasksCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            cardHeader
            progressSection
            tasksList
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .top)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.clear)
                .glassEffect(.clear, in: .rect(cornerRadius: 20))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.14), lineWidth: 1)
        }
    }

    private var cardHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top, spacing: 10) {
                Text(goal?.title ?? "")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .lineLimit(2)
                Spacer(minLength: 4)
                if goal?.isChallenge == true {
                    Text("⚡️ \(lang.t(.challenge))")
                        .font(.caption.bold())
                        .foregroundColor(.yellow)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.yellow.opacity(0.15)))
                }
                GoalFlowAddButton(size: 44) { showAddSheet = true }
            }

            if let info = goal?.challengeInfo {
                HStack(spacing: 6) {
                    Image(systemName: "person.fill")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("vs \(info.opponentName)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
    }

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(progressSummary(for: goal))
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.75))
                if let goal, let settings = goal.settings, settings.goalType == .reachTarget, !settings.isMilestoneMode {
                    Text(goalTotalSubtitle(settings: settings))
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.4))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if let goal, goal.isChallenge, let info = goal.challengeInfo {
                GoalChallengeProgressBars(
                    myProgress: goal.progress,
                    friendProgress: info.friendProgress,
                    friendName: info.opponentName
                )
            } else {
                GoalProgressBar(progress: goal?.progress ?? 0)
            }
        }
        .padding(.bottom, 4)
    }

    private var sortedTasks: [GoalTask] {
        goal?.tasks.sorted { $0.scheduledDate < $1.scheduledDate } ?? []
    }

    private var visibleTasks: [GoalTask] {
        let all = sortedTasks
        if showAllTasks || all.count <= tasksPreviewLimit { return all }
        return Array(all.prefix(tasksPreviewLimit))
    }

    private var tasksList: some View {
        VStack(spacing: 10) {
            if !sortedTasks.isEmpty {
                ForEach(visibleTasks) { task in
                    TaskTrackRow(task: task, goal: goal, lang: lang)
                        .contextMenu {
                            Button(role: .destructive) {
                                taskPendingDelete = task
                                showDeleteConfirm = true
                            } label: { Label(lang.t(.deleteTask), systemImage: "trash") }
                        }
                }

                if sortedTasks.count > tasksPreviewLimit {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { showAllTasks.toggle() }
                    } label: {
                        Text(showAllTasks ? lang.t(.showLess) : lang.t(.readMore))
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.cyan)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "tray")
                        .font(.system(size: 32))
                        .foregroundColor(.white.opacity(0.3))
                    Text(lang.t(.noTasksYet))
                        .foregroundColor(.white.opacity(0.4))
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 24)
            }
        }
    }

    private func goalTotalSubtitle(settings: GoalSettings) -> String {
        let u = settings.unit.isEmpty ? "" : " \(settings.unit)"
        switch lang.language {
        case .english:
            return "Goal: \(settings.targetNumber)\(u) total"
        case .arabic:
            return "الهدف: \(settings.targetNumber)\(u) إجمالي"
        }
    }

    private func progressSummary(for goal: OrbGoal?) -> String {
        guard let goal else { return "0 / 0 tasks" }
        if let settings = goal.settings, settings.goalType == .reachTarget, !settings.isMilestoneMode {
            let unit = settings.unit.isEmpty ? "" : " \(settings.unit)"
            return "\(goal.completedUnits) / \(goal.targetUnits)\(unit)"
        }
        return lang.tasksProgressSummary(done: goal.doneTasks, total: goal.totalTasks)
    }

    private func checkWinner() {
        guard var goal = store.goal(with: goalID),
              goal.isChallenge,
              goal.challengeInfo?.winnerID == nil else { return }

        if goal.progress >= 1.0 {
            goal.challengeInfo?.winnerID = "me"
            goal.challengeInfo?.isWinner = true
            store.updateGoal(goal)
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

// MARK: - TaskTrackRow (read-only; check off tasks on Today / calendar only)
struct TaskTrackRow: View {
    let task: GoalTask
    let goal: OrbGoal?
    let lang: LanguageManager

    private var statusTitle: String {
        if let goal, let partial = GoalTaskDisplay.partialProgressLine(for: task, in: goal), task.completedAmount > 0 {
            return partial
        }
        return goal.map { GoalTaskDisplay.label(for: task, in: $0, lang: lang) } ?? task.title
    }

    private var trailingStatus: String? {
        if task.targetAmount > 1 {
            return "\(task.completedAmount)/\(task.targetAmount)"
        }
        if task.isDone || task.isFullyComplete {
            return lang.language == .arabic ? "تم" : "Done"
        }
        return nil
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Text("•").font(.title3).foregroundStyle(.white.opacity(0.9))
            Text(statusTitle)
                .foregroundStyle(.white)
                .opacity(task.isFullyComplete ? 0.45 : 0.92)
                .strikethrough(task.isFullyComplete, color: .white.opacity(0.35))
            Spacer()
            if let trailingStatus {
                Text(trailingStatus)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(task.isFullyComplete ? .cyan.opacity(0.7) : .white.opacity(0.45))
            }
        }
        .padding(.vertical, 6)
    }
}

// MARK: - TaskAmountStepper
struct TaskAmountStepper: View {
    let completed: Int
    let target:    Int
    let onMinus:   () -> Void
    let onPlus:    () -> Void

    var body: some View {
        HStack(spacing: 8) {
            stepButton(systemName: "minus", enabled: completed > 0, action: onMinus)
            Text("\(completed)/\(target)")
                .font(.caption.monospacedDigit().weight(.semibold))
                .foregroundColor(.white.opacity(0.9))
                .frame(minWidth: 36)
            stepButton(systemName: "plus", enabled: completed < target, action: onPlus)
        }
    }

    private func stepButton(systemName: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(enabled ? .white : .white.opacity(0.25))
                .frame(width: 28, height: 28)
                .background(Circle().fill(.white.opacity(enabled ? 0.12 : 0.05)))
        }
        .disabled(!enabled)
        .buttonStyle(.plain)
    }
}
