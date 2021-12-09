//
//  TalkCommentsView.swift
//  GCoresTalk
//
//  Created by catbaron on 2021/11/29.
//

import SwiftUI

struct TalkCommentBottomView: View {
    let comment: TalkCommentCard
    let _status: TalkStatus
    @EnvironmentObject var gtalk: GCoresTalk
    
    var body: some View {
        let sceneType = _status.sceneType
        if let idx = gtalk.indexOf(status: _status) {
            let status = gtalk.statusForScene[sceneType]![idx]
            HStack{
                // thumb up
                let likesCount = comment.likesCount ?? 0
                if let isVoting = comment.isVoting, isVoting {
                    Label("\(likesCount)", systemImage: "hand.thumbsup.circle").foregroundColor(.gray).font(.caption)
                } else if let voteId = comment.voteId, let voteFlag = comment.voteFlag, voteFlag  {
                    Label("\(likesCount)", systemImage: "hand.thumbsup.circle.fill").foregroundColor(.red)
                        .onTapGesture {
                            gtalk.cancelVote(targetId: comment.id, targetType: .comments, voteId: voteId, status: status)
                        }
                } else {
                    Label("\(likesCount)", systemImage: "hand.thumbsup.circle").foregroundColor(.red)
                        .onTapGesture {
                            gtalk.voteTo(targetId: comment.id, targetType: .comments, voteFlag: true, _status: status)
                        }
                }
                // thumb down
                if let isVoting = comment.isVoting, isVoting {
                    Label("-", systemImage: "hand.thumbsdown.circle").labelStyle(.iconOnly).foregroundColor(.gray).font(.caption)
                } else if let voteId = comment.voteId, let voteFlag = comment.voteFlag, !voteFlag  {
                    Label("-", systemImage: "hand.thumbsdown.circle.fill").labelStyle(.iconOnly).foregroundColor(.red)
                        .onTapGesture {
                            gtalk.cancelVote(targetId: comment.id, targetType: .comments, voteId: voteId, status: status)
                        }
                } else {
                    Label("-", systemImage: "hand.thumbsdown.circle").labelStyle(.iconOnly).foregroundColor(.red)
                        .onTapGesture {
                            gtalk.voteTo(targetId: comment.id, targetType: .comments, voteFlag: false, _status: status)
                        }
                }
                Spacer()
                Button{
                    newWindowForComment(view: NewCommentView(targetUser: comment.user, targetTalkId: _status.targetTalk!.id, targetCommentId: comment.id, _status: _status, gtalk: gtalk))
                } label: {Image(systemName: "arrowshape.turn.up.left.circle")}.foregroundColor(.red)
                .buttonStyle(.plain).padding(5)
            }.font(.title3.bold())
        }
        
    }
}

struct ReplyCardView: View {
    let _status: TalkStatus
    let reply: TalkCommentCard
    @EnvironmentObject var gtalk: GCoresTalk
    
    var body: some View {
        let sceneType = _status.sceneType
        if let idx = gtalk.indexOf(status: _status) {
            let status = gtalk.statusForScene[sceneType]![idx]
            HStack(alignment: .top) {
                TalkCardProfileView(user: reply.user)
                    .onTapGesture {
                        gtalk.addStatusToCurrentScene(after: status, statusType: .profile, title: reply.user.nickname, icon: "person.fill", targetTalk: nil, topic: nil, userId: reply.user.id)
                    }
                VStack(alignment: .leading) {
                    TalkCardHeadView(user: reply.user, created: reply.createdAt)
                    Text(reply.text)
                        .fixedSize(horizontal: false, vertical: true)
                    TalkCommentBottomView(comment: reply, _status: status)
                }
            }.padding(.leading, 40)
        }
    }
}

struct CommentCardView: View {
    let _status: TalkStatus
    let comment: TalkCommentCard
    let withReply: Bool
    @EnvironmentObject var gtalk: GCoresTalk
    
