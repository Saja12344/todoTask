//
//  OrbGoalModels.swift
//  todoTask
//
//  Created by Ruba Alghamdi on 27/08/1447 AH.
//

import SwiftUI

struct OrbGoal: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String

    // Achievement
    var totalTasks: Int
    var doneTasks: Int

    // Planet design
    var design: OrbDesign

    var progress: Double {
        guard totalTasks > 0 else { return 0 }
        return min(1, max(0, Double(doneTasks) / Double(totalTasks)))
    }
}

// Codable-friendly design (we can’t directly Codable Color, so we store RGBA)
struct OrbDesign: Codable, Equatable {
    var glow: Double
    var textureOpacity: Double
    var textureAssetName: String?
    var gradientStops: [RGBAColor]
}

struct RGBAColor: Codable, Equatable {
    var r: Double
    var g: Double
    var b: Double
    var a: Double

    var swiftUIColor: Color {
        Color(.sRGB, red: r, green: g, blue: b, opacity: a)
    }

    static func from(_ color: Color) -> RGBAColor {
        // best-effort: if you already store colors as fixed presets, this is enough.
        // For full accurate conversion, we’d pass UIColor in iOS.
        // We'll provide a practical UIKit-based converter below in the extension.
        color.toRGBA() ?? RGBAColor(r: 0.6, g: 0.2, b: 0.9, a: 1)
    }
}

extension OrbGoal {
    static var mock: OrbGoal {
        OrbGoal(
            id: UUID(),
            title: "Learn Spanish",
            totalTasks: 10,
            doneTasks: 4,
            design: OrbDesign(
                glow: 0.12,
                textureOpacity: 0.85,
                textureAssetName: "effect1",
                gradientStops: [
                    RGBAColor(r: 0.16, g: 0.26, b: 0.95, a: 1),
                    RGBAColor(r: 0.60, g: 0.50, b: 0.98, a: 1),
                    RGBAColor(r: 0.93, g: 0.30, b: 0.96, a: 1)
                ]
            )
        )
    }
}
import UIKit

extension Color {
    func toRGBA() -> RGBAColor? {
        let ui = UIColor(self)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        guard ui.getRed(&r, green: &g, blue: &b, alpha: &a) else { return nil }
        return RGBAColor(r: Double(r), g: Double(g), b: Double(b), a: Double(a))
    }
}
