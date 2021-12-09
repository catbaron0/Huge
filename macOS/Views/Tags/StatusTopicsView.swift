////
////  StatusTagsView.swift
////  GCoresTalk
////
////  Created by catbaron on 2021/12/03.
////
//
import SwiftUI
//
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
    let _status: TalkStatus
    @State private var offset: CGPoint = .zero
    @EnvironmentObject var gtalk: GCoresTalk

    var body: some View {
//        let sceneType = _status.sceneType
//        if let idx = gtalk.indexOf(status: _status) {
//        let status = gtalk.statusForScene[sceneType]![idx]
        ScrollView(showsIndicators: false) {
            VStack {
                ForEach(gtalk.topicCategories) { category in
                    Group {
                        if category == gtalk.selectedTopicCategory {
                            TopicCategoryCardView(topicCategory: category)
                                .background(Rectangle().fill(.red).opacity(0.8))
                                .font(.body.bold())
                        } else {
                            TopicCategoryCardView(topicCategory: category)
                        }

                    }
                        .onTapGesture{
                            gtalk.select(topicCategory: category)
                            withAnimation {
                                gtalk.readTopics(categoryId: category.id)
                            }
                        }
                }
                Spacer()
            }
        }
    }
}


struct TopicCardView: View {
    let topic: Topic

    var body: some View {
        HStack{
            Text(topic.title)
            Spacer()
        }
        .padding(.top)
        .padding(.leading)
        .contentShape(Rectangle())
    }
}

struct topicsView: View {
    @State var status: TalkStatus
    @EnvironmentObject var gtalk: GCoresTalk

    var body: some View {
        ScrollView {
            VStack {
                ForEach(gtalk.selectedTopics) { topic in
                    TopicCardView(topic: topic)
                        .onTapGesture {
                            gtalk.addStatusToCurrentScene(after: status, statusType: .topicTimeline, title: topic.title, icon: "tag.fill", targetTalk: nil, topic: topic)
                        }
                }
                Spacer()
            }
        }
    }
}

struct StatusTopicsView: View {
    @State var _status: TalkStatus
    @EnvironmentObject var gtalk: GCoresTalk

    @State private var sending = false
    @State private var checkInfo: String = ""
    @State private var searchText: String = ""
    @State private var searchMode: Bool = false
    @FocusState private var focused: Bool
//    @FocusState private var foncusOnSearchInput: Bool
    let uuid = UUID().uuidString
    var body: some View {
        let sceneType = _status.sceneType
        let idx = gtalk.indexOf(status: _status)
        let status = idx == nil ? _status : gtalk.statusForScene[sceneType]![idx!]

        let sendState = gtalk.requestStates[uuid]
        let opacity = sendState != nil && sendState! == .sending ? 0.5 : 1.0

        VStack{
            HStack {
                TextField("title", text: $searchText, prompt: Text("prompt"))
                    .font(.title2)
                    .cornerRadius(16)
                    .focused($focused)
                    .padding(.bottom, 8)
                    .lineSpacing(20)
                    

                Button {
                    
//                    if sendState == nil || sendState! == .failed {
//                        gtalk.sendComment(talkId: targetTalkId, commentId: targetCommentId, _status: _status, comment: comment, uuid: uuid)
//                    }
                } label: {
                    Label("搜索", systemImage: "magnifyingglass").frame(height: 30)
                        .labelStyle(.iconOnly).frame(width: 50)
                        .background(RoundedRectangle(cornerRadius: 5).fill(.blue))

                }.padding(.trailing, 8).padding(.bottom, 8).buttonStyle(PlainButtonStyle()).opacity(opacity)
            }.padding()
            if searchMode {
                // Activated by focus in the search input box
                // Display the UI for search of tags
                if checkInfo != "" { Text(checkInfo) }
                if let hotResearch = status.resentHotSearch {
                    VStack{
                        ForEach(hotResearch, id: \.self) { text in
                            Text(text)
                        }

                    }
                }
            }

            else {
                HStack {
                    TopicCategoriesView(_status: status)
                        .frame(width: 100)
                        .onAppear { gtalk.readTopicsCategories()}
                    topicsView(status: status)
                    Spacer()
                }
            }
        }
    }
    
    func submit() {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            return
        }
        // gtalk.searchTopic
    }
}

//struct StatusTagsView: View {
//    @State var status: TalkStatus
//    @EnvironmentObject var gtalk: GCoresTalk
//    var body: some View {
//        Text("test")
//    }
//}
