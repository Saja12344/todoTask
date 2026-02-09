//
//  NotificationType.swift
//  todoTask
//
//  Created by saja khalid on 20/08/1447 AH.
//


import Foundation
enum NotificationType: String, Codable {
    case friendRequestSent
    case friendRequestAccepted
    case challengeCreated
    case challengeAccepted
    case challengeRejected
    case planetStolen
    case challengeWon
}

struct NotificationEvent: Codable {
    var recordID: String? // CKRecord.ID.recordName
    var userID: String    // User.recordID
    var type: NotificationType
    var createdAt: Date
}
