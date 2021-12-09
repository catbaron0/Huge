//
//  GCoresData.swift
//  GCoresTalk
//
//  Created by catbaron on 2021/12/01.
//

import Foundation


enum GCoresType: String, Codable {
    case users
    case topics
    case topic
    case articles
    case videos
    case games
    case radios
    case comments
    case unstyled
    case image
    case talks
    case atomic
    case text
    case GALLERY
    case categories
    case headerOne = "header-one"
    case IMAGE
}

struct GCoresIDAndType: Codable {
    let id: String
    let type: GCoresType
}

struct GCoresIDAndTypeData: Codable {
    let data: GCoresIDAndType?
}

struct GCoresIDAndTypeDataList: Codable {
    let data: [GCoresIDAndType]?
}
