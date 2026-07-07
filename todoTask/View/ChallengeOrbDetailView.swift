//
//  ChallengeOrbDetailView.swift
//  todoTask
//

import SwiftUI

struct ChallengeOrbDetailView: View {
    @EnvironmentObject private var store: OrbGoalStore
    @EnvironmentObject private var userVM: UserViewModel
    @EnvironmentObject private var lang: LanguageManager
    @EnvironmentObject private var challengeOrbs: ChallengeOrbsManager
    @Environment(\.dismiss) private var dismiss

    let goal: OrbGoal

    @State private var showWin = false

    private var accent: Color { Color("accent") }
    private var roomId: String? { goal.challengeInfo?.challengeID }
    private var myId: String { userVM.currentUser?.id ?? "" }
    private var live: ChallengeLiveState? { challengeOrbs.liveState(for: goal) }
    private var service: ChallengeService? { roomId.flatMap { challengeOrbs.service(for: $0) } }
    private var isWaiting: Bool { live?.waitingForOpponent ?? true }

    var body: some View {
        ZStack {
            ClassicOrbitBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    heroCard

                    if isWaiting, let roomId {
                        ChallengeCodeCard(
                            roomId: roomId,
                            subtitle: lang.t(.challengeShareActive)
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
                .padding(.top, GoalFlowLayout.topSafeArea + GoalFlowLayout.topBarHeight + 8)
                .padding(.bottom, 28)
            }
        }
        .overlay(alignment: .topLeading) {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: GoalFlowLayout.buttonSize, height: GoalFlowLayout.buttonSize)
                    .glassEffect(.clear.tint(Color.black.opacity(0.4)), in: .rect(cornerRadius: 24))
            }
            .buttonStyle(.plain)
            .padding(.leading, 16)
            .padding(.top, GoalFlowLayout.topSafeArea)
        }
        .orbitForcedDark()
        .onReceive(challengeOrbs.$liveStates) { states in
            guard let roomId,
                  let live = states[roomId],
                  live.isFinished,
                  live.room.winnerId != nil else { return }
            showWin = true
        }
        .fullScreenCover(isPresented: $showWin) {
            if let winner = service?.winner {
                ChallengeOrbitView(
                    winner: winner,
                    isMyWin: winner.id == myId,
                    onDismiss: {
                        showWin = false
                        dismiss()
                    }
                )
                .environmentObject(userVM)
                .environmentObject(lang)
            }
        }
    }

    @ViewBuilder
    private var heroCard: some View {
        VStack(spacing: 14) {
            Text(goal.title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            ChallengeOrbGalaxyView(goal: goal, live: live, size: 138)
                .frame(height: 168)

            if let live {
                Text(lang.raceHype(myProgress: live.myProgress, opponentProgress: live.opponentProgress))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(accent)
                    .multilineTextAlignment(.center)

                GoalChallengeProgressBars(
                    myProgress: live.myProgress,
                    friendProgress: live.opponentProgress,
                    friendName: live.opponentName,
                    myLabel: lang.t(.raceYou)
                )
            } else if isWaiting {
                Text(lang.t(.challengeWaiting))
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.45))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.clear)
                .glassEffect(.clear.tint(Color.black.opacity(0.32)), in: .rect(cornerRadius: 22))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(.white.opacity(0.14), lineWidth: 1)
        }
    }
}
