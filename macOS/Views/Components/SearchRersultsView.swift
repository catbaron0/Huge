//
//  SearchRersultsView.swift
//  GCoresTalk
//
//  Created by catbaron on 2021/12/10.
//

import SwiftUI

struct RelatedCardView: View {
    let related: TalkRelated
    var body: some View {
        HStack {
            let size = CGFloat(70)
            if let cover = related.cover {
                AsyncImage(url: URL(string: cover+GCORES_IMAGE_SCALE_SETTING)!) { image in
                    image
                    .resizable()
                    .scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                    
                    .frame(width: size, height: size)
                    .background(.gray)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius))
                
            } else {
                HStack{
                    Text("G")
                        .font(.largeTitle.italic())
                        .foregroundColor(.white)
                }
                .frame(width:size, height: size)
                .background(RoundedRectangle(cornerRadius: CornerRadius).fill(.red))
            }
            VStack(alignment: .leading) {
                // Title
                HStack{
                    Text(related.title!).font(.title3.bold()).frame(alignment:.leading).lineLimit(2).multilineTextAlignment(.leading)
                }
                
                // Desc if exists
                if let desc = related.desc {
                    Text(desc).lineLimit(2).font(.body.italic()).multilineTextAlignment(.leading)
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
                ScrollView{// ForEach
                    LazyVStack { // ForEach(cards)
                        // LazyVstack to avoid refresh of cards
                        ForEach(status.searchResults){ result in
                            // We need foreach to avoid reloading images everytime the talkcards appear
                            RelatedCardView(related: result)
                                .onTapGesture {
                                    selectResult = result
                                    switchTrigger.toggle()
                                }
                        }
                        if status.requestEarlier == .empty {
                            Text("这就是一切了。").padding(.bottom, 20)
                        }
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
                                            gtalk.search(status: status, endponit: searchType, query: query , earlier: true, recommend: !searchMode)
                                        }
                                }
                            default:
                                EmptyView()
                            }
                        }.padding(.bottom)
                    }.readingScrollView(from: "scroll", into: $scrollerOffset)
                }

                .frame(maxWidth: .infinity)
                .frame(height: proxy.size.height)
                .coordinateSpace(name: "scroll")
            }
        }
    }
}
