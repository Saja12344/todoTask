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
import CloudKit
import Combine

class PlanetViewModel: ObservableObject {
    
    @Published var myPlanets: [Planet] = []
    
    private let container = CKContainer.default()
    private lazy var publicDB = container.publicCloudDatabase
    
    // MARK: - Fetch My Planets
    
    func fetchMyPlanets(for userID: String) async throws {
        let predicate = NSPredicate(format: "ownerID == %@", userID)
        let query = CKQuery(recordType: "Planet", predicate: predicate)
        
        let results = try await publicDB.records(matching: query)
        
        let planets: [Planet] = results.matchResults.compactMap { _, result in
            guard let record = try? result.get() else { return nil }
            
            return Planet(
                recordID: record.recordID.recordName,
                ownerID: record["ownerID"] as? String ?? "",
                state: PlanetState(rawValue: record["state"] as? String ?? "") ?? .active,
                goalID: record["goalID"] as? String ?? "",
                progressPercentage: record["progressPercentage"] as? Double ?? 0,
                design: nil
            )

        }
        
        await MainActor.run {
            self.myPlanets = planets
        }
    }

    // MARK: - Transfer Planet Ownership
    
    func transferPlanet(
        _ planet: Planet,
        to newOwnerID: String,
        newTasks: [String] // فقط التاسكات الجديدة الخاصة بالتحدي
    ) async throws {

        let recordID = CKRecord.ID(recordName: planet.recordID)
        let record = try await publicDB.record(for: recordID)
        
        // 1️⃣ تغيير المالك
        record["ownerID"] = newOwnerID as CKRecordValue
        
        // 2️⃣ تحديث الحالة
        record["state"] = PlanetState.stolen.rawValue as CKRecordValue
        
        // 3️⃣ تعيين التقدم إلى 100% (لأنه فاز بالتحدي)
        record["progressPercentage"] = 100 as CKRecordValue
          
        // 3️⃣ تحديث التاسكات الجديدة فقط
        record["tasks"] = newTasks as CKRecordValue
        
        // 4️⃣ حفظ التغييرات في CloudKit
        _ = try await publicDB.save(record)
        
        // 5️⃣ إزالة الكوكب من قائمة المستخدم القديم لأنه صار ملك شخص آخر
        await MainActor.run {
            myPlanets.removeAll { $0.id == planet.id }
        }
    }

}
