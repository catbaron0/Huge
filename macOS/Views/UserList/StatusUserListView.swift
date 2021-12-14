//
//  UserListStatusView.swift
//  GCoresTalk
//
//  Created by catbaron on 2021/12/05.
//

import SwiftUI

struct FollowshipCard: View {
    let user: TalkUser
    
    var body: some View {
        HStack {
            // Profile image, nickname, followship
            HStack {
                TalkCardProfileView(user: user)
                Text(user.nickname)
            }
            Spacer()
            Group {
                if let _ = user.followshipId {
                    Text("取消关注").frame(width: 100).padding(5).background(.gray)
                } else {
                    Text("关注").frame(width: 100).padding(5).background(.blue)
                }
            }
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 5))
            
            
        }
    }
}

struct StatusUserListView: View {
    @StateObject var status: ViewStatus
    @EnvironmentObject var gtalk: GCoresTalk
    @State var scrollerOffset: CGPoint = .zero
    let topOffsetTrigger = TopOffsetTrigger.userList
    var body: some View {
//        let sceneType = _status.sceneType
//        if let idx = gtalk.indexOf(status: _status) {
//            let status = gtalk.statusForScene[sceneType]![idx]
            let users = (status.statusType == .followers) ? status.followers : status.followees
            GeometryReader { proxy in
                VStack {
                    List{// ForEach
                        LazyVStack{ // ForEach(cards)
                            // LazyVstack to avoid refresh of cards
                            ForEach(users){ user in
                                // We need foreach to avoid reloading images everytime the talkcards appear
                                FollowshipCard(user: user)
                                Divider()
                            }
                            if status.loadingEarlier == .empty {
                                Text("这就是一切了。").padding()
                            }
                        }.readingScrollView(from: "scroll", into: $scrollerOffset)
                    }
                    .frame(maxWidth: .infinity)
                    .coordinateSpace(name: "scroll")
                    .overlay(alignment: .top) {
                        VStack { // LoadingBar

                            switch status.loadingLatest {
                            case .loading:
                                ProgressView()
                            case .empty, .loaded:
                                if scrollerOffset.x > CGFloat(topOffsetTrigger.rawValue) {
                                    Divider()
                                        .contentShape(Rectangle())
                                        .onAppear {
                                            gtalk.loadFollowship(status: status, earlier: false)
                                        }
                                }
                            }
                        }
                    }
                    VStack { // LoadingBar
                        switch status.loadingEarlier {
                        case .loading:
                            ProgressView()
                        case .loaded:
                            if proxy.size.height - scrollerOffset.y > -20 {
                                Divider()
                                    .contentShape(Rectangle())
                                    .onAppear {
                                        gtalk.loadFollowship(status: status, earlier: true)
                                    }
                            }
                        default:
                            EmptyView()
                        }
                    }.padding(.bottom)
                }
            }
//        }
    }
}
