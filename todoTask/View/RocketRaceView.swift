//
//  RocketRaceView.swift
//  todoTask
//
//  Created by شهد عبدالله القحطاني on 16/12/1447 AH.
//


//  RocketRaceView.swift
//  todoTask

import SwiftUI

struct RocketRaceView: View {
    @EnvironmentObject private var store: OrbGoalStore
    @EnvironmentObject private var userVM: UserViewModel
    @StateObject private var service = ChallengeService()

    let roomId: String
    @Environment(\.dismiss) private var dismiss

    private var myId: String { userVM.currentUser?.id ?? "" }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // خلفية فضاء
                Color.black.ignoresSafeArea()
                StarsBackgroundView()

                // الكوكب في الأعلى
                if let room = service.room {
                    ChallengeOrbView(room: room)
                        .frame(width: 130, height: 130)
                        .position(x: geo.size.width / 2, y: 110)
                }

                // مسارات الصواريخ
                if service.room?.status == .active || service.room?.status == .finished {
                    TrailPath(
                        x: geo.size.width * 0.28,
                        progress: service.myProgress(myId: myId),
                        height: geo.size.height,
                        color: .purple
                    )
                    TrailPath(
                        x: geo.size.width * 0.72,
                        progress: service.opponentProgress(myId: myId),
                        height: geo.size.height,
                        color: .teal
                    )

                    // صاروخ اللاعب (أنا)
                    RocketSprite(color: .purple, label: "أنت",
                                 progress: service.myProgress(myId: myId))
                        .position(
                            x: geo.size.width * 0.28,
                            y: rocketY(service.myProgress(myId: myId), geo.size.height)
                        )
                        .animation(.easeOut(duration: 0.35), value: service.myProgress(myId: myId))

                    // صاروخ المنافس
                    RocketSprite(color: .teal, label: "منافس",
                                 progress: service.opponentProgress(myId: myId))
                        .position(
                            x: geo.size.width * 0.72,
                            y: rocketY(service.opponentProgress(myId: myId), geo.size.height)
                        )
                        .animation(.easeOut(duration: 0.35), value: service.opponentProgress(myId: myId))
                }

                // انتظار اللاعب الثاني
                if service.room?.status == .waiting {
                    WaitingRoomView(roomId: roomId)
                }

                // قائمة المهام في الأسفل
                if service.room?.status == .active {
                    VStack {
                        Spacer()
                        TasksBottomSheet(
                            tasks: service.tasks,
                            myId: myId,
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
                    }
                }
            }
        }
        .onAppear {
            service.listen(roomId: roomId, myId: myId)
        }
        .onDisappear {
            service.stopListening()
        }
        // لما يفوز أحد
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
        }
    }

    private func rocketY(_ progress: Double, _ height: CGFloat) -> CGFloat {
        let start = height * 0.84
        let end   = height * 0.18
        return start - (start - end) * progress
    }
}

// ─── مكونات مساعدة ───────────────────────────────────────

struct WaitingRoomView: View {
    let roomId: String
    @State private var copied = false

    var body: some View {
        VStack(spacing: 20) {
            ProgressView().tint(.white).scaleEffect(1.4)
            Text("في انتظار صديقك...").font(.headline).foregroundColor(.white)
            Text("أرسل له هذا الرمز:")
                .font(.caption).foregroundColor(.white.opacity(0.55))
            Text(roomId)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(.accent)
                .padding(.horizontal, 20).padding(.vertical, 10)
                .glassEffect(.clear, in: .rect(cornerRadius: 12))
                .onTapGesture {
                    UIPasteboard.general.string = roomId
                    copied = true
                }
            if copied {
                Text("تم النسخ!").font(.caption).foregroundColor(.green)
            }
        }
        .padding(32)
        .glassEffect(.clear.tint(.darkBlu.opacity(0.5)), in: .rect(cornerRadius: 24))
        .padding(.horizontal, 40)
    }
}

struct TasksBottomSheet: View {
    let tasks: [ChallengeTask]
    let myId: String
    let onComplete: (String) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Capsule().fill(Color.white.opacity(0.25))
                .frame(width: 40, height: 4).padding(.vertical, 10)

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(tasks) { task in
                        ChallengeTaskRow(task: task, myId: myId) {
                            onComplete(task.id)
                        }
                    }
                }
                .padding(.horizontal, 16).padding(.bottom, 20)
            }
            .frame(maxHeight: 260)
        }
        .glassEffect(.clear.tint(.darkBlu.opacity(0.6)), in: .rect(cornerRadius: 24))
        .padding(.horizontal, 12)
        .padding(.bottom, 20)
    }
}

struct ChallengeTaskRow: View {
    let task: ChallengeTask
    let myId: String
    let onTap: () -> Void

    private var isDoneByMe:     Bool { task.completedBy == myId }
    private var isDoneByOther:  Bool { task.completedBy != nil && task.completedBy != myId }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(task.completedBy != nil ? .white.opacity(0.4) : .white)
                    .strikethrough(task.completedBy != nil)
                Text("\(task.points) نقطة")
                    .font(.caption2).foregroundColor(.white.opacity(0.35))
            }
            Spacer()
            if isDoneByMe {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.accent).font(.system(size: 26))
            } else if isDoneByOther {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red.opacity(0.6)).font(.system(size: 26))
            } else {
                Image(systemName: "circle")
                    .foregroundColor(.gray).font(.system(size: 26))
                    .onTapGesture { onComplete() }
            }
        }
        .padding(.horizontal, 18).padding(.vertical, 12)
        .glassEffect(.clear, in: .rect(cornerRadius: 16))
    }

    private func onComplete() { onTap() }
}

struct ChallengeOrbView: View {
    let room: ChallengeRoom

    var colors: [Color] {
        room.planetGradient.map { Color(hex: $0) ?? .purple }
    }

    var body: some View {
        PlanetOrbView(
            size: 110,
            gradientColors: colors,
            glow: room.planetGlow,
            textureAssetName: room.planetTextureAsset,
            textureOpacity: room.planetTextureOpacity
        )
    }
}