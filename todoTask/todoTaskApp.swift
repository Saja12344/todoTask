//
//  todoTaskApp.swift
//  todoTask
//
//  Created by شهد عبدالله القحطاني on 19/08/1447 AH.
//

import SwiftUI

@main

struct todoTaskApp: App {
    
    init() {
        NotificationPermissionManager.shared.requestPermissionIfNeeded()
    }
    
    var body: some Scene {
        WindowGroup {
            Splash()

        }
    }
}

