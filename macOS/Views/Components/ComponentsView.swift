//
//  NavigationBar.swift
//  GCoresTalk (macOS)
//
//  Created by catbaron on 2021/11/29.
//

import SwiftUI
import WebKit


struct NicknameView: View {
    @StateObject var status: ViewStatus
    let user: TalkUser
    @EnvironmentObject var gtalk: GCoresTalk
    
    var body: some View {
        Text(user.nickname).font(.title3)
            .onTapGesture {
                gtalk.addStatusToCurrentScene(after: status, statusType: .profile, title: user.nickname, icon: "person.fill", userId: user.id)
            }
    }
}


enum LoadingBarPosition {
    case top
    case bottom
}

//struct LoadingBarView: View {
//    @EnvironmentObject var gtalk: GCoresTalk
//    @State  var status: ViewStatus
//    @State  var barPosition: LoadingBarPosition
//    @Binding  var offset: CGPoint
//
//    var  action: () -> Void
//
//    var body: some View {
//        VStack { // LoadingBar
//            switch status.loadingEarlier {
//            case .loading:
//                ProgressView()
//            case .empty:
//                if barPosition == .bottom {
//                    Text("没有更多了")
//                }
//            case .loaded:
//                if barPosition == .top && offset.x > 10 {
//                    Divider()
//                        .contentShape(Rectangle())
//                        .onTapGesture {
//                            action()
//                        }
//                        .onAppear {
//                            action()
//                        }
//                } else if barPosition == .top && offset.x > 10 {
//                    HStack {
//                        Spacer()
//                        Label("点击加载更多", systemImage: "arrow.up.arrow.down")
//                        Spacer()
//                    }
//                    .frame(height: 20)
//                    .contentShape(Rectangle())
//                    .onTapGesture {
//                        action()
//                    }
//                    .onAppear {
//                        action()
//                    }
//                }
//            }
//        }
//    }
//}

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
                        .labelStyle(.titleOnly)
                        .font(.title3.bold())
                        .padding(.top, 3)
                        .padding(8)
//                        .onTapGesture {
//                            let webConfiguration = WKWebViewConfiguration()
//                            var webView = WKWebView(frame: .zero, configuration: webConfiguration)
//                            webView.uiDelegate = self
//                        }
                    Spacer()
                }
                HStack {
                    if gtalk.statusForScene[gtalk.selectedTalkSceneType]!.count > 1 {
                        Button { gtalk.back()  } label: {
                            Label("后退", systemImage: "arrow.backward")
                                .labelStyle(.iconOnly)
                                .font(.title3.bold())
//                                .foregroundColor(Color(NSColor.windowFrameTextColor))
                                .padding(.leading, 12)
                        }.buttonStyle(.plain)
                    }
                    Spacer()
                    Button {
                        let newStatus = ViewStatus(id: UUID().uuidString, sceneType: .newWindow, statusType: .newTalk, title: "新 Talk", icon: "pencil.and.outline")
                        newNSWindow(view: NewTalkView(status: newStatus, gtalk: gtalk, topic: status.targetTopic))
                    } label: {
                        NewTalkButtonView()
                            .font(.title3.bold())
                            .foregroundColor(.red)
                    }
                    .padding(.trailing, 12)
                    .buttonStyle(.plain)
                    
                }
                .frame(height: CGFloat(TITILEBAR_HEIGHT))
            }
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
                    .padding(.bottom, 10)
                    ForEach(gtalk.talkScenes) {item in
                        SidebarItemView(sidebarItem: item)
                    }
                }.padding(.top, SIDEBAR_TOP_PADDING)
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
                        NSApp.dockTile.badgeLabel = ""
                        NSApp.dockTile.display()
                    case .followeeTimeline, .recommendTimeline, .topicTimeline, .userTimeline:
                        gtalk.loadTimeline(status: status, earlier: false)
                    case .topics:
                        gtalk.loadTopicsCategories(status: status)
                    case .profile:
                        gtalk.loadTalks(status: status, endpoint: .user)
                    default:
                        break
                    }

                }
            } else {
                print("switch item")
                gtalk.select(sidebarItem: sidebarItem)
                let status = gtalk.statusForScene[sidebarItem.sceneType]![0]
                switch status.statusType {
                case .notification:
                    // Update notifications evert time switch to this view
                    gtalk.loadNotifications(status: status, earlier: false)
                    gtalk.markNotificationsAsSeen(status: status)
                default:
                    break
                }

            }
            
        }
    }
}

