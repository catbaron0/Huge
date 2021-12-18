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
                    .padding(.top, SIDEBAR_TOP_PADDING)
                    .background(BlurView().colorMultiply(.blue.opacity(0.3)))
                    .ignoresSafeArea()
                ZStack(alignment: .top){
                    GeometryReader { proxy in
                        ZStack {
                            ForEach(gtalk.talkScenes) { sceneType in
                                ScenesView(sceneType: sceneType.sceneType)
                                    .opacity(sceneType.sceneType == gtalk.selectedTalkSceneType ? 1 : 0)
                            }
                        }
                        .background(BlurView().colorMultiply(.blue.opacity(0.3)))
                        .ignoresSafeArea()
                    }
                    TitleBarView().ignoresSafeArea()
                        .background(BlurView().colorMultiply(.blue.opacity(0.3)))
                        .background(.ultraThinMaterial, in: Rectangle())
                        .padding(.top, CGFloat(TITILEBAR_PADDING))
                }
                .frame(width: 350)
                .frame(minHeight: 600)
            }
                .ignoresSafeArea()
        } else {
            LoginView()
        }
    }
}


