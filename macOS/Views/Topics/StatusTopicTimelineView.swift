//
//  StatusTopicTimelineView.swift
//  GCoresTalk
//
//  Created by catbaron on 2021/12/03.
//

import SwiftUI


struct StatusTopicTimelineView: View {
    @StateObject var status: ViewStatus
    @EnvironmentObject var gtalk: GCoresTalk
    var body: some View {
        let descView = HeaderView(status: status, headerType: .topics)
        StatusTalksTimelineView(
            status: status,
            scrollTopPadding: TimelineTopPadding.titleBar.rawValue,
            headerView: descView,
            topOffsetTrigger: .topics)
        
    }
}
