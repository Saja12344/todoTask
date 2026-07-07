//
//  RocketRaceView.swift
//  todoTask
//

import SwiftUI

struct RocketRaceView: View {
    @EnvironmentObject private var store: OrbGoalStore
    @EnvironmentObject private var userVM: UserViewModel
    @EnvironmentObject private var lang: LanguageManager
    @StateObject private var service = ChallengeService()

    let roomId: String
    @Environment(\.dismiss) private var dismiss

    private var myId: String { userVM.currentUser?.id ?? "" }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.01, green: 0.02, blue: 0.08), .darkBlu, .black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            StarsBackgroundView()

            if service.room?.status == .waiting {
                FunWaitingRoomView(roomId: roomId, room: service.room)
            } else if service.room?.status == .active || service.room?.status == .finished {
                activeRaceContent
            }
        }
        .orbitForcedDark()
        .onAppear { service.listen(roomId: roomId, myId: myId) }
        .onDisappear { service.stopListening() }
        .fullScreenCover(item: $service.winner) { winner in
            ChallengeOrbitView(
                winner: winner,
                isMyWin: winner.id == myId,
                onDismiss: {
                    service.winner = nil
                    dismiss()
                }
            )
            .environmentObject(userVM)
            .environmentObject(lang)
        }
    }

    private var activeRaceContent: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                FunRaceBanner(
                    myProgress: service.myProgress(myId: myId),
                    opponentProgress: service.opponentProgress(myId: myId),
                    myLabel: lang.t(.raceYou),
                    opponentLabel: lang.t(.raceOpponent)
                )
                .padding(.horizontal, 16)
                .padding(.top, 56)

                ZStack {
                    if let room = service.room {
                        ChallengeOrbitArena(
                            room: room,
                            myProgress: service.myProgress(myId: myId),
                            opponentProgress: service.opponentProgress(myId: myId),
                            myLabel: lang.t(.raceYou),
                            opponentLabel: lang.t(.raceOpponent),
                            prizeLabel: lang.t(.racePrizeLabel),
                            myId: myId,
                            winnerId: room.winnerId,
                            waitingForOpponent: false,
                            height: geo.size.height * 0.38
                        )
                    }
                }
                .frame(height: geo.size.height * 0.38)

                FunMissionsPanel(
                    tasks: service.tasks,
                    myId: myId,
                    lang: lang,
                    onComplete: { taskId in
                        Task {
                            try? await service.completeTask(
                                roomId: roomId,
                                taskId: taskId,
                                userId: myId
                            )
                        }
                    }
                )
                .padding(.horizontal, 14)
                .padding(.bottom, 16)
            }
        }
    }
}

// MARK: - Hype banner
private struct FunRaceBanner: View {
    @EnvironmentObject private var lang: LanguageManager
    let myProgress: Double
    let opponentProgress: Double
    let myLabel: String
    let opponentLabel: String

    var body: some View {
        VStack(spacing: 12) {
            Text(lang.raceHype(myProgress: myProgress, opponentProgress: opponentProgress))
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            HStack(spacing: 10) {
                scorePill(label: myLabel, percent: myProgress, color: .purple, emoji: "🚀")
                Text(lang.t(.raceVS))
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(.yellow)
                scorePill(label: opponentLabel, percent: opponentProgress, color: Color("accent"), emoji: "🔥")
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(0.06))
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(.white.opacity(0.10), lineWidth: 1)
                }
        }
    }

    private func scorePill(label: String, percent: Double, color: Color, emoji: String) -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Text(emoji).font(.caption)
                Text(label)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.85))
            }
            Text("\(Int(percent * 100))%")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Capsule()
                .fill(color.opacity(0.35))
                .frame(height: 4)
                .overlay(alignment: .leading) {
                    GeometryReader { bar in
                        Capsule()
                            .fill(color)
                            .frame(width: bar.size.width * percent)
                    }
                }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Shared orbit arena (planet + 2 rockets)
struct ChallengeOrbitArena: View {
    let room: ChallengeRoom
    let myProgress: Double
    let opponentProgress: Double
    let myLabel: String
    let opponentLabel: String
    let prizeLabel: String
    var myId: String = ""
    var winnerId: String? = nil
    var waitingForOpponent: Bool = false
    let height: CGFloat

    private var orbitRadius: CGFloat { min(height * 0.34, 118) }
    private var planetSize: CGFloat { 74 }

