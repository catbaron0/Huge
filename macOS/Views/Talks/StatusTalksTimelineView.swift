//
//  StatusTalksTimelineView.swift
//  GCoresTalk
//
//  Created by catbaron on 2021/12/02.
//
import SwiftUI

struct StatusTalksTimelineView: View {
    @StateObject var status: ViewStatus
    let scrollTopPadding: CGFloat
    let headerView: HeaderView?
    let topOffsetTrigger: TopOffsetTrigger
    @State private var offset: CGPoint = .zero
    @EnvironmentObject var gtalk: GCoresTalk
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                List {// ForEach
                    LazyVStack{ // ForEach(cards)
                        // LazyVstack to avoid refresh of cards
                        Text("").padding(.top, scrollTopPadding)
                        if let headerView = headerView {
                            headerView
                        }
                        ForEach(status.talks){ card in
                            // We need foreach to avoid reloading images everytime the talkcards appear
                            TalkCardView(status: status, card: card, isSelected: card.id == status.targetTalk?.id)
                                .onTapGesture(count: 2) {
                                    gtalk.addStatusToCurrentScene(after: status, statusType: .comments, title: "评论", icon: "bubble.right.fill", targetTalkId: card.id)
                                }
                            Divider()
                        }
                        if status.loadingEarlier == .empty {
                            Text("这就是一切了。").padding()
                        }
                        
                    }.readingScrollView(from: "scroll", into: $offset)
                }.coordinateSpace(name: "scroll")
                    .overlay(alignment: .top) {
                        VStack { // LoadingBar
                            switch status.loadingLatest {
                            case .loading:
                                ProgressView()
                            case .loaded:
                                if offset.x > CGFloat(topOffsetTrigger.rawValue) {
                                    Divider()
                                        .contentShape(Rectangle())
                                        .onAppear {
                                            gtalk.loadTimeline(status: status, earlier: false)
                                        }
                                }
                            default:
                                EmptyView()
                            }
                        }
                        
                    }
                VStack { // LoadingBar
                    switch status.loadingEarlier {
                    case .loading:
                        ProgressView()
                    case .loaded, .empty:
                        if proxy.size.height - offset.y > -20 {
                            Divider()
                                .contentShape(Rectangle())
                                .onAppear {
                                    gtalk.loadTimeline(status: status, earlier: true)
                                }
                        }
                    }
                }.padding(.bottom)
            }
        }
    }
}
