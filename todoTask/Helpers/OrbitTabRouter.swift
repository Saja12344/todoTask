//
//  OrbitTabRouter.swift
//  todoTask
//

import SwiftUI
import Combine

final class OrbitTabRouter: ObservableObject {
    @Published var selectedTab = 0

    func openOrbs() {
        selectedTab = 1
    }
}
