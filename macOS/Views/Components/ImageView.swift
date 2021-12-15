//
//  ImageView.swift
//  GCoresTalk (macOS)
//
//  Created by catbaron on 2021/11/29.
//

import SwiftUI


struct ImageReaderView: View {

    @ObservedObject var imageReader: ImageReader
    private var width: Int
    private var height: Int
    private var largeSize: Int?

    init(url: String, width: Int, height: Int, forceLoad: Bool = false) {
        self._imageReader = ObservedObject(wrappedValue: ImageReader(url: url, forceLoad: forceLoad))
        self.width = width
        self.height = height
        imageReader.fetch(downLoad: false)
    }

    
    init(talkImage: TalkImage, forceLoad: Bool = false) {
        self._imageReader = ObservedObject(wrappedValue: ImageReader(url: talkImage.src, forceLoad: forceLoad))
        self.width = talkImage.width
        self.height = talkImage.height
        imageReader.fetch(downLoad: false)
    }
    
    init(talkImage: TalkImage, largeSize: Int, forceLoad: Bool = false) {
        self._imageReader = ObservedObject(wrappedValue: ImageReader(url: talkImage.src, forceLoad: forceLoad))
        self.width = talkImage.width
        self.height = talkImage.height
        self.largeSize = largeSize
        imageReader.fetch(downLoad: false)
    }
    
    var body: some View {
            HStack {
                if let image = imageReader.image {
                    if let _ = largeSize {
                        Image(nsImage: image)
                            .resizable()
                            
                    } else {
                        Image(nsImage: image)
                            .resizable()
//                            .scaledToFill()
//                            .aspectRatio(contentMode: .fit)
//                            .clipShape(RoundedRectangle(cornerRadius: CornerRadius))
//                            .frame(maxWidth:300, maxHeight: 300)

                    }
                }
                else {
                    if let largeSize = largeSize {
                        if width > height {
                            let frameWidth = Float(largeSize)
                            let frameHeight = Float(frameWidth) / Float(width) * Float(height)
                            Rectangle()
                                .background(Color.red)
                                .frame(width: CGFloat(frameWidth), height: CGFloat(frameHeight))
                                .opacity(0.5)
                        } else {
                            let frameHeight = Float(largeSize)
                            let frameWidth = Float(frameHeight) / Float(height) * Float(width)
                            Rectangle()
                                .background(Color.red)
                                .frame(width: CGFloat(frameWidth), height: CGFloat(frameHeight))
                                .opacity(0.5)
                        }

                    }
                    else {
                        Rectangle()
                            .background(.gray)
                            .opacity(0.5)
                            .frame(maxWidth:300, maxHeight: 300)
                            .overlay {
                                ProgressView()
                            }
                    }

                }
            }
//            .onAppear {
//                imageReader.fetch(downLoad: false)
//            }
    }
}

struct TalkCardImageView: View {

    let talkImages: [TalkImage]
    var body: some View {
        let image = talkImages[0]

        ImageReaderView(talkImage: image)
            .overlay(alignment: .bottom){
                if talkImages.count > 1 {
                    Label("1 of \(talkImages.count)", systemImage: "ellipsis")
                        .font(.title2).labelStyle(.titleOnly).padding(5)
                        .background(Color.gray.opacity(0.8))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius))
                        .padding(.bottom, 5)
                }
            }
            .scaledToFill()
            .frame(width: 300, height: 300)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius))
            
            .contentShape(Rectangle())
            .onTapGesture {
                newWindowForImageSlides(with: talkImages)
            }
    }
}

struct ImageSlidesView: View {
    let images: [TalkImage]
//    let window: NSWindow?
    @State private var cur: Int = 0
    @State private var isLoading = true
    let maxSize = 1500