    var body: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: height * 0.54)

            ZStack {
                Text(prizeLabel)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.55))
                    .position(x: center.x, y: center.y - orbitRadius - 38)

                Circle()
                    .stroke(.white.opacity(0.10), style: StrokeStyle(lineWidth: 1.5, dash: [6, 8]))
                    .frame(width: orbitRadius * 2, height: orbitRadius * 2)
                    .position(center)

                OrbitProgressArc(progress: myProgress, radius: orbitRadius, color: .purple)
                    .position(center)
                OrbitProgressArc(progress: opponentProgress, radius: orbitRadius, color: Color("accent"))
                    .position(center)
                    .opacity(waitingForOpponent ? 0.35 : 1)

                ZStack {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.yellow.opacity(0.45), .orange.opacity(0.18)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                        .frame(width: planetSize + 16, height: planetSize + 16)

                    PlanetOrbView(
                        size: planetSize,
                        gradientColors: room.planetGradient.map { Color(hex: $0) ?? .purple },
                        glow: max(room.planetGlow, 0.12),
                        textureAssetName: room.planetTextureAsset.isEmpty ? nil : room.planetTextureAsset,
                        textureOpacity: room.planetTextureOpacity,
                        autoSpin: true
                    )
                    .shadow(color: (Color(hex: room.planetGradient.first ?? "") ?? .purple).opacity(0.45), radius: 16, y: 6)
                }
                .position(center)

                ChallengeOrbitRocket(
                    color: .purple,
                    label: myLabel,
                    progress: myProgress,
                    radius: orbitRadius,
                    startOffset: -90,
                    isWinner: winnerId == myId
                )
                .position(center)
                .animation(.spring(response: 0.5, dampingFraction: 0.78), value: myProgress)

                ChallengeOrbitRocket(
                    color: Color("accent"),
                    label: opponentLabel,
                    progress: waitingForOpponent ? 0 : opponentProgress,
                    radius: orbitRadius,
                    startOffset: 90,
                    dimmed: waitingForOpponent,
                    isWinner: winnerId != nil && winnerId != myId
                )
                .position(center)
                .animation(.spring(response: 0.5, dampingFraction: 0.78), value: opponentProgress)
            }
        }
        .frame(height: height)
    }
}

private struct ChallengeOrbitRocket: View {
    let color: Color
    let label: String
    let progress: Double
    let radius: CGFloat
    var startOffset: Double = -90
    var dimmed: Bool = false
    var isWinner: Bool = false

    private var angle: Double { progress * 360 + startOffset }

    var body: some View {
        ZStack {
            RocketSprite(color: color, label: label, progress: progress)
                .scaleEffect(0.62)
                .opacity(dimmed ? 0.45 : 1)
                .rotationEffect(.degrees(angle + 90))
                .offset(x: radius)
                .rotationEffect(.degrees(angle))

            if isWinner {
                Text("👑")
                    .font(.caption)
                    .offset(y: -28)
                    .rotationEffect(.degrees(-angle))
            }
        }
    }
}

private struct OrbitProgressArc: View {
    let progress: Double
    let radius: CGFloat
    let color: Color

    var body: some View {
        Circle()
            .trim(from: 0, to: max(0.001, progress))
            .stroke(
                color.opacity(0.55),
                style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: progress >= 1 ? [] : [8, 6])
            )
            .frame(width: radius * 2, height: radius * 2)
            .rotationEffect(.degrees(-90))
    }
}

// Legacy alias
private struct ChallengeRaceArena: View {
    let room: ChallengeRoom
    let myProgress: Double
    let opponentProgress: Double
    let myLabel: String
    let opponentLabel: String
    let prizeLabel: String
    let vsLabel: String
    let height: CGFloat

    var body: some View {
        ChallengeOrbitArena(
            room: room,
            myProgress: myProgress,
            opponentProgress: opponentProgress,
            myLabel: myLabel,
            opponentLabel: opponentLabel,
            prizeLabel: prizeLabel,
            height: height
        )
    }
}

private struct OrbitingRocketSprite: View {
    let color: Color
    let label: String
    let progress: Double
    let radius: CGFloat

    private var angle: Double { progress * 360 - 90 }

    var body: some View {
        RocketSprite(color: color, label: label, progress: progress)
            .scaleEffect(0.85)
            .rotationEffect(.degrees(angle + 90))
            .offset(x: radius)
            .rotationEffect(.degrees(angle))
    }
}

// MARK: - Missions panel
struct FunMissionsPanel: View {
    let tasks: [ChallengeTask]
    let myId: String
    let lang: LanguageManager
    let onComplete: (String) -> Void

    private var accent: Color { Color("accent") }
    private var myDone: Int { tasks.filter { $0.completedBy == myId }.count }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(lang.t(.raceMissionsTitle))
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                Spacer()
                Text(lang.challengeTasksProgress(done: myDone, total: tasks.count))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(accent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .glassEffect(.clear.tint(accent.opacity(0.2)), in: .capsule)
            }

