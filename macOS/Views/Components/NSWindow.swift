//
//  NSWindow.swift
//  GCoresTalk
//
//  Created by catbaron on 2021/12/08.
//

import SwiftUI

func newWindowForImageSlides(with images: [TalkImage])
{
    @State var winRef: NSWindow
    @State var winCtrl: NSWindowController
    
    winRef = NSWindow(
        contentRect: NSRect(x: 100, y: 100, width: 800, height: 600),
        styleMask: [.titled, .closable, .fullSizeContentView, .miniaturizable, .resizable],
        backing: .buffered, defer: false)
    winRef.center()
    winRef.isOpaque = false
    winRef.contentView = NSHostingView(rootView: ImageSlidesView(images: images).onTapGesture(count: 2) { NSApplication.shared.keyWindow?.close()})
//    winRef.setContentSize(view.geo)
    winRef.titlebarAppearsTransparent = true
    winRef.makeKeyAndOrderFront(nil)
    winRef.isMovableByWindowBackground = true
    
    winCtrl = NSWindowController(window: winRef)
}


func newNSWindow<T>(view: T) where T: View
{
    @State var winRef: NSWindow
    @State var winCtrl: NSWindowController
    winRef = NSWindow(
        contentRect: NSRect(x: 100, y: 100, width: 300, height: 200),
        styleMask: [.titled, .closable, .fullSizeContentView, .miniaturizable, .resizable],
        backing: .buffered, defer: false)
    winRef.center()
    winRef.isOpaque = false
    winRef.contentView = NSHostingView(rootView: view.ignoresSafeArea())
//    winRef.setContentSize(view.geo)
    winRef.titlebarAppearsTransparent = true
    winRef.makeKeyAndOrderFront(nil)
    winRef.isMovableByWindowBackground = true

    winCtrl = NSWindowController(window: winRef)
}
