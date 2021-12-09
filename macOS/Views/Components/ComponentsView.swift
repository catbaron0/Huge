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
//
//struct TopLoadingBarView: View {
//    @EnvironmentObject var gtalk: GCoresTalk
//    let status: TalkModelStatus
//    @State var triggerLoading: Bool
//    let action: (_ earlier: Bool) -> Void
//
//    var body: some View {
//        VStack { // LoadingBar
//            switch status.loadingLatest {
//            case .loading:
//                ProgressView()
//            default:
//                if triggerLoading {
//                    HStack {
//                        Spacer()
//                        Label("点击加载更多", systemImage: "arrow.up.arrow.down")
//                        Spacer()
//                    }
//                    .contentShape(Rectangle())
//                    .onTapGesture {
//                        action(false)
////                        gtalk.getComments(for: status.selectedCard!.id, fromStart: )
//                    }
//                    .onAppear {
//                        action(false)
////                        gtalk.getComments(for: status.selectedCard!.id, fromStart: true)
//                    }
//                }
//            }
//        }
//    }
//}

struct LoadingBarView: View {
    @EnvironmentObject var gtalk: GCoresTalk
    @State  var status: TalkStatus
    @State  var barPosition: LoadingBarPosition
    @Binding  var offset: CGPoint
//    @Binding var height: CGFloat
//    @State var triggerLoading: Bool
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
                }
                if gtalk.statusForScene[gtalk.selectedTalkSceneType]!.count > 1 {
                    Label("后退", systemImage: "arrow.backward.circle.fill")
                        .foregroundColor(Color(NSColor.windowFrameTextColor))
                        .background(Color(NSColor.windowBackgroundColor))
                        .padding(.leading)
                        .onTapGesture {
//                            withAnimation(.linear){
                                gtalk.back()
//                            }
                        }
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
        Label("推!", systemImage: "square.and.pencil")
            .labelStyle(.iconOnly)
            .font(.title)
            .padding(.top, 10)
            .padding(.bottom, 5)
    }
}

struct NaviSideBarView: View {
    @EnvironmentObject var gtalk: GCoresTalk
//    @Binding var sidebarItem: SidebarItemTag
    
    var body: some View {
        VStack{
            NewTalkButtonView()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .center) {
                    ForEach(gtalk.talkScenes) {item in
                        SidebarItemView(sidebarItem: item)
                    }
                }
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
//        Divider().frame(width: 70, height: 0)
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
//        .background(RoundedRectangle(cornerRadius: 5).fill(Color(hue: 1.0, saturation: 0.268, brightness: 0.435)))
    }
}

