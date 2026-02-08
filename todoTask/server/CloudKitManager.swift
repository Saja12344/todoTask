//
//  CloudKitManager.swift
//  todoTask
//
//  Created by saja khalid on 20/08/1447 AH.
//


//
//  CloudKit.swift
//  toDotask
//
//  Created by saja khalid on 17/08/1447 AH.
//

import CloudKit
import Foundation
let container = CKContainer.default()



class CloudKitManager {
    // الكونتينر الافتراضي (مرتبط بالـ Bundle ID)
    private let container = CKContainer.default()
    
    // قاعدة البيانات العامة (لأننا بنسوي نظام اجتماعي)
    private lazy var publicDB = container.publicCloudDatabase
    
    
    func createUser(username: String) async throws {
        
        // إنشاء Record نوعه "User"
        let record = CKRecord(recordType: "User")
        
        // إضافة الحقول
        record["username"] = username as CKRecordValue
        record["createdAt"] = Date() as CKRecordValue
        
        // حفظ في قاعدة البيانات العامة
        try await publicDB.save(record)
    }
    
    
    func fetchUsers() async throws -> [CKRecord] {
        
        // نجيب كل السجلات من نوع User
        let query = CKQuery(recordType: "User", predicate: NSPredicate(value: true))
        
        let result = try await publicDB.records(matching: query)
        
        // نحول النتائج إلى Array
        let records = result.matchResults.compactMap { try? $0.1.get() }
        
        return records
    }

    
    
}
