//
//  TalkCardView.swift
//  GCoresTalk
//
//  Created by catbaron on 2021/11/25.
//

import SwiftUI


struct TalkCardProfileView: View {
    let user: TalkUser
    
    var body: some View {
        ImageReaderView(talkImage: user.profile)
            .frame(width: 45, height: 45)
            .scaledToFit()
            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
            .overlay(Circle().stroke(.gray, lineWidth: 2))
        
    }
}

struct TalkCardHeadView: View {
    let user: TalkUser
    let created: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading){
                Text(user.nickname).font(.title3)
                Text(String(created)).foregroundColor(.gray)
            }
            .frame(height: 50)
            
            Spacer()
        }
    }
}

struct TalkCardTopicsView: View {
    let topics: [TalkRelated]
    @EnvironmentObject var gtalk: GCoresTalk
    
    var body: some View {
        ForEach(topics) { topic in
            HStack{
                Text(topic.title!)
                //                    .font(.caption.bold())
                    .padding(5)
                    .foregroundColor(Color.red)
                    .background(Color(hue: 1.0, saturation: 0.368, brightness: 0.235))
                    .cornerRadius(30)
                    .onTapGesture {
                        let status = gtalk.statusForScene[gtalk.selectedTalkSceneType]?.last
                        if let statusType = status?.statusType, statusType != .topicTimeline, topic != status?.topic {
                            gtalk.addStatusToCurrentScene(after: status!, statusType: .topicTimeline, title: topic.title ?? "nil", icon: "tag.fill", topic: topic)
                        }
                    }
                Spacer()
            }
            .contentShape(Rectangle())
        }
    }
}

struct TalkCardBottomView: View {
    let _status: ViewStatus
    let talkCard: TalkCard
    @EnvironmentObject var gtalk: GCoresTalk
//    var curTalkCard: TalkCard?

    var body: some View {
        let sceneType = _status.sceneType
        if let idx = gtalk.indexOf(status: _status) {
            let status = gtalk.statusForScene[sceneType]![idx]
            HStack{
                // the card can be updated by voting
                // need to read it directly from environmengObject
                let curTalkCard = (status.statusType == .comments) ? status.targetTalk! : (status.talks.first {$0.id == talkCard.id })!
                let likesCount = curTalkCard.likesCount ?? 0
                HStack {
                    if let isVoting = curTalkCard.isVoting, isVoting {
                        Label(String(likesCount), systemImage: "heart.fill").foregroundColor(.gray).font(.caption)
                    } else if let voteFlag = curTalkCard.voteFlag, voteFlag {
                        Label(String(likesCount), systemImage: "heart.fill").foregroundColor(.red)
                            .onTapGesture { withAnimation {
                                gtalk.cancelVote(targetId: curTalkCard.id, targetType: .talks, voteId: curTalkCard.voteId!, status: status)
                            }}
                    } else {
                        Label(String(likesCount), systemImage: "heart").foregroundColor(.red)
                            .onTapGesture { withAnimation {
                                gtalk.voteTo(targetId: curTalkCard.id, targetType: .talks, voteFlag: true, _status: status)
                            }}
                    }
                }
                    
                let commentsCount = curTalkCard.commentsCount ?? 0
                HStack {
                    Label(String(commentsCount), systemImage: "bubble.right").foregroundColor(.red)
                        .onTapGesture {
                            newNSWindow(view: NewCommentView(targetUser: nil, targetTalkId: talkCard.id, targetCommentId: nil, _status: _status, gtalk: gtalk))
//                            gtalk.sendComment(talkId: talkCard.id, commentId: nil, _status: _status, comment: "233333")
                        }
                }
                Spacer()
            }.font(.title3.bold())
        }

    }
}


// MARK: - CardView
struct TalkCardView: View {
    @EnvironmentObject var gtalk: GCoresTalk
    let _status: ViewStatus
    let card: TalkCard
    let isSelected: Bool
    var body: some View {
        let sceneType = _status.sceneType
        if let idx = gtalk.indexOf(status: _status) {
            let status = gtalk.statusForScene[sceneType]![idx]
            HStack(alignment: .top) {
                TalkCardProfileView(user: card.user)
                    .onTapGesture {
//                        withAnimation{
                            gtalk.addStatusToCurrentScene(after: status, statusType: .profile, title: card.user.nickname, icon: "person.fill", targetTalk: card, topic: nil, userId: card.user.id)
//                        }
                    }
                
                VStack(alignment: .leading){
                    TalkCardHeadView(user: card.user, created: card.createdAt)
                    if let images = card.images, !images.isEmpty {
                        TalkCardImageView(talkImages: images)
                            .scaledToFit()
                    }
                    VStack{
                        ForEach(card.texts){ text in
                            Text(text.content)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 3, trailing: 0))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    
                    if let related = card.related {
                        Text(related.title!)
                    }
                    if let topics = card.topics {
                        TalkCardTopicsView(topics: topics)
                    }
                    TalkCardBottomView(_status: status, talkCard: card)
                }
                Spacer()
            }
            .padding(5)
            .contentShape(Rectangle())

        }
        
    }
}

