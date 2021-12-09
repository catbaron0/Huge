//
//  StatusTagTimelineView.swift
//  GCoresTalk
//
//  Created by catbaron on 2021/12/03.
//

import SwiftUI


struct StatusTagTimelineView: View {
    let _status: TalkStatus
    
    @State var scrollerOffset: CGPoint = .zero
    @EnvironmentObject var gtalk: GCoresTalk
    var body: some View {
        let sceneType = _status.sceneType
        if let idx = gtalk.indexOf(status: _status) {
            let status = gtalk.statusForScene[sceneType]![idx]
            let descView = HeaderView(desc: status.tag!.desc!)
            StatusTalksTimelineView(_status: status, headerView: descView, topOffsetTrigger: .timeline)

        }
    }
}
