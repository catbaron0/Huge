//
//  TalkCommentsView.swift
//  GCoresTalk
//
//  Created by catbaron on 2021/11/29.
//

import SwiftUI

struct CommentCardHeadView: View {
    @StateObject var status: ViewStatus
    let user: TalkUser
    let created: String
    let replyTo: TalkUser?
    @EnvironmentObject var gtalk:GCoresTalk
    
    var body: some View {
        HStack {
            VStack(alignment: .leading){
                HStack {
                    NicknameView(status: status, user: user)
                    if let replyTo = replyTo {
                        Label(replyTo.nickname, systemImage: "arrow.right.circle")
                    }
                }
                Text(String(created)).foregroundColor(.gray)
            }
            .frame(height: 50)
            
            Spacer()
        }
    }
}


struct TalkCommentBottomView: View {
    let comment: TalkCommentCard
    @StateObject var status: ViewStatus
    @EnvironmentObject var gtalk: GCoresTalk
    
    var body: some View {
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
                        gtalk.voteTo(targetId: comment.id, targetType: .comments, voteFlag: true, status: status)
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
                        gtalk.voteTo(targetId: comment.id, targetType: .comments, voteFlag: false, status: status)
                    }
            }
            Spacer()
            Button{
                newNSWindow(view: NewCommentView(targetUser: nil, targetTalkId: status.targetTalk!.id, targetCommentId: comment.id, status: status.copy(), gtalk: gtalk))
            } label: {Image(systemName: "arrowshape.turn.up.left.circle")}.foregroundColor(.red)
                .buttonStyle(.plain).padding(5)
        }.font(.title3.bold())
    }
}

struct ReplyCardView: View {
    @StateObject var status: ViewStatus
    let reply: TalkCommentCard
    @EnvironmentObject var gtalk: GCoresTalk
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                TalkCardProfileView(user: reply.user)
                    .onTapGesture {
                        gtalk.addStatusToCurrentScene(after: status, statusType: .profile, title: reply.user.nickname, icon: "person.fill", userId: reply.user.id)
                    }
                
                CommentCardHeadView(status: status, user: reply.user, created: reply.createdAt, replyTo: status.getUserOfReplyTo(replyToId: reply.replyTo))
            }
            Text(reply.text)
                .fixedSize(horizontal: false, vertical: true)
                .font(GCoresFont.body)
            TalkCommentBottomView(comment: reply, status: status)
        }.padding(.leading, 40)
    }
}

struct CommentCardView: View {
    @StateObject var status: ViewStatus
    let comment: TalkCommentCard
    let withReply: Bool
    @EnvironmentObject var gtalk: GCoresTalk
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                HStack(alignment: .bottom) {
                    TalkCardProfileView(user: comment.user)
                        .onTapGesture {
                            gtalk.addStatusToCurrentScene(
                                after: status, statusType: .profile, title: comment.user.nickname, icon: "person.fill", userId: comment.user.id
                            )
                        }
                    CommentCardHeadView(status: status, user: comment.user, created: comment.createdAt, replyTo: status.getUserOfReplyTo(replyToId: comment.replyTo))
                }
                Text(comment.text)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(GCoresFont.body)
                TalkCommentBottomView(comment: comment, status: status)
                
            }
            .padding(EdgeInsets(top: 10, leading: 5, bottom: 0, trailing: 10))
            if let oldestDecendants = comment.oldestDescendants, withReply {
                VStack {
                    ForEach(oldestDecendants, id: \.self) { replyId in
                        if let reply = status.replies.first {$0.id == replyId} {
                            Divider()
                            ReplyCardView(status: status, reply: reply)
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
                            gtalk.addStatusToCurrentScene(after: status, statusType: .replies, title: "回复", icon: "arrowshape.turn.up.left.2.circle.fill", targetCommentId: comment.id)
                        }
                    }
                }
            }
        }
    }
}

