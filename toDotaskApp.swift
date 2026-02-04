//
//  toDotaskApp.swift
//  toDotask
//
//  Created by saja khalid on 15/08/1447 AH.
//

import SwiftUI
import CoreData

@main
struct toDotaskApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
