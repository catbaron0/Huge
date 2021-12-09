////
////  StatusTagsView.swift
////  GCoresTalk
////
////  Created by catbaron on 2021/12/03.
////
//
import SwiftUI
//
struct TagCategoryCardView: View {
    // The card view shown in the sidebar of tagsview
    let tagCategory: TalkTagCategory

    var body: some View {
        HStack{
            Spacer()
            Text(tagCategory.name)
            Spacer()
        }
        .padding(.top)
        .padding(.bottom)
        .frame(maxHeight: .infinity)
        .contentShape(Rectangle())
    }
}

struct TagCategoriesView: View {
    let _status: TalkStatus
    @State private var offset: CGPoint = .zero
    @EnvironmentObject var gtalk: GCoresTalk

    var body: some View {
//        let sceneType = _status.sceneType
//        if let idx = gtalk.indexOf(status: _status) {
//        let status = gtalk.statusForScene[sceneType]![idx]
        ScrollView(showsIndicators: false) {
            VStack {
                ForEach(gtalk.tagCategories) { category in
                    Group {
                        if category == gtalk.selectedTagCategory {
                            TagCategoryCardView(tagCategory: category)
                                .background(Rectangle().fill(.red).opacity(0.8))
                                .font(.body.bold())
                        } else {
                            TagCategoryCardView(tagCategory: category)
                        }

                    }
                        .onTapGesture{
                            gtalk.select(tagCategory: category)
                            withAnimation {
                                gtalk.readTags(categoryId: category.id)
                            }
                        }
                }
                Spacer()
            }
        }
    }
}


struct TagCardView: View {
    let tag: TalkTag

    var body: some View {
        HStack{
            Text(tag.title)
            Spacer()
        }
        .padding(.top)
        .padding(.leading)
        .contentShape(Rectangle())
    }
}

struct TagsView: View {
    @State var status: TalkStatus
    @EnvironmentObject var gtalk: GCoresTalk

    var body: some View {
        ScrollView {
            VStack {
                ForEach(gtalk.selectedTags) { tag in
                    TagCardView(tag: tag)
                        .onTapGesture {
                            gtalk.addStatusToCurrentScene(after: status, statusType: .tagTimeline, title: tag.title, icon: "tag.fill", targetTalk: nil, tag: tag)
                        }
                }
                Spacer()
            }
        }
    }
}

struct StatusTagsView: View {
    @State var _status: TalkStatus
    @EnvironmentObject var gtalk: GCoresTalk

    @State private var sending = false
    @State private var checkInfo: String = ""
    @State private var searchText: String = ""
    @FocusState private var searchMode: Bool
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
                    .focused($searchMode)
                    .padding(.bottom, 8)
                    .lineSpacing(20)
                    

                Button {
                    if searchText.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
                        checkInfo = "评论不能为空！"
                        return
                    } else {
                        checkInfo = ""
                    }
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
                    TagCategoriesView(_status: status)
                        .frame(width: 100)
                        .onAppear { gtalk.readTagsCategories()}
                    TagsView(status: status)
                    Spacer()
                }
            }
        }
    }
}

//struct StatusTagsView: View {
//    @State var status: TalkStatus
//    @EnvironmentObject var gtalk: GCoresTalk
//    var body: some View {
//        Text("test")
//    }
//}
