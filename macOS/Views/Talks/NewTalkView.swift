//
//  NewTalkView.swift
//  GCoresTalk
//
//  Created by catbaron on 2021/12/10.
//

import SwiftUI
import UniformTypeIdentifiers

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
    //    let windowId: String
    //    let _status: ViewStatus
    @ObservedObject var status: ViewStatus
    @ObservedObject var gtalk: GCoresTalk
    
    @State  var topic: TalkRelated?
    @State  var talkText: String = ""
    @State  var checkInfo: String = ""
    @State  var relatedView: GCoresRelatedType = .topics
    //    @State  var images = [Image]()
    @State  var images = [NSImage]()
    @State  var related: TalkRelated? = nil
    @State  var query: String = ""
    @State  var searchMode = false
    @State  var triggerSensor: Bool = false
    @State  var searchResult: TalkRelated? = nil
    @State private var importImage: Bool = false
    
    var imageRow: [GridItem] = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        let sendState = status.requestState
        let opacity = (sendState != nil && sendState! == .sending) ? 0.5 : 1.0
        
        VStack {
            TextEditor(text: $talkText)
                .frame(minWidth: 300)
                .frame(height: 100)
                .padding([.leading, .trailing], 5)
                .font(.body)
                .ignoresSafeArea()
                .onPasteCommand(of: [.image, .url]) { providers in
                    for provider in providers {
                        if self.images.count < 9 {
                            if provider.registeredTypeIdentifiers.contains(UTType.image.identifier) {
                                provider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, error in
                                    print("load image")
                                }
                            }
                            if provider.registeredTypeIdentifiers.contains(UTType.url.identifier) {
                                provider.loadDataRepresentation(forTypeIdentifier: UTType.url.identifier) { data, error in
                                    print("load url")
                                }
                            }
                        }
                    }
                }
            
            Divider().padding()
            
            
            VStack {
                // send button
                HStack {
                    // Selected topic
                    HStack {
                        if relatedView == .topics {
                            if let topic = topic {
                                Label(topic.title ?? "nil", systemImage: "tag.fill")
                                    .foregroundColor(.red)
                                Spacer()
                            } else {
                                Label("话题", systemImage: "rectangle.dashed")
                                    .foregroundColor(.red)
                                    .onTapGesture {
                                        relatedView = .topics
                                    }
                            }
                        } else {
                            if let topic = topic {
                                Label(topic.title ?? "nil", systemImage: "tag.fill")
                                Spacer()
                            } else {
                                Label("话题", systemImage: "rectangle.dashed")
                                    .onTapGesture {
                                        relatedView = .topics
                                    }
                            }
                        }
                    }
                    .onTapGesture {
                        relatedView = .topics
                    }
                    Spacer()
                    
                    Button {
                        relatedView = .image
                    } label: {
                        NewTalkRelatedLabel(text: "图片", icon: "photo", highlight: !images.isEmpty)
                    }
                    .buttonStyle(.plain)
                    Button {
                        submit()
                    } label: {
                        Label("发送", systemImage: "paperplane.fill")
                            .labelStyle(.iconOnly)
                            .frame(width: 40, height: 30)
                            .background(RoundedRectangle(cornerRadius: CornerRadius).fill(.red))
                            .foregroundColor(.white)
                            .disabled(status.requestState != nil && status.requestState! == .sending)
                        
                    }.buttonStyle(PlainButtonStyle()).opacity(opacity)
                }.padding([.leading, .trailing], 10)
                
                // Related content
                if let related = related {
                    RelatedCardView(related: related)
                        .padding([.leading, .trailing])
                }
                
                Divider().padding()
                // Buttons of related contents
                HStack {
                    Button {
                        relatedView = .games
                    } label: {
                        NewTalkRelatedLabel( text: "游戏", icon: "gamecontroller", highlight: relatedView == .games)
                    }
                    .buttonStyle(.plain)
                    Spacer()
                    Button {
                        relatedView = .radios
                    } label: {
                        NewTalkRelatedLabel( text: "电台", icon: "antenna.radiowaves.left.and.right", highlight: relatedView == .radios )
                    }
                    .buttonStyle(.plain)
                    Spacer()
                    Button {
                        relatedView = .articles
                    } label: {
                        NewTalkRelatedLabel(text: "文章", icon: "square.text.square", highlight: relatedView == .articles )
                    }
                    .buttonStyle(.plain)
                    Spacer()
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
                        gtalk.search(status: status, endponit: relatedView, query: "", earlier: false, recommend: true)
                    }
                }
                .onChange(of: relatedView) { text in
                    searchMode = false
                    gtalk.search(status: status, endponit: relatedView, query: "", earlier: false, recommend: true)
                }
                
                
                // Search input box
                HStack {
                    TextField("搜索", text: $query, prompt: Text("搜索关联内容"))
                        .font(.title2)
                        .cornerRadius(SearchBoxCornerRadius)
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
                        Label("搜索", systemImage: "magnifyingglass")
                            .labelStyle(.iconOnly)
                            .frame(width: 40, height: 25)
                            .background(RoundedRectangle(cornerRadius: CornerRadius).fill(.red).opacity(0.85))
                            .foregroundColor(.white)
                            .font(.body.bold())
                        
                    }.padding(.bottom, 8).buttonStyle(PlainButtonStyle()).opacity(opacity)
                }.padding(.bottom, -5).padding([.leading, .trailing], 10)
                
                // Related search results
                if relatedView == .image {
                    // Images
                    VStack {
                        GeometryReader { proxy in
                            let size = (proxy.size.width - 15 ) / 3
                            ScrollView(showsIndicators: false) {
                                LazyVGrid(columns: imageRow, alignment: .leading, spacing: 10) {
                                    ForEach(0..<images.count, id: \.self) { idx in
                                        Image(nsImage: images[idx])
//                                    }
//                                    ForEach(images, id: \.absoluteString) { url in
//                                        ImageReaderView(url: url.absoluteString, width: Int(size), height: Int(size))
                                            .scaledToFill()
                                            .frame(width: size, height: size)
                                            .clipShape(RoundedRectangle(cornerRadius: CornerRadius))
                                            .overlay(alignment: .topTrailing) {
                                                // delete buton
                                                Label("", systemImage: "minus.circle").font(.title3)
                                                    .onTapGesture {
                                                        images.remove(at: idx)
                                                    }
                                            }
                                    }
                                    Button {
                                        importImage = true
                                    } label: {
                                        Label("添加图片", systemImage: "plus.viewfinder")
                                            .labelStyle(.iconOnly)
                                            .font(.largeTitle.bold())
                                            .frame(width:size, height: size).foregroundColor(.white)
                                            .background(RoundedRectangle(cornerRadius: CornerRadius).fill(.gray).opacity(0.6))
                                            .contentShape(Rectangle())
                                    }
                                    .buttonStyle(.plain)
                                    .fileImporter(isPresented: $importImage, allowedContentTypes: [.png, .jpeg], allowsMultipleSelection: true) { result in
                                        switch result {
                                        case .success(let urls):
                                            for url in urls {
                                                let img = NSImage(byReferencing: url)
                                                img.setName(url.absoluteString)
                                                images.append(img)
                                            }
//                                            images = urls.map { url in NSImage(byReferencing: url) }
                                        default:
                                            break
                                        }
                                    }
                                }
                            }
                        }
                        
                    }.padding([.leading, .trailing])
                    
                    //                }
                } else if !searchMode && relatedView == .topics {
                    // List of topics
                    HStack {
                        if status.topicCategories.isEmpty && !searchMode {
                            VStack{
                                Spacer()
                                ProgressView()
                                    .onAppear { gtalk.loadTopicsCategories(status: status)}
                                Spacer()
                            }
                        } else {
                            HStack {
                                TopicCategoriesView(status: status).environmentObject(gtalk)
                                    .frame(width: 100)
                                if status.requestState == .sending {
                                    Spacer()
                                    ProgressView()
                                } else {
                                    TopicsView(status: status, related: $topic, newStatus: false).environmentObject(gtalk)
                                }
                                
                                Spacer()
                            }
                            
                        }
                    }
                    .frame(minHeight: 500)
                    
                } else {
                    SearchRersultsView(status: status, selectResult: $searchResult, switchTrigger: $triggerSensor, query: $query, searchMode: $searchMode, searchType: relatedView).environmentObject(gtalk)
                        .frame(minHeight: 500)
                        .padding([.leading, .trailing])
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
        .preferredColorScheme(.dark)
        .background((BlurView().colorMultiply(.blue.opacity(0.3))))
    }
    
    func submitSearch() {
        if query.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            checkInfo = "内容不能为空！"
            return
        }
        // Set to searchMode
        searchMode = true
        // gtalk.searchTopic
        gtalk.search(status: status, endponit: relatedView, query: query, earlier: false, recommend: false)
    }
    
    func submit() {
        if talkText.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 && images.isEmpty{
            checkInfo = "内容不能为空！"
            return
        }
        checkInfo = ""
        if status.requestState != .sending {
            if let topic = topic {
                gtalk.newTalk(text: talkText, nsImages: images, topic: topic, related: related, status: status)
            }
            
        }
    }
}