struct TopicDescView: View {
    @StateObject var status: ViewStatus
    @EnvironmentObject var gtalk: GCoresTalk
    
    var body: some View {
        
        VStack {
            HStack {
                Text("简介:").font(.title2).padding(.leading).padding(.top)
                Spacer()
                Group {
                    if let _ = status.targetTopic?.subscriptionId {
                        Label("subscribe", systemImage: "star.fill")
                            .onTapGesture {
                                gtalk.unsubscribe(status: status, targetId: status.targetTopic!.id, targetType: .topics, updateSubscriptionId: gtalk.updateSubscriptionId)
                            }
                    } else {
                        Label("subscribe", systemImage: "star")
                            .onTapGesture {
                                gtalk.subscribe(status: status, targetId: status.targetTopic!.id, targetType: .topics, updateSubscriptionId: gtalk.updateSubscriptionId)
                            }
                    }
                }
                .foregroundColor(.yellow)
                .labelStyle(.iconOnly)
                .font(.title2)
                .padding(.trailing)
            }
            if let topic = status.targetTopic, let desc = topic.desc, desc.trimmingCharacters(in: .whitespacesAndNewlines) != ""  {
                HStack {
                    Text(desc).padding(.bottom).padding(.leading)
                    Spacer()
                }
            }
        }
        .background(RoundedRectangle(cornerRadius: CornerRadius.normal.rawValue).fill(.red.opacity(0.6)))
    }
}

struct UserDescView: View {
    @StateObject var status: ViewStatus
    
    var body: some View {
        if let intro = status.user?.intro, intro.trimmingCharacters(in: .whitespacesAndNewlines) != ""  {
            VStack {
                HStack {
                    Text("简介:").font(.title2).padding(.leading).padding(.top)
                    Spacer()
                }
                HStack {
                    Text(intro).padding(.bottom).padding(.leading)
                    Spacer()
                }
            }
            .background(RoundedRectangle(cornerRadius: CornerRadius.normal.rawValue).fill(.red.opacity(0.6)))
        } else {
            EmptyView()
        }
    }
}

struct HeaderView: View {
    @StateObject var status: ViewStatus
    let headerType: GCoresRelatedType
    
    var body: some View {
        if headerType == .topics {
            TopicDescView(status: status)
        } else if headerType == .users {
            UserDescView(status: status)
        }
        else {
            EmptyView()
        }
    }
}


struct EdgeBorder: Shape {

    var width: CGFloat
    var edges: [Edge]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        for edge in edges {
            var x: CGFloat {
                switch edge {
                case .top, .bottom, .leading: return rect.minX
                case .trailing: return rect.maxX - width
                }
            }

            var y: CGFloat {
                switch edge {
                case .top, .leading, .trailing: return rect.minY
                case .bottom: return rect.maxY - width
                }
            }

            var w: CGFloat {
                switch edge {
                case .top, .bottom: return rect.width
                case .leading, .trailing: return self.width
                }
            }

            var h: CGFloat {
                switch edge {
                case .top, .bottom: return self.width
                case .leading, .trailing: return rect.height
                }
            }
            path.addPath(Path(CGRect(x: x, y: y, width: w, height: h)))
        }
        return path
    }
}

//struct TextEditorView: NSViewRepresentable {
//    
//    typealias NSViewType = NSTextView
//    var configuration = { (view: NSViewType) in }
//    
//    func makeNSView(context: NSViewRepresentableContext<Self>) -> NSViewType {
//        NSViewType()
//    }
//    
//    func updateNSView(_ nsView: NSViewType, context: NSViewRepresentableContext<Self>) {
//        configuration(nsView)
//    }
//}
