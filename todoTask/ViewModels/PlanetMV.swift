//
//  PlanetViewModel.swift
//  todoTask
//
//  Created by saja khalid on 20/08/1447 AH.
//


//
//  PlanetViewModel.swift
//  toDotask
//
//  Created by saja khalid on 19/08/1447 AH.
//


import Foundation
// import CloudKit   // Commented: local-only mode
import Combine

class PlanetViewModel: ObservableObject {
    
    @Published var myPlanets: [Planet] = []
    
    // MARK: - CloudKit disabled for local-only mode
    // private let container = CKContainer.default()
    // private lazy var publicDB = container.publicCloudDatabase
    
    // MARK: - Fetch My Planets (Local-only stub)
    func fetchMyPlanets(for userID: String) async throws {
        // In local-only mode, either:
        // - Load from your local storage if available
        // - Or set to an empty array as a placeholder
        await MainActor.run {
            self.myPlanets = []
        }
    }

    // MARK: - Transfer Planet Ownership (disabled in local-only mode)
    func transferPlanet(
        _ planet: Planet,
        to newOwnerID: String,
        newTasks: [String]
    ) async throws {
        // No-op in local-only mode.
        // If you later add local persistence for planets, update it here.
        await MainActor.run {
            // Remove from local list if needed
            myPlanets.removeAll { $0.id == planet.id }
        }
    }
}

