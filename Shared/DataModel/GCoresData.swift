//
//  GCoresData.swift
//  GCoresTalk
//
//  Created by catbaron on 2021/12/01.
//

import Foundation

let GCORES_DEFAULT_PROFILE_URL = "https://alioss.gcores.com/page_resources/misc/avatar-default.png"
let GCORES_IMAGE_HOST = "https://image.gcores.com/"
let GCORES_IMAGE_SCALE_SETTING = "?x-oss-process=image/resize,limit_1,m_fill,w_150,h_150"
let GCORES_HOST = "https://www.gcores.com/"

enum GCoresRelatedType: String, Codable {
    case users
    case topics
//    case topic
    case articles
    case videos
    case games
    case radios
    case comments
//    case unstyled
    case image
    case talks
//    case atomic
//    case text
//    case GALLERY
    case categories
//    case headerOne = "header-one"
//    case IMAGE
}

struct GCoresIDAndType: Codable {
    let id: String
    let type: GCoresRelatedType
}

struct GCoresIDAndTypeData: Codable {
    let data: GCoresIDAndType?
}

struct GCoresIDAndTypeDataList: Codable {
    let data: [GCoresIDAndType]?
}
