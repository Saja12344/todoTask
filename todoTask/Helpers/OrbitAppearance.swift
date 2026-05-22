//
//  OrbitAppearance.swift
//  todoTask
//

import SwiftUI
import UIKit

enum OrbitAppearance {
    static func configure() {
        let dark = UIUserInterfaceStyle.dark
        UIView.appearance().overrideUserInterfaceStyle = dark
        UIWindow.appearance().overrideUserInterfaceStyle = dark
        UINavigationBar.appearance().overrideUserInterfaceStyle = dark
        UITabBar.appearance().overrideUserInterfaceStyle = dark
        UITableView.appearance().overrideUserInterfaceStyle = dark
    }
}

extension View {
    /// Force dark styling on sheets, alerts, and pickers presented from this view.
    func orbitForcedDark() -> some View {
        self
            .preferredColorScheme(.dark)
            .environment(\.colorScheme, .dark)
    }

    func orbitDarkSheetBackground() -> some View {
        self
            .orbitForcedDark()
            .presentationBackground(Color.darkBlu)
            .presentationDragIndicator(.visible)
    }
}
