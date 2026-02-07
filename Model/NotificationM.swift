//
//  NotificationEvent.swift
//  toDotask
//
//  Created by saja khalid on 16/08/1447 AH.
//

import Foundation
struct NotificationEvent {
    let id: UUID
    let userID: UserID
    let type: String
    let createdAt: Date
}
