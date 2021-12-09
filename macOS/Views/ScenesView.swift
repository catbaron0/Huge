//
//  ScenesView.swift
//  GCoresTalk
//
//  Created by catbaron on 2021/12/05.
//

import SwiftUI

struct ScenesView: View {
    @EnvironmentObject var gtalk: GCoresTalk
    @State var offset: CGFloat = 0
    var body: some View {
        GeometryReader{ proxy in
            HStack(alignment: .top) {
                let sceneType = gtalk.selectedTalkSceneType
                let statuses = gtalk.statusForScene[sceneType]!
                ForEach(statuses){status in
                    Group{
                        switch status.statusType {
                        case .profile:
//                            Text("profile")
                            StatusProfilePageView(_status: status)
                        case .comments, .replies:
//                            Text("profile")
                            StatusCommentsView(_status: status)
                        case .followeeTimeline, .recommendTimeline:
//                            Text("profile")
                            StatusTalksTimelineView(_status: status, headerView: nil, topOffsetTrigger: .timeline)
                        case .topicTimeline:
//                            Text("profile")
                            StatusTopicTimelineView(_status: status)
                        case .topics:
//                            Text("tags")
                            StatusTopicsView(_status: status)
//                            StatusUserListView(_status: status)
                        case .followers, .followees:
//                            Text("profile")
                            StatusUserListView(_status: status)
                        default:
                            Text("Unknown scene").onAppear{print(status.statusType)}
                        }
                    }
                    .frame(width: proxy.size.width)
                    .onAppear{
                        withAnimation(.easeInOut(duration: 0.5)) {
                            offset = offset - proxy.size.width
                        }
                    }
                    .onDisappear {
                        withAnimation {
                        offset = offset + proxy.size.width
                        }
                    }
                }
            }.onAppear {
                offset = proxy.size.width
            }
//            .offset(x: (-proxy.size.width - 8) * ( CGFloat(gtalk.statusForScene[gtalk.selectedTalkSceneType]!.count) - 1))
            .offset(x: offset)
        }
    }
}
