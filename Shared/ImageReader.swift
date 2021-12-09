//
//  ImageReader.swift
//  GCoresTalk
//
//  Created by catbaron on 2021/11/30.
//
import Foundation
import Cocoa
//
//// Step 1: Typealias UIImage to NSImage
//typealias UIImage = NSImage
//
//// Step 2: You might want to add these APIs that UIImage has but NSImage doesn't.
//extension NSImage {
//    var cgImage: CGImage? {
//        var proposedRect = CGRect(origin: .zero, size: size)
//
//        return cgImage(forProposedRect: &proposedRect,
//                       context: nil,
//                       hints: nil)
//    }
//
//    convenience init?(named name: String) {
//        self.init(named: Name(name))
//    }
//}

// Load image from a url

class ImageReader: ObservableObject {
    
    @Published var isLoading: Bool = false
    @Published var image: NSImage? = nil
    // TODO: Add error message
    
    let url: String?

    init(url: String?) {
        self.url = url
    }
    func fetch(downLoad: Bool = false) {
        
        guard self.image == nil, !(self.isLoading) else {
            return
        }
        print("I'm fetching from \(url!)")
        guard let url = url, let fetchURL = URL(string: url) else {
            // TODO: ivalid url
            print("Failed to process the url!")
            return
        }
        let request = URLRequest(url: fetchURL, cachePolicy: .returnCacheDataElseLoad)
        URLCache.shared.memoryCapacity = 1024 * 1024 * 200
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = true
                if let error = error {
                    // TODO: Failed to get data from url
                    print("Failed to access to image url:\(error)")
                    print(url)
                    return
                }
                if let response = response as? HTTPURLResponse {
                    if !(200...299).contains(response.statusCode) {
                        // TODO: Error code!
                        print("Error code: \(response.statusCode)")
                        return
                    }
                }
                if let data = data, let image = NSImage(data: data) {
                    self.image = image
                    self.isLoading = false
                    if downLoad {
                        let filename = fetchURL.lastPathComponent
                        
                        let dir = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first?.appendingPathComponent(filename)
                        do{
                            try data.write(to: dir!)
                            print("The image is saved to \(dir!)")
                        } catch {
                            print("Failed to save image: \(error) ")
                        }
                        
                    }
                    return
                }
                // TODO: - UNKown Error
                
            }
        }
        task.resume()
    }
    
}
