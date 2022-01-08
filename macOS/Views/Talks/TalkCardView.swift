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
    @StateObject var status: ViewStatus
    let user: TalkUser
    let created: String
    @EnvironmentObject var gtalk: GCoresTalk
    
    var body: some View {
        HStack {
            VStack(alignment: .leading){
                NicknameView(status: status, user: user)
                Text(String(created)).foregroundColor(.gray)
            }
            .frame(height: 50)
            
            Spacer()
        }
    }
}

struct TalkCardTopicsView: View {
    @StateObject var status: ViewStatus
    let topics: [TalkRelated]
    @EnvironmentObject var gtalk: GCoresTalk
    
    var body: some View {
        ForEach(topics) { topic in
            HStack{
                Text(topic.title!)
                    .padding(5)
                    .foregroundColor(Color.red)
                    .background(Color(hue: 1.0, saturation: 0.368, brightness: 0.235))
                    .cornerRadius(30)
                    .onTapGesture {
                        if status.statusType != .topicTimeline, topic != status.targetTopic {
                            gtalk.addStatusToCurrentScene(after: status, statusType: .topicTimeline, title: topic.title ?? "nil", icon: "tag.fill", topic: topic)
                        }
                    }
                Spacer()
            }
            .contentShape(Rectangle())
        }
    }
}

struct TalkCardBottomView: View {
    @StateObject var status: ViewStatus
    let talkCard: TalkCard
    @EnvironmentObject var gtalk: GCoresTalk
    
    var body: some View {
        HStack{
            if let curTalkCard = (status.statusType == .comments) ? status.targetTalk! : (status.talks.first {$0 == talkCard }) {
                let likesCount = curTalkCard.likesCount ?? 0
                HStack {
                    if let isVoting = curTalkCard.isVoting, isVoting {
                        Label(String(likesCount), systemImage: "heart.fill").foregroundColor(.white)
                    } else if let voteFlag = curTalkCard.voteFlag, voteFlag {
                        Label(String(likesCount), systemImage: "heart.fill").foregroundColor(.red)
                            .onTapGesture { withAnimation {
                                gtalk.cancelVote(targetId: curTalkCard.id, targetType: .talks, voteId: curTalkCard.voteId!, status: status)
                            }}
                    } else {
                        Label(String(likesCount), systemImage: "heart").foregroundColor(.red)
                            .onTapGesture { withAnimation {
                                gtalk.voteTo(targetId: curTalkCard.id, targetType: .talks, voteFlag: true, status: status)
                            }}
                    }
                }
                
                let commentsCount = curTalkCard.commentsCount ?? 0
                HStack {
                    Label(String(commentsCount), systemImage: "bubble.right").foregroundColor(.red)
                        .onTapGesture {
                            newNSWindow(view: NewCommentView(targetUser: nil, targetTalkId: talkCard.id, targetCommentId: nil, sendStatus: status.copy(), viewStatus: status, gtalk: gtalk))
                        }
                }
            }
            else {
                EmptyView()
            }

        }.font(.title3.bold())
    }
}


// MARK: - CardView
struct TalkCardView: View {
    @EnvironmentObject var gtalk: GCoresTalk
    @ObservedObject var status: ViewStatus
    let card: TalkCard
    let isSelected: Bool
    var body: some View {
        VStack(alignment: .leading){
            HStack(alignment: .top) {
                TalkCardProfileView(user: card.user)
                    .onTapGesture {
                        gtalk.addStatusToCurrentScene(after: status, statusType: .profile, title: card.user.nickname, icon: "person.fill", userId: card.user.id)
                    }
                TalkCardHeadView(status: status, user: card.user, created: card.createdAt)
                Spacer()
            }.padding(.bottom, 5)
            if let images = card.images, !images.isEmpty {
                TalkCardImageView(talkImages: images)
            }
            VStack{
                ForEach(card.texts){ text in
                    Text(text.content)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 3, trailing: 0))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(GCoresFont.body)
                }
            }.padding(5)
            
            if let related = card.related {
                Link(destination: URL(string: related.shareUrl)!) {
                    RelatedCardView(related: related)
                        .frame(height: 70)
                        .padding(5)
                        .background(.red)
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.normal.rawValue))
                }.foregroundColor(.white)
            }
            HStack {
                if let topics = card.topics {
                    TalkCardTopicsView(status: status, topics: topics)
                }
                Spacer()
                TalkCardBottomView(status: status, talkCard: card)
                    .padding(.trailing)
            }
        }
        .padding(5)
        .contentShape(Rectangle())
    }
}

