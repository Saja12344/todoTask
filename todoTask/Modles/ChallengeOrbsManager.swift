//
//  ChallengeOrbsManager.swift
//  todoTask
//

import Combine
import Foundation

struct ChallengeLiveState {
    var room: ChallengeRoom
    var tasks: [ChallengeTask]
    var myProgress: Double
    var opponentProgress: Double
    var goalId: UUID
    var myId: String

    var opponentName: String {
        if myId == room.player1Id {
            return room.player2Name ?? "Friend"
        }
        return room.player1Name
    }

    var waitingForOpponent: Bool {
        room.status == .waiting || room.player2Id == nil
    }

    var isFinished: Bool { room.status == .finished }

    var iWon: Bool { room.winnerId == myId }
}

struct ActiveChallengeRecord: Codable, Equatable {
    var roomId: String
    var goalId: UUID
    var myUserId: String
}

@MainActor
final class ChallengeOrbsManager: ObservableObject {
    static let shared = ChallengeOrbsManager()

    private let storageKey = "active_challenge_orbs_v1"

    @Published private(set) var liveStates: [String: ChallengeLiveState] = [:]

    private var services: [String: ChallengeService] = [:]
    private var bag: [String: AnyCancellable] = [:]
    private weak var store: OrbGoalStore?

    init() {
        let records = loadRecords()
        for record in records {
            track(roomId: record.roomId, goalId: record.goalId, myId: record.myUserId, store: nil)
        }
    }

    func attach(store: OrbGoalStore) {
        self.store = store
        for (roomId, state) in liveStates {
            pushProgressToStore(state)
        }
    }

    func liveState(for goal: OrbGoal) -> ChallengeLiveState? {
        guard let roomId = goal.challengeInfo?.challengeID else { return nil }
        return liveStates[roomId]
    }

    func track(roomId: String, goalId: UUID, myId: String, store: OrbGoalStore?) {
        if let store { self.store = store }
        persistRecord(ActiveChallengeRecord(roomId: roomId, goalId: goalId, myUserId: myId))

        if services[roomId] != nil { return }

        let service = ChallengeService()
        services[roomId] = service
        service.listen(roomId: roomId, myId: myId)

        let roomPub = service.$room.compactMap { $0 }
        let tasksPub = service.$tasks

        let cancellable = Publishers.CombineLatest(roomPub, tasksPub)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] room, tasks in
                guard let self else { return }
                let state = ChallengeLiveState(
                    room: room,
                    tasks: tasks,
                    myProgress: service.myProgress(myId: myId),
                    opponentProgress: service.opponentProgress(myId: myId),
                    goalId: goalId,
                    myId: myId
                )
                self.liveStates[roomId] = state
                self.pushProgressToStore(state)
            }

        bag[roomId]?.cancel()
        bag[roomId] = cancellable
    }

    func service(for roomId: String) -> ChallengeService? {
        services[roomId]
    }

    /// Open friend-challenge missions shown on Today's Tasks (today only).
    func todayItems(goals: [OrbGoal], date: Date, myId: String = "") -> [TodayItem] {
        let cal = Calendar.current
        guard cal.isDateInToday(date) else { return [] }

        var result: [TodayItem] = []
        let dayStart = cal.startOfDay(for: date)

        for goal in goals where goal.isChallenge {
            guard let roomId = goal.challengeInfo?.challengeID,
                  let state = liveStates[roomId],
                  state.room.status == .active,
                  !state.isFinished else { continue }

            for ct in state.tasks where ct.completedBy == nil {
                let taskUUID = UUID(uuidString: ct.id) ?? UUID()
                let task = GoalTask(
                    id: taskUUID,
                    goalID: goal.id,
                    title: ct.title,
                    scheduledDate: dayStart,
                    targetAmount: 1,
                    completedAmount: 0
                )
                result.append(TodayItem(goal: goal, task: task, challengeTaskId: ct.id))
            }
        }
        return result
    }

    func untrack(roomId: String) {
        services[roomId]?.stopListening()
        services[roomId] = nil
        bag[roomId]?.cancel()
        bag[roomId] = nil
        liveStates[roomId] = nil
        removeRecord(roomId: roomId)
    }

    private func pushProgressToStore(_ state: ChallengeLiveState) {
        guard var goal = store?.goal(with: state.goalId),
              var info = goal.challengeInfo else { return }

        info.friendProgress = state.opponentProgress
        info.opponentName = state.opponentName
        info.opponentID = state.myId == state.room.player1Id
            ? (state.room.player2Id ?? info.opponentID)
            : state.room.player1Id
        info.winnerID = state.room.winnerId
        info.isWinner = state.room.winnerId == state.myId
        goal.challengeInfo = info
        store?.updateGoal(goal)
    }

    // MARK: - Persistence

    private func loadRecords() -> [ActiveChallengeRecord] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([ActiveChallengeRecord].self, from: data) else {
            return []
        }
        return decoded
    }

    private func persistRecord(_ record: ActiveChallengeRecord) {
        var records = loadRecords().filter { $0.roomId != record.roomId }
        records.append(record)
        guard let data = try? JSONEncoder().encode(records) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func removeRecord(roomId: String) {
        let records = loadRecords().filter { $0.roomId != roomId }
        guard let data = try? JSONEncoder().encode(records) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
