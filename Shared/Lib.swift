//
//  Utils.swift
//  GCoresTalk
//
//  Created by catbaron on 2021/11/26.
//

import Foundation
import SwiftUI
enum TimelineEndPoint {
    case recommend
    case followee
    case topic
    case user
//    case topic(id: String)
    
}

enum Platform {
    case gcores
}

class DateUtils {
    class func dateFromString(string: String, platform: Platform) -> Date {
        let formatter: DateFormatter = DateFormatter()
        
        switch platform {
        case .gcores:
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        }
        
        formatter.calendar = Calendar(identifier: .gregorian)
        return formatter.date(from: string)!
    }

    class func stringFromDate(date: Date, platform: Platform) -> String {
        let formatter: DateFormatter = DateFormatter()
        switch platform {
        case .gcores:
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        }
        formatter.calendar = Calendar(identifier: .gregorian)
        
        return formatter.string(from: date)
    }
    
    class func stampFromDate(date: Date) -> String {
        let timeInterval:TimeInterval = date.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        return String(timeStamp)
    }
}

extension Int {
    var boolValue: Bool { return self != 0 }
}

extension String {
    var escaped: String {
        return self.replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
            .replacingOccurrences(of: "\0", with: "\\0")
            .replacingOccurrences(of: "\t", with: "\\t")
    }
}

extension Data {

    var mimeType: String? {
        var values = [UInt8](repeating: 0, count: 1)
        copyBytes(to: &values, count: 1)

        switch values[0] {
        case 0xFF:
            return "image/jpeg"
        case 0x89:
            return "image/png"
        case 0x47:
            return "image/gif"
        case 0x49, 0x4D:
            return "image/tiff"
        default:
            return nil
        }
    }
}

extension NSTextView {
    open override var frame: CGRect {
        didSet {
            backgroundColor = .clear //<<here clear
            drawsBackground = true
        }

    }
}

extension View {
    func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
}

public extension NSTextField {
    override var focusRingType: NSFocusRingType {
            get { .none }
            set { }
    }
}
