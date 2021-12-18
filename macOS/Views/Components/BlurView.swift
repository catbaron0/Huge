//
//  BlurView.swift
//  GCoresTalk (macOS)
//
//  Created by CatBaron on 2021/12/18.
//

import SwiftUI

struct BlurView: NSViewRepresentable {
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        
        let blurView = NSVisualEffectView(frame: NSRect(x: 0, y: 0, width: 100, height: 100))
        blurView.blendingMode = NSVisualEffectView.BlendingMode.behindWindow
        blurView.material = NSVisualEffectView.Material.hudWindow
        blurView.isEmphasized = true
        blurView.state = NSVisualEffectView.State.active
        
        return blurView;
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        NSLog("updateNSView")
    }

}
