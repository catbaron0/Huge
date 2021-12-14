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
                    ScenesView()
                    TitleBarView()
                        .background(.ultraThinMaterial, in: Rectangle())
                        .padding(.top, -30)
                }
                .frame(minWidth: 200, idealWidth: 380, maxWidth: 380, minHeight: 600, idealHeight: 800, maxHeight: .infinity, alignment: .center)
            }
        } else {
            LoginView()
        }
    }
}