struct StatusCommentsView: View {
    @StateObject var status: ViewStatus
    @State var scrollerOffset: CGPoint = .zero
    @EnvironmentObject var gtalk: GCoresTalk
    var body: some View {
        GeometryReader { proxy in
            VStack {
                let topOffset = scrollerOffset.x
                ScrollView(showsIndicators: false) {// ForEach
                    LazyVStack{ // ForEach(cards)
                        // LazyVstack to avoid refresh of cards
                        Spacer().frame(height: TimelineTopPadding.titleBar.rawValue)
                        if status.statusType == .comments {
                            if let targetTalk = status.targetTalk {
                                TalkCardView(status: status, card: targetTalk, isSelected: false)
                                Divider().padding(.bottom, 10)
                            } else if let talkId = status.targetTalkId {
                                ProgressView()
                                    .onAppear {
                                        gtalk.loadTalk(status: status, talkId: talkId)
                                    }
                            }
                            ForEach(status.comments){ comment in
                                // We need foreach to avoid reloading images everytime the talkcards appear
                                CommentCardView(status: status, comment: comment, withReply: true)
                                Divider()
                            }
                            if status.loadingEarlier == .empty {
                                Text("这就是一切了。").padding(.bottom, 20)
                            }
                        } else if status.statusType == .replies {
                            if let targetTalkId = status.targetTalkId {
                                HStack {
                                    Spacer()
                                    Label("查看原文", systemImage: "arrow.up.forward")
                                        .padding(3)
                                        .foregroundColor(.blue)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            gtalk.addStatusToCurrentScene(after: status, statusType: .comments, title: "评论", icon: "bubble.right.fill", targetTalkId: targetTalkId)
                                        }
                                    Spacer()
                                }
                            } else if let url = status.targetRelated?.shareUrl {
                                HStack {
                                    Spacer()
                                    Label("查看原文", systemImage: "arrow.up.forward")
                                        .padding(3)
                                        .foregroundColor(.blue)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            NSWorkspace.shared.open(URL(string: url)!)
                                        }
                                    Spacer()
                                }
                            }
                            if let targetComment = status.targetComment {
                                CommentCardView(status: status, comment: targetComment, withReply: false)
                                Divider().padding(.bottom, 10)
                            }
                            ForEach(status.replies){ reply in
                                // We need foreach to avoid reloading images everytime the talkcards appear
                                ReplyCardView(status: status, reply: reply)
                                Divider()
                            }
                            if status.loadingEarlier == .empty {
                                Text("这就是一切了。").padding(.bottom, 20)
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
                                        gtalk.loadComments(talkId: status.targetTalk!.id, status: status, earlier: false)
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
                        if proxy.size.height - scrollerOffset.y > -50 {
                            Divider()
                                .contentShape(Rectangle())
                                .onAppear {
                                    if status.statusType == .comments, let talkId = status.targetTalkId {
                                        gtalk.loadComments(talkId: talkId, status: status, earlier: true)
                                    } else if status.statusType == .replies, let commentId = status.targetCommentId {
                                        gtalk.loadReplies(commentId: commentId, status: status)
                                    }
                                }
                        }
                    default:
                        EmptyView()
                    }
                }.padding(.bottom)
            }.padding()
        }
    }
}


struct StatusRepliesView: View {
    @StateObject var status: ViewStatus
    @State var scrollerOffset: CGPoint = .zero
    @EnvironmentObject var gtalk: GCoresTalk
    var body: some View {
        //        let sceneType = _status.sceneType
        //        if let idx = gtalk.indexOf(status: _status) {
        //            let status = gtalk.statusForScene[sceneType]![idx]
        GeometryReader { proxy in
            VStack {
                let topOffset = scrollerOffset.x
                List{// ForEach
                    LazyVStack{ // ForEach(cards)
                        // LazyVstack to avoid refresh of cards
                        TalkCardView(status: status, card: status.targetTalk!, isSelected: false)
                        Divider().padding(.bottom, 10)
                        ForEach(status.comments){ comment in
                            // We need foreach to avoid reloading images everytime the talkcards appear
                            CommentCardView(status: status, comment: comment, withReply: false)
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
                                        gtalk.loadComments(talkId: status.targetTalk!.id, status: status, earlier: false)
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
                                    gtalk.loadComments(talkId: status.targetTalk!.id, status: status, earlier: true)
                                }
                        }
                    }
                }.padding(.bottom)
            }
        }
        //        }
    }
}
