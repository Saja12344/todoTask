//
//  PlanetState.swift
//  todoTask
//
//  Created by شهد عبدالله القحطاني on 20/08/1447 AH.
//


import Foundation
import SwiftUI

// MARK: - 🪐 Planet Design Models (صفحة 8: تصميم الكوكب)

// ═══════════════════════════════════════════════════════════
// MARK: - Planet State (حالات الكوكب)
// ═══════════════════════════════════════════════════════════

enum PlanetState: String, Codable {
    case hidden      // مخفي
    case active      // نشط
    case completed   // مكتمل
    case damaged     // متضرر
    case stolen      // مسروق
}


// ═══════════════════════════════════════════════════════════
// MARK: - Planet Color (ألوان الكوكب)
// ═══════════════════════════════════════════════════════════

struct PlanetColor: Codable, Hashable {
    let red: Double
    let green: Double
    let blue: Double
    let opacity: Double
    
    var color: Color {
        Color(red: red, green: green, blue: blue, opacity: opacity)
    }
    
    static let pink = PlanetColor(red: 1.0, green: 0.41, blue: 0.71, opacity: 1.0)
    static let magenta = PlanetColor(red: 0.91, green: 0.11, blue: 0.36, opacity: 1.0)
    static let blue = PlanetColor(red: 0.39, green: 0.64, blue: 1.0, opacity: 1.0)
    static let purple = PlanetColor(red: 0.61, green: 0.35, blue: 0.71, opacity: 1.0)
}

// ═══════════════════════════════════════════════════════════
// MARK: - Planet Design (تصميم الكوكب)
// ═══════════════════════════════════════════════════════════

struct PlanetDesign: Codable {
    var colors: [PlanetColor]
    var glowIntensity: Double       // 0-100
    var ringCount: Int               // 0-3
    var ringThickness: Double        // 0-100
    var textureIntensity: Double     // 0-100
    var baselineNumber: Int?         // رقم أساسي
    var targetNumber: Int?           // رقم الهدف
}

// ═══════════════════════════════════════════════════════════
// MARK: - Planet Info (معلومات الكوكب)
// ═══════════════════════════════════════════════════════════
struct Planet: Codable, Identifiable {
    
    // MARK: - Identity
    
    var id: String { recordID }
    var recordID: String
    var ownerID: String
    
    // MARK: - Core State
    
    var state: PlanetState
    var goalID: String
    
    // MARK: - Progress
    
    var progressPercentage: Double
    
    // MARK: - Design
    
    var design: PlanetDesign?
    var tasks: [String] = []
}


// ═══════════════════════════════════════════════════════════
// MARK: - Planet Theme (ثيمات الكواكب)
// ═══════════════════════════════════════════════════════════

enum PlanetTheme: String, CaseIterable {
    case greenNature = "green_nature"       // للعادات
    case blueTech = "blue_tech"             // للمشاريع
    case purpleWisdom = "purple_wisdom"     // للتعلم
    case redEnergy = "red_energy"           // للياقة
    case goldWealth = "gold_wealth"         // للمالي
    case rainbowCustom = "rainbow_custom"   // مخصص
    
    var defaultColors: [PlanetColor] {
        switch self {
        case .greenNature:
            return [
                PlanetColor(red: 0.2, green: 0.8, blue: 0.4, opacity: 1.0),
                PlanetColor(red: 0.1, green: 0.6, blue: 0.3, opacity: 1.0)
            ]
        case .blueTech:
            return [
                PlanetColor(red: 0.2, green: 0.5, blue: 1.0, opacity: 1.0),
                PlanetColor(red: 0.4, green: 0.7, blue: 1.0, opacity: 1.0)
            ]
        case .purpleWisdom:
            return [
                PlanetColor(red: 0.6, green: 0.3, blue: 0.9, opacity: 1.0),
                PlanetColor(red: 0.8, green: 0.4, blue: 1.0, opacity: 1.0)
            ]
        case .redEnergy:
            return [
                PlanetColor(red: 1.0, green: 0.2, blue: 0.3, opacity: 1.0),
                PlanetColor(red: 1.0, green: 0.4, blue: 0.5, opacity: 1.0)
            ]
        case .goldWealth:
            return [
                PlanetColor(red: 1.0, green: 0.84, blue: 0.0, opacity: 1.0),
                PlanetColor(red: 0.85, green: 0.65, blue: 0.13, opacity: 1.0)
            ]
        case .rainbowCustom:
            return [
                PlanetColor.pink,
                PlanetColor.magenta,
                PlanetColor.blue,
                PlanetColor.purple
            ]
        }
    }
}

// ═══════════════════════════════════════════════════════════
// MARK: - Tracking Mode (وضع التتبع - للـ Reduce Something)
// ═══════════════════════════════════════════════════════════

enum TrackingMode: String, Codable {
    case reduceBy = "Reduce by"
    case stayUnder = "Stay under"
}

// ═══════════════════════════════════════════════════════════
// MARK: - Metric Type (نوع المقياس - للـ Reduce Something)
// ═══════════════════════════════════════════════════════════

enum MetricType: String, Codable, CaseIterable {
    case screenTime = "Screen Time"
    case spending = "Spending"
    case cigarettes = "Cigarettes"
    case sugar = "Sugar"
    case custom = "Custom"
}
