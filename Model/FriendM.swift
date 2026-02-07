//
//  FriendRequestStatus.swift
//  toDotask
//
//  Created by saja khalid on 16/08/1447 AH.
//


enum FriendRequestStatus {
    case pending
    case accepted
    case rejected
}

struct FriendRequest {
    let id: UUID
    let from: UserID
    let to: UserID
    var status: FriendRequestStatus
}
