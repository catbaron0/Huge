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
                HStack {
                    Label(status.title, systemImage: status.icon)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(Color(NSColor.windowFrameTextColor))
                        .padding(.bottom, 8)
                        .font(.title3)
                }
                if gtalk.statusForScene[gtalk.selectedTalkSceneType]!.count > 1 {
                    Button { gtalk.back()  } label: {
                        Label("后退", systemImage: "arrow.backward.circle.fill")
                            .labelStyle(.iconOnly)
                            .font(.title)
                            .foregroundColor(Color(NSColor.windowFrameTextColor))
                            .background(Color(NSColor.windowBackgroundColor))
                            .padding([.bottom], 8)
                            .padding(.leading, 15)
                    }.buttonStyle(.plain)
                    
                    
                }
                HStack {
                    Spacer()
                    Button {
                        let newStatus = ViewStatus(id: UUID().uuidString, sceneType: .newWindow, statusType: .newTalk, title: "新 Talk", icon: "pencil.and.outline")
//                        newStatus.topic = status.topic
                        newNSWindow(view: NewTalkView(status: newStatus, gtalk: gtalk, topic: status.topic))
                    } label: {
                        NewTalkButtonView()
                            .padding([.trailing,])
                            .foregroundColor(Color(NSColor.windowFrameTextColor))
                            .background(Color(NSColor.windowBackgroundColor))
                            .font(.title)
                            .padding(.bottom, 8)
                    }.buttonStyle(.plain)
                }
            }
            .padding(.top, -20)
            .frame(height: 20)
            .background(Color(NSColor.windowBackgroundColor))
        }
        else {
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
//            NewTalkButtonView()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .center) {
                    HStack {
                        if let src = gtalk.user?.profile.src {
                            AsyncImage(url: URL(string: src)!) { image in
                                image.resizable().scaledToFit()
                            } placeholder: {
                                ProgressView()
                            }
//                            ImageReaderView(url: src, width: 60, height: 60)
                        } else {
                            AsyncImage(url: URL(string: GCORES_DEFAULT_PROFILE_URL)!) { image in
                                image.resizable().scaledToFit()
                            } placeholder: {
                                ProgressView()
                            }
//                            ImageReaderView(url: GCORES_DEFAULT_PROFILE_URL, width: 60, height: 60)
                        }
                    }
                    .frame(width:50, height: 50)
                    .clipShape(Circle())
                    .padding(.bottom)
                    ForEach(gtalk.talkScenes) {item in
                        SidebarItemView(sidebarItem: item)
                    }
                }
                .padding(.top, 20)
                Spacer()
            }
        }.background(Color.init(red: 55/255, green: 55/255, blue: 55/255))
    }
}

struct SidebarItemView: View {
    @EnvironmentObject var gtalk: GCoresTalk
    let sidebarItem: TalkScene
    
    var body: some View {
        HStack {
            Label(
                "Timeline",
                systemImage: gtalk.isSelected(sidebarItem: sidebarItem) ? sidebarItem.selectedIcon: sidebarItem.unselectedIcon
            )
                .labelStyle(.iconOnly)
                .foregroundColor(gtalk.isSelected(sidebarItem: sidebarItem) ? .red : .white)
                .font(.largeTitle)
                .frame(width: 70, height: 45)
        }
        .onTapGesture {
            gtalk.select(sidebarItem: sidebarItem)
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
        .foregroundColor(.white)
        .background(RoundedRectangle(cornerRadius: 5).fill(Color(red: 1, green: 0, blue: 0, opacity: 0.6)))
    }
}

