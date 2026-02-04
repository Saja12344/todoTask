//
//  ChallM.swift
//  toDotask
//
//  Created by saja khalid on 16/08/1447 AH.
//
import Foundation
enum ChallengeState {
    case draft
    case pendingAcceptance
    case active
    case locked
    case completed
    case rejected
}

struct Challenge {
    let id: ChallengeID
    let challengerID: UserID
    let opponentID: UserID
    var state: ChallengeState
    var planetStake: PlanetID?
    let createdAt: Date
    var editDeadline: Date
}