    var body: some View {
        let sceneType = _status.sceneType
        if let idx = gtalk.indexOf(status: _status) {
            let status = gtalk.statusForScene[sceneType]![idx]
            VStack {
                HStack(alignment: .top) {
                    TalkCardProfileView(user: comment.user).padding(.trailing)
                        .onTapGesture {
                            gtalk.addStatusToCurrentScene(
                                after: status, statusType: .profile, title: comment.user.nickname,
                                icon: "person.fill", targetTalk: nil, topic: nil, userId: comment.user.id
                            )
                        }
                    VStack(alignment: .leading) {
                        TalkCardHeadView(user: comment.user, created: comment.createdAt)
                        Text(comment.text)
                            .fixedSize(horizontal: false, vertical: true)
                        TalkCommentBottomView(comment: comment, _status: status)
                    }
                }.padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 10))
                if let oldestDecendants = comment.oldestDescendants, withReply {
                    VStack {
                        ForEach(oldestDecendants, id: \.self) { replyId in
                            if let reply = status.replies.first {$0.id == replyId} {
                                Divider()
                                ReplyCardView(_status: status, reply: reply)
                            }
                        }
                        if let decendantsCount = comment.descendantsCount, let oldestDecendants = comment.oldestDescendants, decendantsCount > oldestDecendants.count {
                            HStack {
                                Spacer()
                                Label("更多回复", systemImage: "arrow.down.circle").foregroundColor(.blue)
                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                gtalk.addStatusToCurrentScene(after: status, statusType: .replies, title: "回复", icon: "arrowshape.turn.up.left.2.circle.fill", targetTalk: _status.targetTalk, topic: nil, userId: nil, targetComment: comment)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct StatusCommentsView: View {
    let _status: TalkStatus
    @State var scrollerOffset: CGPoint = .zero
    @EnvironmentObject var gtalk: GCoresTalk
    var body: some View {
        let sceneType = _status.sceneType
        let idx = gtalk.indexOf(status: _status)
        let status = (idx == nil) ? _status : gtalk.statusForScene[sceneType]![idx!]

        GeometryReader { proxy in
            VStack {
                let topOffset = scrollerOffset.x
                List{// ForEach
                    LazyVStack{ // ForEach(cards)
                        // LazyVstack to avoid refresh of cards
                        if status.statusType == .comments {
                            TalkCardView(_status: status, card: status.targetTalk!, isSelected: false)
                            Divider().padding(.bottom, 10)
                            ForEach(status.comments){ comment in
                                // We need foreach to avoid reloading images everytime the talkcards appear
                                CommentCardView(_status: status, comment: comment, withReply: true)
                                Divider()
                            }
                            if status.loadingEarlier == .empty {
                                Text("这就是一切了。").padding()
                            }
                        } else if status.statusType == .replies {
                            CommentCardView(_status: status, comment: status.targetComment!, withReply: false)
                            Divider().padding(.bottom, 10)
                            ForEach(status.replies){ reply in
                                // We need foreach to avoid reloading images everytime the talkcards appear
                                ReplyCardView(_status: status, reply: reply)
                                Divider()
                            }
                            if status.loadingEarlier == .empty {
                                Text("这就是一切了。").padding()
                            }
                        }
                    }.readingScrollView(from: "scroll", into: $scrollerOffset)
                }
                .frame(maxWidth: .infinity)
                .frame(height: proxy.size.height)
                .coordinateSpace(name: "scroll")
                .overlay(alignment: .top) {
                    VStack { // LoadingBar

                        switch status.loadingLatest {
                        case .loading:
                            ProgressView()
                        case .loaded:
                            if scrollerOffset.x - topOffset > 100 {
                                Divider()
                                    .contentShape(Rectangle())
                                    .onAppear {
                                        gtalk.readComments(talkId: status.targetTalk!.id, _status: status, earlier: false)
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
                    case .loaded:
                        if proxy.size.height - scrollerOffset.y > -30 {
                            Divider()
                                .contentShape(Rectangle())
                                .onAppear {
                                    if status.statusType == .comments {
                                        gtalk.readComments(talkId: status.targetTalk!.id, _status: status, earlier: true)
                                    } else if status.statusType == .replies {
                                        gtalk.readReplies(commentId: status.targetComment!.id, _status: status)
                                    }
                                }
                        }
                    default:
                        EmptyView()
                    }
                }.padding(.bottom)
            }
        }
    }
}


struct StatusRepliesView: View {
    let _status: TalkStatus
    @State var scrollerOffset: CGPoint = .zero
    @EnvironmentObject var gtalk: GCoresTalk
    var body: some View {
        let sceneType = _status.sceneType
        if let idx = gtalk.indexOf(status: _status) {
            let status = gtalk.statusForScene[sceneType]![idx]
            GeometryReader { proxy in
                VStack {
                    let topOffset = scrollerOffset.x
                    List{// ForEach
                        LazyVStack{ // ForEach(cards)
                            // LazyVstack to avoid refresh of cards
                            TalkCardView(_status: status, card: status.targetTalk!, isSelected: false)
                            Divider().padding(.bottom, 10)
                            ForEach(status.comments){ comment in
                                // We need foreach to avoid reloading images everytime the talkcards appear
                                CommentCardView(_status: status, comment: comment, withReply: false)
                                Divider()
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
                                if scrollerOffset.x - topOffset > 40 {
                                    Divider()
                                        .contentShape(Rectangle())
                                        .onAppear {
                                            gtalk.readComments(talkId: status.targetTalk!.id, _status: status, earlier: false)
                                        }
                                    
                                }
                            }
                        }
                    }
                    VStack { // LoadingBar
                        switch status.loadingEarlier {
                        case .loading:
                            ProgressView()
                        case .loaded, .empty:
                            if proxy.size.height - scrollerOffset.y > -20 {
                                Divider()
                                    .contentShape(Rectangle())
                                    .onAppear {
                                        gtalk.readComments(talkId: status.targetTalk!.id, _status: status, earlier: true)
                                    }
                            }
                        }
                    }.padding(.bottom)
                }
            }
        }
    }
}
