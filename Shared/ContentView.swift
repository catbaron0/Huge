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
                VStack{
                    TitleBarView().padding(.bottom, -8)
                    ScenesView()
                }
                .frame(width: AppSize.width.rawValue)
            }
        } else {
            LoginView()
        }
//        Text("content")
    }
}