    struct ImageView: View {
        let talkImage: TalkImage
//        let window: NSWindow?
        let maxSize: Int
        @Binding var isLoading: Bool
        var body: some View {
            AsyncImage(url: URL(string: talkImage.src)){ image in
                image
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .onAppear{
                    self.isLoading.toggle()
                    var frameWidth: Int
                    var frameHeight: Int
                    let imgWidth = talkImage.width
                    let imgHeight = talkImage.height
                    if imgWidth < maxSize && imgHeight < maxSize {
                        frameWidth = imgWidth
                        frameHeight = imgHeight
                    } else if imgWidth > imgHeight {
                        frameWidth = maxSize
                        frameHeight = Int(Float(frameWidth) * Float(imgHeight) / Float(imgWidth))
                    } else {
                        frameHeight = maxSize
                        frameWidth = Int(Float(frameHeight) * Float(imgWidth) / Float(imgHeight))
                    }
                }
            } placeholder: {
                    let imgWidth = talkImage.width
                    let imgHeight = talkImage.height
                    if imgWidth < maxSize && imgHeight < maxSize {
                        let frameWidth = imgWidth
                        let frameHeight = imgHeight
                        ProgressView().frame(width: CGFloat(frameWidth), height: CGFloat(frameHeight))
                    } else if imgWidth > imgHeight {
                        let frameWidth = maxSize
                        let frameHeight = Int(Float(frameWidth) * Float(imgHeight) / Float(imgWidth))
                        ProgressView().frame(width: CGFloat(frameWidth), height: CGFloat(frameHeight))
                    } else {
                        let frameHeight = maxSize
                        let frameWidth = Int(Float(frameHeight) * Float(imgWidth) / Float(imgHeight))
                        ProgressView().frame(width: CGFloat(frameWidth), height: CGFloat(frameHeight))
                    }
            }

        }
    }


    
    struct ImageControlView: View {
        let imageCount: Int
        @Binding var cur: Int
        @Binding var isLoading: Bool
        var body: some View {
            GeometryReader{ proxy in
                HStack(alignment: .center){
                    if cur > 0 {
                        Rectangle()
                            .opacity(0.001)
                            .frame(width: proxy.size.width / 4, height: proxy.size.height)
                            .overlay(alignment: .leading) {
                                Label("Pre", systemImage: "arrow.left.circle.fill")
                                    .labelStyle(.iconOnly)
                                    .padding(20)
                                    .foregroundColor(.gray)
                            }
                            .onTapGesture {
                                cur = cur - 1
                                isLoading = true
                            }
                        }
                    if cur < imageCount - 1 {
                        Rectangle()
                            .opacity(0.001)
                            .frame(width: proxy.size.width / 4, height: proxy.size.height)
                            .overlay(alignment: .trailing) {
                                Label("Next", systemImage: "arrow.right.circle.fill")
                                    .labelStyle(.iconOnly)
                                    .padding(20)
                                    .foregroundColor(.gray)
                            }
                            .offset(x: cur == 0 ? proxy.size.width/4*3 : proxy.size.width/2)
                            .onTapGesture {
                                cur += 1
                                isLoading = true
                            }
                    }
                }
            }
            .font(Font.system(size: 36))
        }
    }

    var body: some View {
        ForEach(images) { image in
            if let idx = images.firstIndex{$0 == image}, idx == cur {
                ImageView(talkImage: image, maxSize: maxSize, isLoading: $isLoading)
                    .overlay {
                        ImageControlView(imageCount: images.count, cur: $cur, isLoading: $isLoading)
                    }
                    .overlay(alignment: .bottom){
                        HStack{
                            Text("\(idx+1) of \(images.count)").font(.title2).foregroundColor(.white)
                            if image.downloadable {
                                Label("Download", systemImage: "arrow.down.circle.fill")
                                    .labelStyle(.iconOnly)
                                    .font(.title2)
                                    .onTapGesture {
                                        ImageReader(url: image.src).fetch(downLoad: true)
                                    }
                            }
                        }
                        .padding(5)
                        .background(Color.gray).opacity(0.7)
                        .cornerRadius(10)
                        .padding(.bottom, 20)
                    }
            }
            
        }
    }
}
        
