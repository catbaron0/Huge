//
//  SearchRersultsView.swift
//  GCoresTalk
//
//  Created by catbaron on 2021/12/10.
//

import SwiftUI

struct RelatedCardView: View {
    let searchResult: TalkRelated
    var body: some View {
        HStack {
            // Cover image if exists
            let size = CGFloat(60)
            if let cover = searchResult.cover {
                let image = TalkImage(src: cover, isSpoiler: false, width: 30, height: 30, downloadable: true)
                ImageReaderView(talkImage: image, largeSize: 30)
                //                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .background(.red)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                
            } else {
                //                RoundedRectangle(cornerRadius: 5)
                //                Image(systemName: "g.square.fill")
                HStack{
                    Text("G").font(.largeTitle.italic())
                        .foregroundColor(.white)
                    
                }
                .frame(width:size, height: size)
                .background(RoundedRectangle(cornerRadius: 5).fill(.red))
            }
            VStack(alignment: .leading) {
                // Title
                Text(searchResult.title!).font(.title3.bold())
                Spacer()
                // Desc if exists
                if let desc = searchResult.desc {
                    Text(desc).lineLimit(2).font(.body)
                }
                Spacer()
            }
            Spacer()
        }.contentShape(Rectangle())
    }
}

struct SearchRersultsView: View {
    let windowId: String
    @Binding var selectResult: TalkRelated?
    @Binding var switchTrigger: Bool
    @Binding var query: String
    @Binding var searchMode: Bool
    let searchType: GCoresRelatedType
    
    @EnvironmentObject var gtalk: GCoresTalk
    @State var scrollerOffset: CGPoint = .zero
    
    var body: some View {
        //        let sceneType = _status.sceneType
        //        let idx = gtalk.indexOf(status: _status)
        //        let status = (idx == nil) ? _status : gtalk.statusForScene[sceneType]![idx!]
        let status = gtalk.NSWindowStatus[windowId]!
        GeometryReader { proxy in
            VStack {
                List{// ForEach
                    LazyVStack{ // ForEach(cards)
                        // LazyVstack to avoid refresh of cards
                        ForEach(status.searchResults){ result in
                            // We need foreach to avoid reloading images everytime the talkcards appear
                            RelatedCardView(searchResult: result)
                                .padding([.top, .leading])
                                .onTapGesture {
                                    selectResult = result
                                    switchTrigger.toggle()
                                }
                        }
                        if status.requestEarlier == .empty {
                            Text("这就是一切了。").padding()
                        }
                    }.readingScrollView(from: "scroll", into: $scrollerOffset)
                }
                .frame(maxWidth: .infinity)
                .frame(height: proxy.size.height)
                .coordinateSpace(name: "scroll")
                .onChange(of: scrollerOffset) { offset in
                    print("More offset! \(proxy.size.height - scrollerOffset.y)")
                }
//                VStack { // LoadingBar
//                    let offset = proxy.size.height - scrollerOffset.y
//                    let earlyState = status.requestEarlier
//                    switch  gtalk.NSWindowStatus[windowId]!.requestEarlier {
//                    case .sending:
//                        ProgressView()
//                    case .succeed:
//                        Text("\(proxy.size.height - scrollerOffset.y)")
//                        if proxy.size.height - scrollerOffset.y > -300 && proxy.size.height - scrollerOffset.y < 0{
//                            Divider()
//                                .contentShape(Rectangle())
//                                .onAppear {
//                                    gtalk.search(endponit: searchType, query: query, searchId: windowId, earlier: true, recommend: !searchMode)
//                                }
//                            // You just try to match the last resut to the list to avoid double search
//                            // Check the length of the results
//                        }
//                    default:
//                        EmptyView()
//                    }
//                }.padding(.bottom)
            }
        }
        
        
        
    }
}
