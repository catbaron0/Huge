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
//                let image = TalkImage(src: cover, isSpoiler: false, width: 30, height: 30, downloadable: true)
//                ImageReaderView(talkImage: image, largeSize: 30, forceLoad: true)
                AsyncImage(url: URL(string: cover+GCORES_IMAGE_SCALE_SETTING)!) { image in
                    image
                    .resizable()
                    .scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                    
                    .frame(width: size, height: size)
                    .background(.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                
            } else {
                HStack{
                    Text("G")
                        .font(.largeTitle.italic())
                        .foregroundColor(.white)
                }
                .frame(width:size, height: size)
                .background(RoundedRectangle(cornerRadius: 5).fill(.red))
            }
            VStack(alignment: .leading) {
                // Title
                Text(searchResult.title!).font(.title3.bold()).lineLimit(2)
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
    //    let windowId: String
    @StateObject var status: ViewStatus
    @Binding var selectResult: TalkRelated?
    @Binding var switchTrigger: Bool
    @Binding var query: String
    @Binding var searchMode: Bool
    let searchType: GCoresRelatedType
    
    @EnvironmentObject var gtalk: GCoresTalk
    @State var scrollerOffset: CGPoint = .zero
    
    var body: some View {

        GeometryReader { proxy in
            VStack {
                List{// ForEach
                    LazyVStack{ // ForEach(cards)
                        // LazyVstack to avoid refresh of cards
                        ForEach(status.searchResults){ result in
                            // We need foreach to avoid reloading images everytime the talkcards appear
                            RelatedCardView(searchResult: result)
//                                .padding([.top, .leading])
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
                
                .overlay(alignment: .bottom) {
                    VStack { // LoadingBar
                        
                        switch  status.requestEarlier {
                        case .sending:
                            VStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                            
                        case .succeed:
                            if proxy.size.height - scrollerOffset.y > -260 && proxy.size.height - scrollerOffset.y < 0{
                                Divider()
                                    .contentShape(Rectangle())
                                    .onAppear {
                                        print("More offset! \(proxy.size.height - scrollerOffset.y)")
                                        gtalk.search(status: status, endponit: searchType, query: query , earlier: true, recommend: !searchMode)
                                    }
                            }
                        default:
                            EmptyView()
                        }
                    }.padding(.bottom)
                }
                
            }
        }
    }
}