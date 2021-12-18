//
//  GCoresTalkApp.swift
//  Shared
//
//  Created by catbaron on 2021/11/25.
//
import Cocoa
import SwiftUI

@main
struct GCoresTalkApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject var gtalk = GCoresTalk()
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .environment(\.managedObjectContext, persistenceController.container.viewContext).environmentObject(gtalk)
                .handlesExternalEvents(preferring: Set(arrayLiteral: "*"), allowing: Set(arrayLiteral: "*"))
                .onOpenURL { url in
                    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                        print("Invalid URL or album path missing")
                        return
                    }
                    let scene = components.path
                    if let sceneType = TalkSceneType(rawValue: scene) {
                        gtalk.selectedTalkSceneType = sceneType
                        while gtalk.statusForScene[sceneType]!.count > 1 {
                            gtalk.back()
                        }
                    }
                    else {
                        print("Invalid URL or album path missing")
                    }
                }
        }
        .windowStyle(HiddenTitleBarWindowStyle())
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
class StatusBarController {
    private var statusBar: NSStatusBar
    private var statusItem: NSStatusItem
    private var mainView: NSView
    
    init(_ view: NSView) {
        self.mainView = view
        statusBar = NSStatusBar()
        statusItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)
        
        if let statusBarButton = statusItem.button {
            statusBarButton.title = "MinimalMenuBarApp"
            let menuItem = NSMenuItem()
            menuItem.view = mainView
            let menu = NSMenu()
            menu.addItem(menuItem)
            statusItem.menu = menu
        }
    }
}
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBar: StatusBarController?
    
    private func applicationDidFinishLaunching(_ aNotification: Notification) {
        let contentView = ContentView()
        let mainView = NSHostingView(rootView: contentView)
        mainView.frame =  NSRect(x: 0, y: 0, width: 200, height: 200)
        statusBar = StatusBarController(mainView)
    }
    
}
