//
//  Utils.swift
//  GCoresTalk
//
//  Created by catbaron on 2021/11/26.
//

import Foundation

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
