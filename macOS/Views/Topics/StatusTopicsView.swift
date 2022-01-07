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
    @StateObject var status: ViewStatus
    @State private var offset: CGPoint = .zero
    @EnvironmentObject var gtalk: GCoresTalk
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                ForEach(status.topicCategories) { category in
                    Group {
                        if category == status.selectedTopicCategory {
                            TopicCategoryCardView(topicCategory: category)
                                .background(Rectangle().fill(.red).opacity(0.8))
                                .font(.body.bold())
                        } else {
                            TopicCategoryCardView(topicCategory: category)
                        }

                    }
                        .onTapGesture{
                            status.selectedTopicCategory = category
                            withAnimation {
                                gtalk.loadTopics(status: status, categoryId: category.id)
                            }
                        }
                }
                Spacer()
            }
            .onAppear {
                if status.selectedTopicCategory == nil {
                    status.selectedTopicCategory = status.topicCategories[0]
                    gtalk.loadTopics(status: status, categoryId: status.topicCategories[0].id)
                }
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
        .padding(.top, 5)
        .padding(.bottom, 5)
        .padding(.leading)
        .contentShape(Rectangle())
        .border(width: topic.subscriptionId == nil ? 0 : 2, edges: [.leading], color: .yellow)
    }
}

struct TopicsView: View {
    @StateObject var status: ViewStatus
    @EnvironmentObject var gtalk: GCoresTalk
    @Binding var related: TalkRelated?
    let newStatus: Bool
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                ForEach(status.topics) { topic in
                    TopicCardView(topic: topic)
                        .onTapGesture {
                            related = TalkRelated(id: topic.id, type: .topics, title: topic.title, desc: nil, cover: nil, banner: nil, contentString: nil)
                            if newStatus {
                                gtalk.addStatusToCurrentScene(after: status, statusType: .topicTimeline, title: topic.title!, icon: "", topic: topic)
                            }
                        }
                        .contextMenu {
                            if let _ = topic.subscriptionId {
                                Button {
                                    gtalk.unsubscribe(status: status, targetId: topic.id, targetType: .topics, updateSubscriptionId: gtalk.updateSubscriptionId)
                                } label: {
                                    Text("取消收藏")
                                }
                            } else {
                                Button {
                                    gtalk.subscribe(status: status, targetId: topic.id, targetType: .topics, updateSubscriptionId: gtalk.updateSubscriptionId)
                                } label: {
                                    Text("收藏")
                                }
                            }
                            
                        }
                }
                Spacer()
            }
        }
    }
}

struct StatusTopicsView: View {
    @StateObject var status: ViewStatus
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
        let sendState = status.requestState
        let opacity = sendState != nil && sendState! == .sending ? 0.5 : 1.0
        VStack{
            Spacer().frame(height: TimelineTopPadding.titleBar.rawValue + 20)
            if gtalk.selectedTalkSceneType == status.sceneType {
                HStack {
                    TextField("话题", text: $query, prompt: Text("搜索话题"))
                        .cornerRadius(SearchBoxCornerRadius)
                        .onChange(of: query) { text in 
                            if query == "" {
                                searchMode = false
                            }
                        }
                        .font(.title2)
                        .padding(.bottom, 8)
                        .onSubmit {
                            submit()
                        }

                    Button {
                        submit()
                    } label: {
                        Label("搜索", systemImage: "magnifyingglass")
//                            .padding(5)
                            .labelStyle(.iconOnly)
                            .frame(width: 40, height: 25)
                            .background(RoundedRectangle(cornerRadius: CornerRadius.normal.rawValue).fill(.red).opacity(0.85))
                            .foregroundColor(.white)
                            .font(.body.bold())
                    }.padding(.bottom, 8).buttonStyle(.plain).opacity(opacity)
                }
                .padding([.leading, .trailing])
            }

            if searchMode {
                // Activated by focus in the search input box
                // Display the UI for search of tags
                if checkInfo != "" { Text(checkInfo) }
                SearchRersultsView(status: status, selectResult: $searchResult, switchTrigger: $triggerSensor, query: $query, searchMode: $searchMode, searchType: .topics)
                    .onChange(of: triggerSensor) { _ in
                        if let result = searchResult, result.type == .topics {
                            // Create a new TopicTimeline status
                            let topic = TalkRelated(id: result.id, type: .topics, title: result.title, desc: result.desc, cover: result.cover, banner: nil,contentString: nil)
                            gtalk.addStatusToCurrentScene(after: status, statusType: .topicTimeline, title: topic.title!, icon: "tag.fill", topic: topic)
                        }

                    }
            } else {
                
                if status.topicCategories.isEmpty {
                    VStack{
                        Spacer()
                        ProgressView()
                            .onAppear { gtalk.loadTopicsCategories(status: status)}
                        Spacer()
                    }
                } else {
                    HStack {
                        TopicCategoriesView(status: status)
                            .frame(width: 100)
//                            .onAppear {
//                                if status.selectedTopicCategory == nil {
//                                    status.selectedTopicCategory = status.topicCategories[0]
//                                    gtalk.loadTopics(status: status, categoryId: status.topicCategories[0].id)
//                                }
//                            }
                        if status.requestState == .sending {
                            Spacer()
                            ProgressView()
                        } else {
                            TopicsView(status: status, related: $_related, newStatus: true)
                        }
                        
                        Spacer()
                    }

                }
            }
        }
    }
    
    func submit() {
        if query.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            return
        }
        // Set to searchMode
        searchMode = true
        // gtalk.searchTopic
        gtalk.search(status: status, endponit: .topics, query: query, earlier: false, recommend: false)
    }
}

