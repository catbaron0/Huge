//
//  GCoresTalkApp.swift
//  Shared
//
//  Created by catbaron on 2021/11/25.
//

import SwiftUI

@main
struct GCoresTalkApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
