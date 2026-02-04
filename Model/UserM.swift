//
//  UserModel.swift
//  toDotask
//
//  Created by saja khalid on 16/08/1447 AH.
//

//UserID, username, authMode, friends, ownedPlanets
import Foundation   
typealias UserID = UUID
typealias PlanetID = UUID
typealias ChallengeID = UUID

enum AuthMode {
    case guest
    case registered
}

struct User {
    let id: UserID
    var username: String
    var authMode: AuthMode
    var friends: [UserID]
    var ownedPlanets: [PlanetID]
}
