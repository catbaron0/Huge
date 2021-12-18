//
//  NavigationBar.swift
//  GCoresTalk (macOS)
//
//  Created by catbaron on 2021/11/29.
//

import SwiftUI

enum LoadingBarPosition {
    case top
    case bottom
}

struct LoadingBarView: View {
    @EnvironmentObject var gtalk: GCoresTalk
    @State  var status: ViewStatus
    @State  var barPosition: LoadingBarPosition
    @Binding  var offset: CGPoint
    
    var  action: () -> Void
    
    var body: some View {
        VStack { // LoadingBar
            switch status.loadingEarlier {
            case .loading:
                ProgressView()
            case .empty:
                if barPosition == .bottom {
                    Text("没有更多了")
                }
            case .loaded:
                if barPosition == .top && offset.x > 10 {
                    Divider()
                        .contentShape(Rectangle())
                        .onTapGesture {
                            action()
                        }
                        .onAppear {
                            action()
                        }
                } else if barPosition == .top && offset.x > 10 {
                    HStack {
                        Spacer()
                        Label("点击加载更多", systemImage: "arrow.up.arrow.down")
                        Spacer()
                    }
                    .frame(height: 20)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        action()
                    }
                    .onAppear {
                        action()
                    }
                }
            }
        }
    }
}

struct TitleBarView: View {
    @EnvironmentObject var gtalk: GCoresTalk
    //    @State var status: TalkModelStatus
    var body: some View {
        // title and icon
        if let status = gtalk.statusForScene[gtalk.selectedTalkSceneType]?.last {
            ZStack(alignment: .leading) {
                HStack{
                    Spacer()
                    Label(status.title, systemImage: status.icon)
                        .font(.title3)
                        .padding(.top, 3)
                        .padding()
                    Spacer()
                }
                HStack {
                    if gtalk.statusForScene[gtalk.selectedTalkSceneType]!.count > 1 {
                        Button { gtalk.back()  } label: {
                            Label("后退", systemImage: "arrow.backward.circle.fill")
                                .labelStyle(.iconOnly)
                                .font(.title)
//                                .foregroundColor(Color(NSColor.windowFrameTextColor))
                                .padding(.leading, 12)
                                .padding(.top, 3)
                        }.buttonStyle(.plain)
                    }
                    Spacer()
                    Button {
                        let newStatus = ViewStatus(id: UUID().uuidString, sceneType: .newWindow, statusType: .newTalk, title: "新 Talk", icon: "pencil.and.outline")
                        newNSWindow(view: NewTalkView(status: newStatus, gtalk: gtalk, topic: status.topic))
                    } label: {
                        NewTalkButtonView()
                            .padding(.top, 3)
                            .padding(.trailing)
//                            .foregroundColor(Color(NSColor.windowFrameTextColor))
                            .font(.title)
                    }.buttonStyle(.plain)
                    
                }
                .frame(height: CGFloat(TITILEBAR_HEIGHT))
            }
//            .foregroundColor(Color(NSColor.windowFrameTextColor))

        } else {
            EmptyView()
        }
    }
}


struct NewTalkButtonView: View {
    @EnvironmentObject var gtalk: GCoresTalk
    
    var body: some View {
        Label("推!", systemImage: "pencil.and.outline")
            .labelStyle(.iconOnly)
    }
}

struct NaviSideBarView: View {
    @EnvironmentObject var gtalk: GCoresTalk
    
    var body: some View {
        VStack{
            ScrollView(showsIndicators: false) {
                VStack(alignment: .center) {
                    HStack {
                        if let src = gtalk.user?.profile.src {
                            AsyncImage(url: URL(string: src)!) { image in
                                image.resizable().scaledToFit()
                            } placeholder: {
                                ProgressView()
                            }
                        } else {
                            AsyncImage(url: URL(string: GCORES_DEFAULT_PROFILE_URL)!) { image in
                                image.resizable().scaledToFit()
                            } placeholder: {
                                ProgressView()
                            }
                        }
                    }
                    .frame(width:50, height: 50)
                    .clipShape(Circle())
                    .padding(.top, SIDEBAR_TOP_PADDING)
                    ForEach(gtalk.talkScenes) {item in
                        SidebarItemView(sidebarItem: item)
                    }
                }
                .padding(.top, 20)
                Spacer()
            }
        }
    }
}

struct SidebarItemView: View {
    @EnvironmentObject var gtalk: GCoresTalk
    let sidebarItem: TalkScene
    
    var body: some View {
        HStack {
            Label(
                "",
                systemImage:sidebarItem.icon
            )
                .labelStyle(.iconOnly)
                .foregroundColor(gtalk.isSelected(sidebarItem: sidebarItem) ? .red : Color(NSColor.windowFrameTextColor))
                .font(.largeTitle)
                .frame(width: 70, height: 45)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if sidebarItem.sceneType == gtalk.selectedTalkSceneType {
                // return to the root view
                if gtalk.statusForScene[sidebarItem.sceneType]!.count > 1 {
                    while gtalk.statusForScene[sidebarItem.sceneType]!.count > 1 {
                        gtalk.back()
                    }
                } else {
                    // clear the unread notification
                    // read unread message
                    let status = gtalk.statusForScene[sidebarItem.sceneType]![0]
                    switch status.statusType {
                    case .notification:
                        gtalk.loadNotifications(status: status, earlier: false)
                        // send mark-seen
                        gtalk.markNotificationsAsSeen(status: status)
                    case .followeeTimeline, .recommendTimeline, .topicTimeline, .userTimeline:
                        gtalk.loadTimeline(status: status, earlier: false)
                    case .topics:
                        gtalk.loadTopicsCategories(status: status)
                    default:
                        break
                    }

                }
            } else {
                print("switch item")
                gtalk.select(sidebarItem: sidebarItem)
            }
            
        }
    }
}

struct HeaderView: View {
    let desc: String
    
    var body: some View {
        VStack {
            HStack {
                Text("简介:").font(.title2).padding(.leading).padding(.top)
                Spacer()
            }
            HStack {
                Text(desc).padding(.bottom).padding(.leading)
                Spacer()
            }
        }
//        .foregroundColor(.white)
        .background(RoundedRectangle(cornerRadius: CornerRadius).fill(Color(red: 1, green: 0, blue: 0, opacity: 0.6)))
    }
}

