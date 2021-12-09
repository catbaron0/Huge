//
//  LoginView.swift
//  GCoresTalk
//
//  Created by catbaron on 2021/12/04.
//

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var gtalk: GCoresTalk
    
    @State var userName: String = ""
    @State var password: String = ""
    var body: some View {
        VStack {
            Label("GAMECORES", systemImage: "gamecontroller.fill")
                .font(.largeTitle.bold()).foregroundColor(.red)
            VStack(alignment: .trailing) {
                
                HStack {
                    Label("邮箱/用户名", systemImage: "envelope.circle.fill")
                    TextField(/*@START_MENU_TOKEN@*/"Placeholder"/*@END_MENU_TOKEN@*/, text: $userName).frame(width: 200)
//                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .border(.secondary)

                }
                HStack {
                    Label("密码", systemImage: "lock.circle.fill")
                    SecureField(/*@START_MENU_TOKEN@*/"Placeholder"/*@END_MENU_TOKEN@*/, text: $password).frame(width: 200)
                }
                Button {
                    gtalk.login(userName: userName, password: password)
                } label: {
                    Text("登录")
                }
            }
        }.frame(width: 500,height: 200).padding(.top, -20)
    }
    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
