//
//  ScenesView.swift
//  GCoresTalk
//
//  Created by catbaron on 2021/12/05.
//

import SwiftUI

struct ScenesView: View {
    let sceneType: TalkSceneType
    @EnvironmentObject var gtalk: GCoresTalk
    @State var offset: CGFloat = 0
    var body: some View {
        GeometryReader{ proxy in
            HStack(alignment: .top) {
                let statuses = gtalk.statusForScene[sceneType]!
                ForEach(statuses){status in
                    Group{
                        switch status.statusType {
                        case .profile:
                            StatusProfilePageView(status: status)
                        case .comments, .replies:
                            StatusCommentsView(status: status)
                        case .followeeTimeline, .recommendTimeline:
                            StatusTalksTimelineView(
                                status: status,
                                scrollTopPadding: TimelineTopPadding.titleBar.rawValue,
                                headerView: nil,
                                topOffsetTrigger: .timeline)
                        case .topicTimeline:
                            StatusTopicTimelineView(
                                status: status
                            )
                        case .topics:
                            StatusTopicsView(status: status)
                        case .followers, .followees:
                            StatusUserListView(status: status)
                        case .notification:
                            StatusNotificationView(
                                status: status,
                                scrollTopPadding: TimelineTopPadding.titleBar.rawValue,
                                topOffsetTrigger: .timeline
                            )
                        default:
                            Text("Unknown scene").onAppear{print(status.statusType)}
                        }
                    }
                    .frame(width: proxy.size.width)
                }
            }
            .offset(x: -(proxy.size.width + 8) * CGFloat(gtalk.statusForScene[sceneType]!.count - 1))
        }
    }
}
