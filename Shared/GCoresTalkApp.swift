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
    @StateObject var gtalk = GCoresTalk()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext).environmentObject(gtalk)
        }.windowStyle(HiddenTitleBarWindowStyle())
            .commands {
                CommandGroup(before: CommandGroupPlacement.newItem) {
                    Button("New Talk") {
                        let status = gtalk.statusForScene[gtalk.selectedTalkSceneType]!.last!
                        let newStatus = ViewStatus(id: UUID().uuidString, sceneType: .newWindow, statusType: .newTalk, title: "新 Talk", icon: "pencil.and.outline")
                        newNSWindow(view: NewTalkView(status: newStatus, gtalk: gtalk, topic: status.topic))
                    }.keyboardShortcut("N", modifiers: [.command, .shift])
                }
            }
    }
}
