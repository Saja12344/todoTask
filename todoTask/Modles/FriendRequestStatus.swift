//
//  FriendRequestStatus.swift
//  todoTask
//
//  Created by saja khalid on 20/08/1447 AH.
//




import Foundation

//state of the requste user 1 is sending
enum FriendRequestStatus: String, Codable,Equatable {
    case pending
    case accepted
    case rejected
}

struct FriendRequest: Codable {
    var recordID: String? // CKRecord.ID.recordName
    var from: String      // User.recordID
    var to: String        // User.recordID
    var status: FriendRequestStatus
}
