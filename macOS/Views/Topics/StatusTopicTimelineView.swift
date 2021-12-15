//
//  StatusTopicTimelineView.swift
//  GCoresTalk
//
//  Created by catbaron on 2021/12/03.
//

import SwiftUI


struct StatusTopicTimelineView: View {
    @StateObject var status: ViewStatus
//    @State var scrollerOffset: CGFloat
    @EnvironmentObject var gtalk: GCoresTalk
    var body: some View {
            let descView = HeaderView(desc: status.topic!.desc!)
            StatusTalksTimelineView(
                status: status,
                scrollTopPadding: TimelineTopPadding.titleBar.rawValue,
                headerView: descView,
                topOffsetTrigger: .timeline)

//        }
    }
}
