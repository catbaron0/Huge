//
//  NewTalkView.swift
//  GCoresTalk
//
//  Created by catbaron on 2021/12/10.
//

import SwiftUI

struct NewTalkRelatedLabel: View {
    let text: String
    let icon: String
    let highlight: Bool
    
    var body: some View {
        if highlight {
            Label(text, systemImage: icon)
                .labelStyle(.iconOnly)
                .font(.title3.bold())
                .padding(.leading)
                .foregroundColor(.red)
        }
        else {
            Label(text, systemImage: icon)
                .labelStyle(.iconOnly)
                .font(.title3.bold())
                .padding(.leading)
        }
    }
}

struct NewTalkView: View {
    let windowId: String
//    let _status: ViewStatus
    @ObservedObject var gtalk: GCoresTalk
    
    @State  var topic: TalkRelated?
    @State  var talkText: String = ""
    @State  var checkInfo: String = ""
    @State  var relatedView: GCoresRelatedType = .topics
    @State  var images = [String]()
    @State  var related: TalkRelated? = nil
    @State  var query: String = ""
    @State  var searchMode = false
    @State  var triggerSensor: Bool = false
    @State  var searchResult: TalkRelated? = nil
    
    var body: some View {
        let sendState = gtalk.NSWindowRequestStates[windowId]
        let opacity = (sendState != nil && sendState! == .sending) ? 0.5 : 1.0

        VStack {
            TextEditor(text: $talkText)
                .frame(minWidth: 300)
                .frame(height: 100)

            // send button
            HStack {
                // Selected topic
                HStack {
                    if let topic = gtalk.NSWindowStatus[windowId]?.topic {
                        Label(topic.title ?? "nil", systemImage: "tag.fill")
                        Spacer()
                    } else {
                        Label("话题", systemImage: "rectangle.dashed")
                            .onTapGesture {
                                relatedView = .topics
                            }
                    }
                }
                Spacer()
                Button {
                    submit()
                } label: {
                    Label("发送", systemImage: "paperplane.fill")
                        .labelStyle(.iconOnly)
                        .frame(width: 40, height: 30)
                        .background(RoundedRectangle(cornerRadius: 5).fill(.red))
                        .foregroundColor(.white)

                }.buttonStyle(PlainButtonStyle()).opacity(opacity)
            }
            HStack {
                Button {
                    relatedView = .topics
                } label: {
                    NewTalkRelatedLabel(text: "话题", icon: "tag", highlight: relatedView == .topics)
                }
                .buttonStyle(.plain)
                Button {
                    relatedView = .image
                } label: {
                    NewTalkRelatedLabel(text: "图片", icon: "photo", highlight: !images.isEmpty)
                }
                .buttonStyle(.plain)
                Button {
                    relatedView = .games
                } label: {
                    NewTalkRelatedLabel( text: "游戏", icon: "gamecontroller", highlight: relatedView == .games)
                }
                .buttonStyle(.plain)
                Button {
                    relatedView = .radios
                } label: {
                    NewTalkRelatedLabel( text: "电台", icon: "antenna.radiowaves.left.and.right", highlight: relatedView == .radios )
                }
                .buttonStyle(.plain)
                Button {
                    relatedView = .articles
                } label: {
                    NewTalkRelatedLabel(text: "文章", icon: "square.text.square", highlight: relatedView == .articles )
                }
                .buttonStyle(.plain)
                Button {
                    relatedView = .videos
                } label: {
                    NewTalkRelatedLabel(text: "视频", icon: "play", highlight: relatedView == .videos)
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 5).padding(.trailing)
            .onChange(of: query) { text in
                if query == "" {
                    searchMode = false
                    gtalk.search(endponit: relatedView, query: "", searchId: windowId, earlier: false, recommend: true)
                }
            }
            .onChange(of: relatedView) { text in
                searchMode = false
                gtalk.search(endponit: relatedView, query: "", searchId: windowId, earlier: false, recommend: true)
            }

            // Images
            if !images.isEmpty {
                Text("show Image")
            }

            // Related content
            if let related = related {
                RelatedCardView(searchResult: related)
            }
            // Search input box
            HStack {
                TextField("搜索", text: $query, prompt: Text("搜索"))
                    .font(.title2)
                    .cornerRadius(5)
                    .padding(.bottom, 8)
                    .onSubmit {
                        submitSearch()
                    }
                    .onChange(of: relatedView) { _relatedView in
                        searchMode = false
                    }

                Button {
                    submitSearch()
                } label: {
                    Label("搜索", systemImage: "magnifyingglass").frame(height: 30)
                        .labelStyle(.iconOnly)
                        .frame(width: 40, height: 30)
                        .background(RoundedRectangle(cornerRadius: 5).fill(.red).opacity(0.85))
                        .foregroundColor(.white)
                        .font(.body.bold())

                }.padding(.bottom, 8).buttonStyle(PlainButtonStyle()).opacity(opacity)
            }


            // Related search results
            if !searchMode && relatedView == .topics {
                // List of topics
                HStack {
                    TopicCategoriesView(_status: gtalk.NSWindowStatus[windowId]!, windowId: windowId).environmentObject(gtalk)
                        .frame(minHeight: 500)
                        .onAppear { gtalk.readTopicsCategories() }
                    topicsView(status: gtalk.NSWindowStatus[windowId]!, related: $topic).environmentObject(gtalk)
                    Spacer()
                }
            } else {
                SearchRersultsView(windowId: windowId, selectResult: $searchResult, switchTrigger: $triggerSensor, query: $query, searchMode: $searchMode, searchType: relatedView).environmentObject(gtalk)
                    .frame(minHeight: 500)
                    .onChange(of: triggerSensor) { result in
                        if let result = searchResult {
                            if relatedView == .topics {
                                topic = result
                            } else {
                             related = result
                            }
                        }
                    }
            }
        }
    }
    
    func submitSearch() {
        if query.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            checkInfo = "内容不能为空！"
            return
        }
        // Set to searchMode
        searchMode = true
        // gtalk.searchTopic
        gtalk.search(endponit: relatedView, query: query, searchId: windowId, earlier: false, recommend: false)
    }

    func submit() {
        if talkText.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            checkInfo = "内容不能为空！"
            return
        }
        checkInfo = ""
//        if sendState == nil || sendState! == .failed {
//            gtalk.sendComment(talkId: targetTalkId, commentId: targetCommentId, _status: _status, comment: comment, uuid: uuid)
//        }
    }
}


