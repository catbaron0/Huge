//
//  NewCommentView.swift
//  GCoresTalk
//
//  Created by catbaron on 2021/12/08.
//

import SwiftUI

struct NewCommentView: View {
    let targetUser: TalkUser?
    let targetTalkId: String
    let targetCommentId: String?
    // TODO: The sendStatus should be very simple, only containing sending states
    @StateObject var sendStatus: ViewStatus
    @StateObject var viewStatus: ViewStatus
    @ObservedObject var gtalk: GCoresTalk
    @State var comment: String = ""
    @State var checkInfo: String = ""
    let uuid = DateUtils.stampFromDate(date: Date())
    

    var body: some View {
        let sendState = sendStatus.requestState
        let opacity = (sendState != nil && sendState! == .sending) ? 0.5 : 1.0
        VStack{
            if let targetCommentId = targetCommentId {
                let replyToUser = viewStatus.getUserOfReplyTo(replyToId: targetCommentId)
                HStack{
                    Text("回复").font(.callout)
                    Text("\(replyToUser!.nickname)").foregroundColor(.red).font(.callout.bold())
                        .padding(.top, 3)
                }.padding(.top, 5)
            }
            TextEditor(text: $comment)
                .font(.body)
                .padding([.leading, .trailing])
                
            HStack{
                Spacer()
                if checkInfo != "" {
                    Text(checkInfo)
                }
                if let state = sendState {
                    if state == .sending {
                        HStack {
                            ProgressView().frame(width: 5)
                            Text("正在发送")
                        }
                    } else if state == .failed {
                        Label("发送失败", systemImage: "x.circle.fill").foregroundColor(.red)
                    }

                }
                Button {
                    if comment.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
                        checkInfo = "评论不能为空！"
                        return
                    } else {
                        checkInfo = ""
                    }
                    if sendState == nil || sendState! == .failed {
                        sendStatus.requestState = .sending
                        gtalk.sendComment(talkId: targetTalkId, commentId: targetCommentId, sendStatus: sendStatus, viewStatus: viewStatus, comment: comment)
                    }
                } label: {
                    Label("发送", systemImage: "paperplane.fill").frame(width: 60, height: 30)
                        .background(RoundedRectangle(cornerRadius: CornerRadius.normal.rawValue).fill(.red))
                }.padding(.trailing, 8).padding(.bottom, 8).buttonStyle(PlainButtonStyle()).opacity(opacity)
                    .disabled(sendStatus.requestState != nil && sendStatus.requestState! == .sending)

            }
        }
        .preferredColorScheme(.dark)
        .background(BlurView().colorMultiply(.blue.opacity(0.3)))
    }
}
