//
//  StatusProfilePageView.swift
//  GCoresTalk
//
//  Created by catbaron on 2021/12/05.
//

import SwiftUI

struct ProfileImageView: View {
    @EnvironmentObject var gtalk: GCoresTalk
    let _status: TalkStatus
    
    var body: some View {
        let sceneType = _status.sceneType
        if let idx = gtalk.indexOf(status: _status) {
            let status = gtalk.statusForScene[sceneType]![idx]
            let profileUrl = status.user?.profile.src ?? DEFAULT_PROFILE_URL
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
}

struct StatusProfilePageView: View {
    let _status: TalkStatus
    @EnvironmentObject var gtalk: GCoresTalk

    
    var body: some View {
        let sceneType = _status.sceneType
        if let idx = gtalk.indexOf(status: _status) {
            let status = gtalk.statusForScene[sceneType]![idx]
            let user = status.user
            if user == nil {
                VStack {
                    Spacer()
                    ProgressView()
                        .onAppear {
                            gtalk.readUserInfo(userId: status.userId!, _status: status)
                        }
                    Spacer()
                }
                    
            } else {
                VStack{
                    HStack(alignment: .bottom) {
                        // Image, nickname, sex, follower/followee,
                        ProfileImageView(_status: status)
                        VStack(alignment: .leading) {
                            HStack{
                                // TODO: Add gender info before/after the username
                                Text(user?.nickname ?? "nil")
                            }.font(.title2.weight(.semibold))
                            HStack(alignment: .bottom) {
                                // TODO: Add status of userlist
                                VStack {
                                    Text("已关注").font(.callout.weight(.light)).opacity(0.6)
                                    let count = user?.followeesCount ?? 0
                                    Text("\(count)").foregroundColor(.blue)
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
//                                    withAnimation {
                                        gtalk.addStatusToCurrentScene(after: status, statusType: .followees, title: "已关注他们", icon: "square.and.arrow.up.fill", targetTalk: nil, topic: nil, userId: status.userId!)
//                                    }
                                }
                                VStack{
                                    Text("被关注").font(.callout.weight(.light)).opacity(0.6)
                                    let count = user?.followersCount ?? 0
                                    Text("\(count)").foregroundColor(.blue)
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
//                                    withAnimation{
                                        gtalk.addStatusToCurrentScene(after: status, statusType: .followers, title: "被他们关注", icon: "square.and.arrow.down.fill", targetTalk: nil, topic: nil, userId: status.userId!)
//                                    }
                                }
                            }.font(.title2)
                        }
                        Spacer()
                    }.padding()
                    if let intro = user?.intro {
                        StatusTalksTimelineView(_status: status, headerView: HeaderView(desc: intro), topOffsetTrigger: .profile)

                    } else {
                        StatusTalksTimelineView(_status: status, headerView: nil, topOffsetTrigger: .profile)

                    }
                }
            }
        }
    }
}
