//
//  ChallengeStatus.swift
//  todoTask
//
//  Created by شهد عبدالله القحطاني on 16/12/1447 AH.
//


//  ChallengeModels.swift
//  todoTask

import Foundation

// حالة المنافسة
enum ChallengeStatus: String, Codable {
    case waiting   // player1 ينتظر
    case active    // الاثنين موجودين
    case finished  // انتهى
}

// بيانات المنافسة في Firestore
struct ChallengeRoom: Codable, Identifiable {
    var id: String
    var player1Id: String
    var player1Name: String
    var player2Id: String?
    var player2Name: String?
    var status: ChallengeStatus
    var createdAt: Date
    var finishedAt: Date?
    var winnerId: String?
    var winnerName: String?
    // الكوكب المتنافَس عليه
    var planetGradient: [String]   // hex strings
    var planetGlow: Double
    var planetName: String
    var planetNameEn: String?
    var planetNameAr: String?
    var planetTextureAsset: String
    var planetTextureOpacity: Double
}

// مهمة واحدة داخل المنافسة
struct ChallengeTask: Codable, Identifiable {
    var id: String
    var title: String
    var points: Int
    var completedBy: String?  // userId أو nil
    var completedAt: Date?
}

// نتيجة الفائز تُمرَّر للـ OrbitView
struct ChallengeWinner: Identifiable {
    var id: String
    var name: String
    var planetGradient: [String]
    var planetGlow: Double
    var planetName: String
    var planetNameEn: String?
    var planetNameAr: String?
    var planetTextureAsset: String
    var planetTextureOpacity: Double
}