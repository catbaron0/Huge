//
//  StatusProfilePageView.swift
//  GCoresTalk
//
//  Created by catbaron on 2021/12/05.
//

import SwiftUI

struct ProfileImageView: View {
    @StateObject var status: ViewStatus
    @EnvironmentObject var gtalk: GCoresTalk
    
    var body: some View {
        let profileUrl = status.user?.profile.src ?? GCORES_DEFAULT_PROFILE_URL
        AsyncImage(url: URL(string: profileUrl)) { image in
            image
                .resizable()
                .frame(width: 60, height: 60)
                .scaledToFit()
                .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                .overlay(Circle().stroke(.gray, lineWidth: 2))
                .padding(.top, 5)
        } placeholder: {
            ProgressView()
                .frame(width: 45, height: 45)
        }
    }
}

struct StatusProfilePageView: View {
    @StateObject var status: ViewStatus
    @EnvironmentObject var gtalk: GCoresTalk
    
    var body: some View {

        if let user = status.user {
            VStack {
                Spacer().frame(height: TimelineTopPadding.titleBar.rawValue)
                HStack(alignment: .top) {
                    // Image, nickname, sex, follower/followee,
                    ProfileImageView(status: status).padding(.trailing)
                    VStack(alignment: .leading) {
                        Spacer().frame(height: 10)
                        HStack{
                            // TODO: Add gender info before/after the username
                            Text(user.nickname )
                            Spacer()
                            Group {
                                if let _ = user.followshipId {
                                    Text("取消关注").padding(5).background(.gray)
                                        .onTapGesture {
                                            gtalk.updateFollowship(status: status, targetId: user.id, follow: false)
                                        }
                                } else {
                                    Text("  关注  ").padding(5).background(.blue)
                                        .onTapGesture {
                                            gtalk.updateFollowship(status: status, targetId: user.id, follow: true)
                                        }
                                }
                            }
                            .font(.body)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.profileFollowship.rawValue))
                        }.font(.title2.weight(.semibold))
                        HStack(alignment: .bottom) {
                            // TODO: Add status of userlist
                            VStack {
                                Text("已关注").font(.callout.weight(.light)).opacity(0.6)
                                let count = user.followeesCount ?? 0
                                Text("\(count)").foregroundColor(.blue)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                gtalk.addStatusToCurrentScene(after: status, statusType: .followees, title: "已关注他们", icon: "square.and.arrow.up.fill", userId: status.userId!)
                            }
                            VStack{
                                Text("被关注").font(.callout.weight(.light)).opacity(0.6)
                                let count = user.followersCount ?? 0
                                Text("\(count)").foregroundColor(.blue)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                gtalk.addStatusToCurrentScene(after: status, statusType: .followers, title: "被他们关注", icon: "square.and.arrow.down.fill", userId: status.userId!)
                            }
                        }.font(.title2)
                    }
                    Spacer()
                }
                .padding(20)
                Divider()
                let descView = HeaderView(status: status, headerType: .users)
                StatusTalksTimelineView(
                    status: status,
                    scrollTopPadding: 0,
                    headerView: descView,
                    topOffsetTrigger: .profile)
//                if let intro = user.intro, intro.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
//                    StatusTalksTimelineView(
//                        status: status,
//                        scrollTopPadding: 0,
//                        headerView: HeaderView(status: status, headerType: <#T##GCoresRelatedType#>)
//                        topOffsetTrigger: .profile)
//
//                } else {
//                    StatusTalksTimelineView(
//                        status: status,
//                        scrollTopPadding: 0,
//                        headerView: nil,
//                        topOffsetTrigger: .profile)
//                }
            }
        } else {
            VStack {
                Spacer()
                if let userId = status.userId {
                    ProgressView()
                        .onAppear {
                            gtalk.loadUserInfo(userId: userId, status: status)
                        }
                    Spacer()
                }
            }
        }
        
    }
}
