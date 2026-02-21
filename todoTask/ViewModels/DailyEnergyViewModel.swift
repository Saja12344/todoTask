//
//  DailyEnergyViewModel.swift
//  todoTask
//
//  Created by You on 14/02/2026.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Model persisted locally (and optionally synced)
struct DailyEnergyEntry: Codable, Identifiable, Equatable {
    // yyyy-MM-dd for the date key
    let dateKey: String
    let title: String
    let value: String
    let icon: String
    
    var id: String { dateKey }
}

final class DailyEnergyViewModel: ObservableObject {
    // MARK: - Public published state
    @Published private(set) var todayEntry: DailyEnergyEntry?
    @Published private(set) var showPromptForToday: Bool = false
    
    // MARK: - Storage
    private let userDefaultsKey = "dailyEnergy.entries"
    private var entries: [String: DailyEnergyEntry] = [:] // keyed by dateKey
    
    // MARK: - Cloud (optional; commented out for later enablement)
    // private let container = CKContainer.default()
    // private lazy var publicDB = container.publicCloudDatabase
    // private let recordType = "DailyEnergy"
    // private let userID: String?
    // private let cloudSyncEnabled: Bool
    
    // MARK: - Init
    init(/* cloudSyncEnabled: Bool = false, userID: String? = nil */) {
        // self.cloudSyncEnabled = cloudSyncEnabled
        // self.userID = userID
        loadLocal()
        refreshToday()
        
        // If you want to auto-fetch from CloudKit on init later:
        // if cloudSyncEnabled, let userID { Task { await fetchFromCloud(for: userID) } }
    }
    
    // MARK: - Public API
    func refreshToday() {
        let key = Self.dateKey(for: Date())
        todayEntry = entries[key]
        showPromptForToday = (todayEntry == nil)
    }
    
    func hasEnergy(for date: Date) -> Bool {
        let key = Self.dateKey(for: date)
        return entries[key] != nil
    }
    
    func energy(for date: Date) -> DailyEnergyEntry? {
        let key = Self.dateKey(for: date)
        return entries[key]
    }
    
    func setEnergyForToday(_ energy: Energytoday) async {
        await setEnergy(energy, for: Date())
    }
    
    @MainActor
    func clearToday() {
        let key = Self.dateKey(for: Date())
        entries[key] = nil
        saveLocal()
        todayEntry = nil
        showPromptForToday = true
    }
    
    func setEnergy(_ energy: Energytoday, for date: Date) async {
        let key = Self.dateKey(for: date)
        let entry = DailyEnergyEntry(dateKey: key, title: energy.title, value: energy.value, icon: energy.icon)
        
        // Update local first
        await MainActor.run {
            entries[key] = entry
            saveLocal()
            if Self.isToday(date) {
                todayEntry = entry
                showPromptForToday = false
            }
        }
        
        // Then optionally sync to CloudKit later by uncommenting:
        /*
        guard cloudSyncEnabled, let userID = userID else { return }
        do {
            try await upsertToCloud(entry: entry, userID: userID)
        } catch {
            // Handle cloud error if you want
            print("Cloud upsert failed: \(error)")
        }
        */
    }
    
    // MARK: - Local persistence
    private func loadLocal() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else { return }
        do {
            let decoded = try JSONDecoder().decode([String: DailyEnergyEntry].self, from: data)
            entries = decoded
        } catch {
            print("Failed to decode daily energy entries: \(error)")
        }
    }
    
    private func saveLocal() {
        do {
            let data = try JSONEncoder().encode(entries)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            print("Failed to encode daily energy entries: \(error)")
        }
    }
    
    // MARK: - Date helpers
    static func dateKey(for date: Date) -> String {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0) // stable daily key independent of device TZ
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
    
    static func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
    
    // MARK: - CloudKit (optional) — uncomment to enable
    /*
    private func upsertToCloud(entry: DailyEnergyEntry, userID: String) async throws {
        // Build a stable recordID combining userID + dateKey
        let recordID = CKRecord.ID(recordName: "dailyEnergy_\(userID)_\(entry.dateKey)")
        
        do {
            // Try fetch existing
            let record = try await publicDB.record(for: recordID)
            record["userID"] = userID as CKRecordValue
            record["dateKey"] = entry.dateKey as CKRecordValue
            record["title"] = entry.title as CKRecordValue
            record["value"] = entry.value as CKRecordValue
            record["icon"] = entry.icon as CKRecordValue
            _ = try await publicDB.save(record)
        } catch {
            // If not found, create new
            let record = CKRecord(recordType: recordType, recordID: recordID)
            record["userID"] = userID as CKRecordValue
            record["dateKey"] = entry.dateKey as CKRecordValue
            record["title"] = entry.title as CKRecordValue
            record["value"] = entry.value as CKRecordValue
            record["icon"] = entry.icon as CKRecordValue
            record["createdAt"] = Date() as CKRecordValue
            _ = try await publicDB.save(record)
        }
    }
    
    // Optional: fetch entire history from CloudKit for this user
    func fetchFromCloud(for userID: String) async {
        let predicate = NSPredicate(format: "userID == %@", userID)
        let query = CKQuery(recordType: recordType, predicate: predicate)
        do {
            let results = try await publicDB.records(matching: query)
            var merged: [String: DailyEnergyEntry] = entries
            for (_, result) in results.matchResults {
                if let record = try? result.get(),
                   let dateKey = record["dateKey"] as? String,
                   let title = record["title"] as? String,
                   let value = record["value"] as? String,
                   let icon = record["icon"] as? String {
                    merged[dateKey] = DailyEnergyEntry(dateKey: dateKey, title: title, value: value, icon: icon)
                }
            }
            await MainActor.run {
                entries = merged
                saveLocal()
                refreshToday()
            }
        } catch {
            print("Cloud fetch failed: \(error)")
        }
    }
    */
}
