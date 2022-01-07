//
//  UserListStatusView.swift
//  GCoresTalk
//
//  Created by catbaron on 2021/12/05.
//

import SwiftUI

struct FollowshipCard: View {
    @StateObject var status: ViewStatus
    let user: TalkUser
    @EnvironmentObject var gtalk: GCoresTalk
    
    var body: some View {
        HStack {
            // Profile image, nickname, followship
            HStack {
                TalkCardProfileView(user: user)
                    .onTapGesture {
                        gtalk.addStatusToCurrentScene(after: status, statusType: .profile, title: user.nickname, icon: "person.fill", userId: user.id)
                    }
                NicknameView(status: status, user: user)
            }
            Spacer()
            Group {
                if let _ = user.followshipId {
                    Text("取消关注").frame(width: 100).padding(5).background(.gray)
                        .onTapGesture {
                            gtalk.updateFollowship(status: status, targetId: user.id, follow: false)
                        }
                } else {
                    Text("关注").frame(width: 100).padding(5).background(.blue)
                        .onTapGesture {
                            gtalk.updateFollowship(status: status, targetId: user.id, follow: true)
                        }
                }
            }
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.normal.rawValue))
        }
    }
}

struct StatusUserListView: View {
    @StateObject var status: ViewStatus
    @EnvironmentObject var gtalk: GCoresTalk
    @State var scrollerOffset: CGPoint = .zero
    let topOffsetTrigger = TopOffsetTrigger.userList
    var body: some View {
            let users = (status.statusType == .followers) ? status.followers : status.followees
            GeometryReader { proxy in
                VStack {
                    ScrollView(showsIndicators: false) {// ForEach
                        Spacer().frame(height: TimelineTopPadding.titleBar.rawValue).padding(.top)
                        LazyVStack{ // ForEach(cards)
                            // LazyVstack to avoid refresh of cards
                            ForEach(users){ user in
                                // We need foreach to avoid reloading images everytime the talkcards appear
                                FollowshipCard(status: status, user: user)
                                    .padding(.leading)
                                    .padding(.trailing)
                                Divider()
                            }
                            if status.loadingEarlier == .empty {
                                Text("这就是一切了。").padding(.bottom, 20)
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
                    }
                }
            }
    }
}
