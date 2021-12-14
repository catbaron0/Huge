//
//  ReadableScroller.swift
//  GCoresTalk
//
//  Created by catbaron on 2021/12/02.
//

import Foundation
import SwiftUI

struct ScrollViewOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
        value = nextValue()
    }
    
    typealias Value = CGPoint

}

struct ScrollViewOffsetModifier: ViewModifier {
    let coordinateSpace: String
    @Binding var offset: CGPoint
    
    func body(content: Content) -> some View {
        ZStack {
            content
            GeometryReader { proxy in
                let minY = proxy.frame(in: .named(coordinateSpace)).minY
                let maxY = proxy.frame(in: .named(coordinateSpace)).maxY
                Color.clear.preference(key: ScrollViewOffsetPreferenceKey.self, value: CGPoint(x: minY * 1, y: maxY * 1))
            }
        }
        .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
            offset = value
        }
    }
}

extension View {
    func readingScrollView(from coordinateSpace: String, into binding: Binding<CGPoint>) -> some View {
        modifier(ScrollViewOffsetModifier(coordinateSpace: coordinateSpace, offset: binding))
    }
}

// Sample usage:
struct ExampleView: View {
    let items = (0..<10).map({ $0 })
    
    @State var offset: CGPoint = .zero
    
    var body: some View {
        VStack {
            Text("Offset: \(offset.x)")
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(items, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .frame(width: 90, height: 90)
                            .foregroundColor(.blue)
                    }
                }
                .readingScrollView(from: "scroll", into: $offset)
            }
            .coordinateSpace(name: "scroll")
        }
    }
}
