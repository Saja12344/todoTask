//
//  AuthMode.swift
//  todoTask
//
//  Created by saja khalid on 20/08/1447 AH.
//



import Foundation
import CloudKit

enum AuthMode: String, Codable {
    case guest
    case registered
}

struct User: Codable, Identifiable {
    var id: String // recordName من CloudKit
  
    
    var username: String
    var email: String
    
    // هل هو Guest أو Cloud
    var authMode: AuthMode = .guest
    
    // مؤقتاً فقط، يتم ملؤه عند Fetch
    var friends: [String] = []
    
    // مؤقتاً فقط، يمكن استخدامه عند Fetch
    var ownedPlanets: [String] = []
}
