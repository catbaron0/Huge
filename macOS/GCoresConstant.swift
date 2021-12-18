//
//  GCoresConstant.swift
//  GCoresTalk
//
//  Created by catbaron on 2021/12/15.
//

import Foundation
let GCORES_DEFAULT_PROFILE_URL = "https://alioss.gcores.com/page_resources/misc/avatar-default.png"
let GCORES_IMAGE_HOST = "https://image.gcores.com/"
let GCORES_IMAGE_SCALE_SETTING = "?x-oss-process=image/resize,limit_1,m_fill,w_150,h_150"
let GCORES_HOST = "https://www.gcores.com/"

let TITILEBAR_PADDING = CGFloat(-30)
let TITILEBAR_HEIGHT = 10
let SIDEBAR_TOP_PADDING = CGFloat(20)

let CornerRadius = CGFloat(10)

enum TopOffsetTrigger: Int {
    case timeline = 100
    case topics = 180
    case profile = 200
    case userList = 70
}

enum TimelineTopPadding: CGFloat {
    case titleBar = 50
    case profile = 80
    case userList = 70
}
