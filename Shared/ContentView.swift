//
//  ContentView.swift
//  Shared
//
//  Created by catbaron on 2021/11/25.
//

import SwiftUI
import CoreData


struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var gtalk: GCoresTalk
    var body: some View {
        if gtalk.loginInfo.loginState == .succeed {
            
            HSplitView{
                NaviSideBarView()
                ZStack(alignment: .top){
                    GeometryReader { proxy in
                        ZStack {
                            ForEach(gtalk.talkScenes) { sceneType in
                                ScenesView(sceneType: sceneType.sceneType)
                                    .frame(height: proxy.size.height)
                                    .opacity(sceneType.sceneType == gtalk.selectedTalkSceneType ? 1 : 0)
                            }
                        }
                    }
                    TitleBarView()
                        .background(.ultraThinMaterial, in: Rectangle())
                        .padding(.top, CGFloat(TITILEBAR_PADDING))
                }
                .frame(width: 380)
                .frame(minHeight: 600)
            }
        } else {
            LoginView()
        }
    }
}


