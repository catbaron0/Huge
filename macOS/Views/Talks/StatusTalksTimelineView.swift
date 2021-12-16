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
                ScrollViewReader { scroll in

                    List {// ForEach
                        LazyVStack{
                            // ForEach(cards)
                            // LazyVstack to avoid refresh of cards
                            Spacer().frame(height: scrollTopPadding).id(0)
                            if let headerView = headerView {
                                headerView.padding(.bottom).id(1)
                            }
                            VStack { // Top LoadingBar
                                switch status.loadingLatest {
                                case .loading:
                                    ProgressView().onAppear {
                                        if !status.talks.isEmpty {
//                                            let viewId = status.talks[0].id
                                            scroll.scrollTo(0)
                                        }
                                    }
                                case .loaded:
                                    if offset.x > CGFloat(topOffsetTrigger.rawValue) {
                                        Divider()
                                            .contentShape(Rectangle())
                                            .onAppear {
                                                withAnimation {
                                                    gtalk.loadTimeline(status: status, earlier: false)
                                                }
                                            }
                                    }
                                default:
                                    EmptyView()
                                }
                            }.id(2)
                            ForEach(status.talks){ card in
                                // We need foreach to avoid reloading images everytime the talkcards appear
                                TalkCardView(status: status, card: card, isSelected: card.id == status.targetTalk?.id).id(Int(card.id))
                                    .onTapGesture(count: 2) {
                                        print(card.id)
                                        gtalk.addStatusToCurrentScene(after: status, statusType: .comments, title: "评论", icon: "bubble.right.fill", targetTalkId: card.id)
                                    }
//                                Divider()
                            }
                            VStack { // Bottom LoadingBar
                                switch status.loadingEarlier {
                                case .loading:
                                    ProgressView()
                                case .empty:
                                    Text("这就是一切了。").padding()
                                case .loaded:
                                    if proxy.size.height - offset.y > -20 && proxy.size.height - offset.y < 10 {
                                        Divider()
                                            .contentShape(Rectangle())
                                            .onAppear {
                                                print("bottom ofset \(proxy.size.height - offset.y)")
                                                print(status.loadingLatest)
                                                status.loadingEarlier = .loading
                                                gtalk.loadTimeline(status: status, earlier: true)
                                            }
                                    }
                                }
                            }.padding(.bottom).id(3)
                            //                        if status.loadingEarlier == .empty {
                            //                            Text("这就是一切了。").padding()
                            //                        }
                            
                        }.readingScrollView(from: "scroll", into: $offset)
                        
                    }
                }.coordinateSpace(name: "scroll")
            }
            .onAppear {
                gtalk.loadTimeline(status: status, earlier: false)
            }
        }
    }
}
