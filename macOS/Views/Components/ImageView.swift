//
//  ImageView.swift
//  GCoresTalk (macOS)
//
//  Created by catbaron on 2021/11/29.
//

import SwiftUI


struct ImageReaderView: View {

    @StateObject var imageReader: ImageReader
    private var width: Int
    private var height: Int
//    private let displayWidth = 200
    private var largeSize: Int?

    init(url: String, width: Int, height: Int) {
        self._imageReader = StateObject(wrappedValue: ImageReader(url: url))
        self.width = width
        self.height = height
    }

    
    init(talkImage: TalkImage) {
        self._imageReader = StateObject(wrappedValue: ImageReader(url: talkImage.src))
        self.width = talkImage.width
        self.height = talkImage.height
    }
    
    init(talkImage: TalkImage, largeSize: Int) {
        self._imageReader = StateObject(wrappedValue: ImageReader(url: talkImage.src))
        self.width = talkImage.width
        self.height = talkImage.height
        self.largeSize = largeSize
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
                            .scaledToFill()
//                            .frame(width: CGFloat(displayWidth))
                            .frame(maxWidth:200, maxHeight: 300)
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
                            .background(.red)
                            .opacity(0.5)
                            .frame(maxWidth:200, maxHeight: 300)
                    }

                }
            }
            .onAppear {
                imageReader.fetch(downLoad: false)
            }
    }
}

struct TalkCardImageView: View {

    let talkImages: [TalkImage]
    var body: some View {
        let image = talkImages[0]

        ImageReaderView(talkImage: image)
            .scaledToFit()
            .overlay(alignment: .bottom){
                if talkImages.count > 1 {
                    HStack {
                        Spacer()
                        Label("1 of \(talkImages.count)", systemImage: "ellipsis")
                            .font(.title2).labelStyle(.titleOnly).frame(minHeight: 20)
                            .foregroundColor(.white)
                        Spacer()
                    }.background(Color.gray).opacity(0.7)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 15))

            .contentShape(Rectangle())
            .onTapGesture {
                newWindowForImageSlides(with: talkImages)
            }
    }
}

struct ImageSlidesView: View {
    let images: [TalkImage]
    let window: NSWindow?
    @State private var cur: Int = 0
    @State private var isLoading = true
    let maxSize = 600

    struct ImageView: View {
        let talkImage: TalkImage
        let window: NSWindow?
        let maxSize: Int
        @Binding var isLoading: Bool
        var body: some View {
            AsyncImage(url: URL(string: talkImage.src)){ image in
                image
                .resizable()
                .scaledToFit()
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
                        window?.setFrame(NSRect(origin: (window?.frame.origin)!, size: CGSize(width: frameWidth, height: frameHeight)), display: true, animate: true)
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
//                        Text("pre")
                            .opacity(0.001)
                            .frame(width: proxy.size.width / 2, height: proxy.size.height)
//                            .foregroundColor(.red)
                            .overlay(alignment: .leading) {
                                Label("Pre", systemImage: "arrow.left.circle.fill")
                                    .labelStyle(.iconOnly)
                                    .padding(20)
                            }
                            .onTapGesture {
                                cur = cur - 1
                                isLoading = true
                            }
                        }
                    if cur < imageCount - 1 {
                        Rectangle()
//                        Text("next")
                            .opacity(0.001)
//                            .foregroundColor(.blue)
                            .frame(width: proxy.size.width / 2, height: proxy.size.height)
                            .overlay(alignment: .trailing) {
                                Label("Next", systemImage: "arrow.right.circle.fill")
                                    .labelStyle(.iconOnly)
                                    .padding(20)
                            }
                            .offset(x: cur == 0 ? proxy.size.width/2 : 0)
                            .onTapGesture {
                                cur += 1
                                isLoading = true
                            }
                    }
                }
            }.font(.largeTitle)
        }
    }
    // TODO: Load all of the images at onece instead repeat loading everytime we switch between images
    var body: some View {
        ForEach(images) { image in
            if let idx = images.firstIndex{$0 == image}, idx == cur {
                ImageView(talkImage: image, window: window, maxSize: maxSize, isLoading: $isLoading)
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
        
