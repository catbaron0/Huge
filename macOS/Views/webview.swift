//
//  webview.swift
//  GCoresTalk
//
//  Created by CatBaron on 2022/01/02.
//

import SwiftUI
import WebKit

struct webView: View {
    var body: some View {
        MyWebView(url: "https://www.apple.com")
            .padding()
            .frame(width: 480, height: 600)
    }
}

import SwiftUI
import WebKit

struct WebView: View {
    let url =  "https://www.apple.com"
    var body: some View {
        MyWebView(url: url)
    }
}

struct MyWebView: NSViewRepresentable {

    let url: String

    func makeNSView(context: Context) -> WKWebView {

        guard let url = URL(string: self.url) else {
            return WKWebView()
        }

        let webview = WKWebView()
        let request = URLRequest(url: url)
        webview.load(request)

        return webview
    }

    func updateNSView(_ nsView: WKWebView, context: Context) { }
}

struct webview_Previews: PreviewProvider {
    static var previews: some View {
        webView()
    }
}


