//
//  StatusTagsView.swift
//  GCoresTalk
//
//  Created by catbaron on 2021/12/03.
//
//
import SwiftUI

struct TopicCategoryCardView: View {
    // The card view shown in the sidebar of tagsview
    let topicCategory: TalkTopicCategory

    var body: some View {
        HStack{
            Spacer()
            Text(topicCategory.name)
            Spacer()
        }
        .padding(.top)
        .padding(.bottom)
        .frame(maxHeight: .infinity)
        .contentShape(Rectangle())
    }
}

struct TopicCategoriesView: View {
    let _status: ViewStatus
    let windowId: String?
    @State private var offset: CGPoint = .zero
    @EnvironmentObject var gtalk: GCoresTalk
    @State var selectedTopicCategory: TalkTopicCategory? = nil
    var body: some View {
//        let sceneType = _status.sceneType
//        if let idx = gtalk.indexOf(status: _status) {
//        let status = gtalk.statusForScene[sceneType]![idx]
//        let status = windowId == nil ? gtalk.statusForScene[_status.sceneType]!.first { $0.id == _status.id} : gtalk.NSWindowStatus[windowId!]!
        ScrollView(showsIndicators: false) {
            VStack {
                ForEach(gtalk.topicCategories) { category in
                    Group {
//                        if category == gtalk.selectedTopicCategory {
                        if category == selectedTopicCategory {
                            TopicCategoryCardView(topicCategory: category)
                                .background(Rectangle().fill(.red).opacity(0.8))
                                .font(.body.bold())
                        } else {
                            TopicCategoryCardView(topicCategory: category)
                        }

                    }
                        .onTapGesture{
//                            gtalk.select(topicCategory: category)
                            selectedTopicCategory = category
                            withAnimation {
                                gtalk.readTopics(categoryId: category.id, windowId: windowId)
                            }
                        }
                }
                Spacer()
            }
        }
    }
}


struct TopicCardView: View {
    let topic: TalkRelated

    var body: some View {
        HStack{
            Text(topic.title!)
            Spacer()
        }
        .padding(.top)
        .padding(.leading)
        .contentShape(Rectangle())
    }
}

struct topicsView: View {
    @State var status: ViewStatus
    @EnvironmentObject var gtalk: GCoresTalk
    @Binding var related: TalkRelated?
    var body: some View {
        ScrollView {
            VStack {
                ForEach(gtalk.selectedTopics) { topic in
                    TopicCardView(topic: topic)
                        .onTapGesture {
                            related = TalkRelated(id: topic.id, type: .topics, title: topic.title, desc: nil, cover: nil, banner: nil, contentString: nil)
                            gtalk.addStatusToCurrentScene(
                                after: status, statusType: .topicTimeline, title: topic.title!,
                                icon: "tag.fill", targetTalk: nil, topic: topic
                            )
                        }
                }
                Spacer()
            }
        }
    }
}

struct StatusTopicsView: View {
    @State var _status: ViewStatus
    let windowId: String
    @EnvironmentObject var gtalk: GCoresTalk

    @State private var sending = false
    @State private var checkInfo: String = ""
    @State private var query: String = ""
    @State private var searchMode: Bool = false
    @State private var isFocused: Bool = false
    @State private var searchResult: TalkRelated? = nil
    @State private var triggerSensor: Bool = false
    @State private var _related: TalkRelated? = nil
    @FocusState private var bindIsFocused: Bool
    
    var body: some View {
        let sceneType = _status.sceneType
        let idx = gtalk.indexOf(status: _status)
        let status = idx == nil ? _status : gtalk.statusForScene[sceneType]![idx!]
//        let searchId = status.searchId!
        let sendState = status.requestState
        let opacity = sendState != nil && sendState! == .sending ? 0.5 : 1.0

        VStack{
            HStack {
                TextField("话题", text: $query, prompt: Text("话题"))
                    .onChange(of: query) { text in
                        if query == "" {
                            searchMode = false
                        }
                    }
                    .font(.title2)
                    .cornerRadius(5)
                    .padding(.bottom, 8)
                    .onSubmit {
                        submit(searchId: windowId)
                    }

                Button {
                    submit(searchId: windowId)
                } label: {
                    Label("搜索", systemImage: "magnifyingglass").frame(width: 30, height: 20)
                        .labelStyle(.iconOnly).frame(width: 50)
                        .background(RoundedRectangle(cornerRadius: 5).fill(.red).opacity(0.85))
                        .foregroundColor(.white)
                        .font(.body.bold())
                }.padding(.bottom, 8).buttonStyle(PlainButtonStyle()).opacity(opacity)
            }
            .padding()
            .onAppear {
                gtalk.NSWindowStatus[windowId] = _status
            }
            .onDisappear {
                gtalk.NSWindowStatus[windowId] = nil
            }
            if searchMode {
                // Activated by focus in the search input box
                // Display the UI for search of tags
                if checkInfo != "" { Text(checkInfo) }
                SearchRersultsView(windowId: windowId, selectResult: $searchResult, switchTrigger: $triggerSensor, query: $query, searchMode: $searchMode, searchType: .topics)
                    .onChange(of: triggerSensor) { _ in
                        if let result = searchResult, result.type == .topics {
                            // Create a new TopicTimeline status
                            let topic = TalkRelated(id: result.id, type: .topics, title: result.title, desc: result.desc, cover: result.cover, banner: nil,contentString: nil)
                            gtalk.addStatusToCurrentScene(after: _status, statusType: .topicTimeline, title: topic.title!, icon: "tag.fill", targetTalk: nil, topic: topic)
                        }

                    }

//                if status.loadingLatest == .loading {
//                    ProgressView()
//                } else {
//                    // A view to display search results
//                    SearchRersultsView(searchId: uuid, selectResult: $searchResult, switchTrigger: $triggerSensor, query: $query, searchType: .topics)
//                        .onChange(of: triggerSensor) { _ in
//                            if let result = searchResult, result.type == .topics {
//                                // Create a new TopicTimeline status
//                                let topic = TalkRelated(id: result.id, type: .topics, title: result.title, desc: result.desc, cover: result.cover, banner: nil,contentString: nil)
//                                gtalk.addStatusToCurrentScene(after: _status, statusType: .topicTimeline, title: topic.title!, icon: "tag.fill", targetTalk: nil, topic: topic)
//                            }
//
//                        }
//                }
            }

            if !searchMode {
                HStack {
                    TopicCategoriesView(_status: status, windowId: nil)
                        .frame(width: 100)
                        .onAppear { gtalk.readTopicsCategories()}
                    topicsView(status: status, related: $_related)
                    Spacer()
                }
            }
        }
    }
    
    func submit(searchId: String) {
        if query.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            return
        }
        // Set to searchMode
        searchMode = true
        // gtalk.searchTopic
        gtalk.search(endponit: .topics, query: query, searchId: searchId, earlier: false, recommend: false)
    }
}