            if tasks.isEmpty {
                Text(lang.t(.noTasksYet))
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.4))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            } else {
                VStack(spacing: 8) {
                    ForEach(tasks) { task in
                        FunChallengeMissionRow(
                            task: task,
                            myId: myId,
                            lang: lang,
                            onTap: { onComplete(task.id) }
                        )
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassPanel()
    }
}

struct FunChallengeMissionRow: View {
    let task: ChallengeTask
    let myId: String
    let lang: LanguageManager
    let onTap: () -> Void

    private var accent: Color { Color("accent") }
    private var isDoneByMe: Bool { task.completedBy == myId }
    private var isDoneByOther: Bool { task.completedBy != nil && task.completedBy != myId }
    private var isOpen: Bool { task.completedBy == nil }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white.opacity(isOpen ? 0.92 : 0.4))
                    .lineLimit(2)
                    .strikethrough(!isOpen, color: .white.opacity(0.3))

                Text(statusLabel)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.white.opacity(0.42))
            }

            Spacer(minLength: 8)

            if isOpen {
                Button(action: onTap) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(accent)
                        .frame(width: 44, height: 44)
                        .glassEffect(.clear.tint(accent.opacity(0.22)).interactive(), in: .circle)
                        .overlay {
                            Circle().stroke(accent.opacity(0.42), lineWidth: 1)
                        }
                }
                .buttonStyle(.plain)
            } else if isDoneByMe {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(accent)
                    .frame(width: 44, height: 44)
            } else {
                Image(systemName: "minus.circle")
                    .font(.system(size: 24))
                    .foregroundStyle(.white.opacity(0.28))
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .glassEffect(.clear.tint(Color.white.opacity(isOpen ? 0.06 : 0.03)), in: .rect(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(.white.opacity(isOpen ? 0.1 : 0.06), lineWidth: 1)
        }
        .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .onTapGesture {
            if isOpen { onTap() }
        }
    }

    private var statusLabel: String {
        if isDoneByMe { return lang.t(.raceDoneYou) }
        if isDoneByOther { return lang.t(.raceDoneFriend) }
        return lang.challengePoints(task.points)
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

// MARK: - Waiting room
private struct FunWaitingRoomView: View {
    @EnvironmentObject private var lang: LanguageManager
    let roomId: String
    let room: ChallengeRoom?

    var body: some View {
        VStack(spacing: 20) {
            if let room {
                ChallengeOrbitArena(
                    room: room,
                    myProgress: 0,
                    opponentProgress: 0,
                    myLabel: lang.t(.raceYou),
                    opponentLabel: lang.t(.raceOpponent),
                    prizeLabel: lang.t(.racePrizeLabel),
                    waitingForOpponent: true,
                    height: 260
                )
                .padding(.top, 40)
            }

            Text(lang.t(.challengeWaiting))
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text(lang.t(.challengeSendCode))
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.5))
                .multilineTextAlignment(.center)

            ChallengeCodeCard(roomId: roomId)
                .environmentObject(lang)
                .padding(.horizontal, 8)

            Text(lang.t(.friendsStep3))
                .font(.caption)
                .foregroundStyle(.white.opacity(0.4))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding(.horizontal, 24)
    }
}

struct ChallengeOrbView: View {
    let room: ChallengeRoom

    var colors: [Color] {
        room.planetGradient.map { Color(hex: $0) ?? .purple }
    }

    var body: some View {
        PlanetOrbView(
            size: 100,
            gradientColors: colors,
            glow: max(room.planetGlow, 0.14),
            textureAssetName: room.planetTextureAsset,
            textureOpacity: room.planetTextureOpacity
        )
        .shadow(color: (colors.first ?? .purple).opacity(0.5), radius: 20, y: 8)
    }
}

// Legacy aliases kept for ChallengeOrbitView
struct WaitingRoomView: View {
    @EnvironmentObject private var lang: LanguageManager
    let roomId: String

    var body: some View {
        FunWaitingRoomView(roomId: roomId, room: nil)
    }
}

struct TasksBottomSheet: View {
    let tasks: [ChallengeTask]
    let myId: String
    let lang: LanguageManager
    let onComplete: (String) -> Void

    var body: some View {
        FunMissionsPanel(tasks: tasks, myId: myId, lang: lang, onComplete: onComplete)
    }
}

struct ChallengeTaskRow: View {
    let task: ChallengeTask
    let myId: String
    let lang: LanguageManager
    let onTap: () -> Void

    var body: some View {
        FunChallengeMissionRow(task: task, myId: myId, lang: lang, onTap: onTap)
    }
}

struct RaceProgressHUD: View {
    let myProgress: Double
    let opponentProgress: Double
    let myLabel: String
    let opponentLabel: String

    var body: some View {
        FunRaceBanner(
            myProgress: myProgress,
            opponentProgress: opponentProgress,
            myLabel: myLabel,
            opponentLabel: opponentLabel
        )
    }
}
