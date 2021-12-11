//
//  GCoresUserData.swift
//  GCoresTalk
//
//  Created by catbaron on 2021/12/04.
//

import Foundation
// Login and check others
// Login and chack yourself
// Logout
struct GCoresUserResponse: Codable {
    struct Data: Codable {
        struct Attributes: Codable {
            let nickname: String
            let thumb: String?
            let location: String?
            let isFresh: Bool?
            let intro: String?
            let sex: Int?
            let followersCount: Int?
            let followeesCount: Int?
            let createdAt: String?
            let psnId: String?
            let liveId: String?
            let nintendoFriendcode: String?
            let steamId: String?
            let isDeleted: Bool?
            let isTreated: Bool?
            let disableImageDownload: Bool?
            private enum CodingKeys: String, CodingKey {
                case nickname
                case thumb
                case location
                case isFresh = "is-fresh"
                case intro
                case sex
                case followersCount = "followers-count"
                case followeesCount = "followees-count"
                case createdAt = "created-at"
                case psnId = "psn-id"
                case liveId = "live-id"
                case nintendoFriendcode = "nintendo-friendcode"
                case steamId = "steam-id"
                case isDeleted = "is-deleted"
                case isTreated = "is-treated"
                case disableImageDownload = "disable-image-download"
            }
        }
        
        struct Meta: Codable {
            let followshipId: String?
            let inverseFollowshipId: String?
            let hasIdentity: Bool?
            let hasPassword: Bool?
            let isEmailBound: Bool?
            let emailDisplay: String?
            let isEmailActive: Bool?
            let isPhoneNumberBound: Bool?
            let phoneNumberDisplay: String?
            let hasWeibo: Bool?
            let weiboDisplay: String?
            private enum CodingKeys: String, CodingKey {
                case followshipId = "followship-id"
                case inverseFollowshipId = "inverse-followship-id"
                case hasIdentity = "has-identity"
                case hasPassword = "has-password"
                case isEmailBound = "is-email-bound"
                case emailDisplay = "email-display"
                case isEmailActive = "is-email-active"
                case isPhoneNumberBound = "is-phone-number-bound"
                case phoneNumberDisplay = "phone-number-display"
                case hasWeibo = "has-weibo"
                case weiboDisplay = "weibo-display"
            }
        }
        
        let id: String
        let type: String
        let attributes: Attributes
        let meta: Meta
    }

    
    
    struct Meta: Codable {
        let notificationFeedsLastSeenAt: String
        let notificationFeedsUnseenCount: Int
        let subscriptionFeedsLastSeenAt: String
        let subscriptionFeedsUnseenCount: Int
        let topicFeedsLastSeenAt: String
        let topicFeedsUnseenCount: Int
        let privateMailsUnreadCount: Int
        private enum CodingKeys: String, CodingKey {
            case notificationFeedsLastSeenAt = "notification-feeds-last-seen-at"
            case notificationFeedsUnseenCount = "notification-feeds-unseen-count"
            case subscriptionFeedsLastSeenAt = "subscription-feeds-last-seen-at"
            case subscriptionFeedsUnseenCount = "subscription-feeds-unseen-count"
            case topicFeedsLastSeenAt = "topic-feeds-last-seen-at"
            case topicFeedsUnseenCount = "topic-feeds-unseen-count"
            case privateMailsUnreadCount = "private-mails-unread-count"
        }
    }
    
    // NOTE: The meta domain for Data got extra info for login users's own profile
    let data: Data
    // Only appear when I'm login and check my own info
    let meta: Meta?
    
    func formalize() -> TalkUser {
        var _notificationFeedsLastSeenAt: Date?
        var _subscriptionFeedsLastSeenAt: Date?
        var _topicFeedsLastSeenAt: Date?

        if let meta = meta {
            _notificationFeedsLastSeenAt = DateUtils.dateFromString(string: meta.notificationFeedsLastSeenAt, platform: .gcores)
            _subscriptionFeedsLastSeenAt = DateUtils.dateFromString(string: meta.subscriptionFeedsLastSeenAt, platform: .gcores)
            _topicFeedsLastSeenAt = DateUtils.dateFromString(string: meta.topicFeedsLastSeenAt, platform: .gcores)
        }
        
        var profile_src: String
        if let src = data.attributes.thumb {
            profile_src = GCORES_IMAGE_HOST + src + GCORES_IMAGE_SCALE_SETTING
        } else {
            profile_src = GCORES_DEFAULT_PROFILE_URL
        }
        return TalkUser(
            id: data.id,
            nickname: data.attributes.nickname,
            profile: TalkImage(
                src:  profile_src,
                isSpoiler: false,
                width: 300, height: 300,
                downloadable: !(data.attributes.disableImageDownload ?? false)
                ),
            downloadable: !(data.attributes.disableImageDownload ?? false),
            location: data.attributes.location,
            isFresh: data.attributes.isFresh,
            intro: data.attributes.intro,
            sex: data.attributes.sex,
            followersCount: data.attributes.followersCount,
            followeesCount: data.attributes.followeesCount,
            _createdAt: DateUtils.dateFromString(string: data.attributes.createdAt!, platform: .gcores) ,
            psnId: data.attributes.psnId,
            liveId: data.attributes.liveId,
            nintendoFriendcode: data.attributes.nintendoFriendcode,
            steamId: data.attributes.steamId,
            isDeleted: data.attributes.isDeleted,
            isTreated: data.attributes.isTreated,
            followshipId: data.meta.followshipId,
            inverseFollowshipId: data.meta.inverseFollowshipId,
            _notificationFeedsLastSeenAt: _notificationFeedsLastSeenAt,
            notificationFeedsUnseenCount: meta?.notificationFeedsUnseenCount,
            _subscriptionFeedsLastSeenAt: _subscriptionFeedsLastSeenAt,
            subscriptionFeedsUnseenCount: meta?.subscriptionFeedsUnseenCount,
            _topicFeedsLastSeenAt: _topicFeedsLastSeenAt,
            topicFeedsUnseenCount: meta?.topicFeedsUnseenCount,
            privateMailsUnreadCount: meta?.privateMailsUnreadCount
        )
    }
    
}

