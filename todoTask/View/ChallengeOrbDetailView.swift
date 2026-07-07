//
//  ChallengeOrbDetailView.swift
//  todoTask
//

import SwiftUI
import UserNotifications

struct ChallengeOrbDetailView: View {
    @EnvironmentObject private var store: OrbGoalStore
    @EnvironmentObject private var userVM: UserViewModel
    @EnvironmentObject private var lang: LanguageManager
    @EnvironmentObject private var challengeOrbs: ChallengeOrbsManager
    @Environment(\.dismiss) private var dismiss

    let goal: OrbGoal
    var onClose: (() -> Void)? = nil

    @State private var showWin = false
    @State private var lastOpponentProgress: Double = -1

    private func close() {
        if let onClose { onClose() } else { dismiss() }
    }

    private func fireOpponentBanterNotification(name: String) {
        let ar = lang.language == .arabic
        let lines = ar
            ? ["\(name) خلّصت مهمة! لا تتأخرين وراها!",
               "\(name) بدأت تسبقك… تحركي!",
               "\(name) قطعت شوط جديد، دورك الحين!"]
            : ["\(name) just finished a task! Don't fall behind!",
               "\(name) is pulling ahead… move it!",
               "\(name) made progress — your turn now!"]

        let content = UNMutableNotificationContent()
        content.title = ar ? "تحدّي الأصدقاء" : "Friend Challenge"
        content.body = lines.randomElement() ?? ""
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )
        UNUserNotificationCenter.current().add(request)
    }

    private var accent: Color { Color("accent") }
    private var roomId: String? { goal.challengeInfo?.challengeID }
    private var myId: String { userVM.currentUser?.id ?? "" }
    private var live: ChallengeLiveState? { challengeOrbs.liveState(for: goal) }
    private var service: ChallengeService? { roomId.flatMap { challengeOrbs.service(for: $0) } }
    private var isWaiting: Bool { live?.waitingForOpponent ?? true }

    var body: some View {
        ZStack {
            ClassicOrbitBackground(includeBackgroundImage: false)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    heroCard

                    if isWaiting, let roomId {
                        ChallengeCodeCard(
                            roomId: roomId,
                            fromUsername: userVM.currentUser?.username ?? ""
                        )
                    }

                    if let service, roomId != nil {
                        FunMissionsPanel(
                            tasks: service.tasks,
                            myId: myId,
                            lang: lang,
                            onComplete: { taskId in
                                Task {
                                    try? await service.completeTask(
                                        roomId: roomId!,
                                        taskId: taskId,
                                        userId: myId
                                    )
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 28)
            }
        }
        .orbitForcedDark()
        .onReceive(challengeOrbs.$liveStates) { states in
            guard let roomId, let live = states[roomId] else { return }

            if lastOpponentProgress >= 0,
               live.opponentProgress > lastOpponentProgress + 0.001,
               !live.isFinished {
                fireOpponentBanterNotification(name: live.opponentName)
            }
            lastOpponentProgress = live.opponentProgress

            guard live.isFinished, live.room.winnerId != nil else { return }
            showWin = true
        }
        .fullScreenCover(isPresented: $showWin) {
            if let winner = service?.winner {
                ChallengeOrbitView(
                    winner: winner,
                    isMyWin: winner.id == myId,
                    onDismiss: {
                        showWin = false
                        close()
                    }
                )
                .environmentObject(userVM)
                .environmentObject(lang)
            }
        }
    }

    @ViewBuilder
    private var heroCard: some View {
        VStack(spacing: 16) {
            Text(goal.title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            ChallengeOrbGalaxyView(goal: goal, live: live, size: 112)
                .frame(height: 140)

            if let live, !live.waitingForOpponent {
                GoalChallengeProgressBars(
                    myProgress: live.myProgress,
                    friendProgress: live.opponentProgress,
                    friendName: live.opponentName,
                    myLabel: lang.t(.raceYou)
                )
            } else if isWaiting {
                Text(lang.t(.challengeWaiting))
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .glassPanel()
    }
}

private extension View {
    func glassPanel(cornerRadius: CGFloat = 20) -> some View {
        self
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.clear)
                    .glassEffect(.clear.tint(Color.black.opacity(0.34)), in: .rect(cornerRadius: cornerRadius))
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(.white.opacity(0.12), lineWidth: 1)
            }
    }
}
