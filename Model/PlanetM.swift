//
//  PlanetPeriod.swift
//  toDotask
//
//  Created by saja khalid on 16/08/1447 AH.
//


enum PlanetPeriod {
    case week
    case month
}

enum PlanetState {
    case active
    case stolen
    case damaged
}

struct Planet {
    let id: PlanetID
    var ownerID: UserID
    var period: PlanetPeriod
    var state: PlanetState
}
