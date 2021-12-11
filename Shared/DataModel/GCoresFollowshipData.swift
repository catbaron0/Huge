//
//  GCoresFollowship.swift
//  GCoresTalk
//
//  Created by catbaron on 2021/12/05.
//

import Foundation
struct GCoresFollowshipResponse: Codable {
    struct Data: Codable {

        struct Attributes: Codable {
            let nickname: String?
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
        
        struct Relationships: Codable {
            struct Talks: Codable {
            }
            let talks: Talks
            struct Notifications: Codable {
            }
            let notifications: Notifications
            struct LatestArticles: Codable {
            }
            let latestArticles: LatestArticles
            struct LatestVideos: Codable {
            }
            let latestVideos: LatestVideos
            struct LatestRadios: Codable {
            }
            let latestRadios: LatestRadios
            struct LatestTalks: Codable {
            }
            let latestTalks: LatestTalks
            struct SubscribedEntries: Codable {
            }
            let subscribedEntries: SubscribedEntries
            struct SubscribedEntities: Codable {
            }
            let subscribedEntities: SubscribedEntities
            struct SubscribedGames: Codable {
            }
            let subscribedGames: SubscribedGames
            struct SubscribedTags: Codable {
            }
            let subscribedTags: SubscribedTags
            struct SubscribedCategories: Codable {
            }
            let subscribedCategories: SubscribedCategories
            struct SubscribedAlbums: Codable {
            }
            let subscribedAlbums: SubscribedAlbums
            struct SubscribedCollections: Codable {
            }
            let subscribedCollections: SubscribedCollections
            struct SubscribedTopics: Codable {
            }
            let subscribedTopics: SubscribedTopics
            struct SubscribedTalks: Codable {
            }
            let subscribedTalks: SubscribedTalks
            struct Entities: Codable {
            }
            let entities: Entities
            struct Originals: Codable {
            }
            let originals: Originals
            struct Articles: Codable {
            }
            let articles: Articles
            struct Radios: Codable {
            }
            let radios: Radios
            struct Videos: Codable {
            }
            let videos: Videos
            struct Followers: Codable {
            }
            let followers: Followers
            struct Followees: Codable {
            }
            let followees: Followees
            struct Preference: Codable {
            }
            let preference: Preference
            struct Bookmarks: Codable {
            }
            let bookmarks: Bookmarks
            struct Subscriptions: Codable {
            }
            let subscriptions: Subscriptions
            struct Tickets: Codable {
            }
            let tickets: Tickets
            struct GiveawayRecords: Codable {
            }
            let giveawayRecords: GiveawayRecords
            struct UserAnnualSummary: Codable {
            }
            let userAnnualSummary: UserAnnualSummary
            private enum CodingKeys: String, CodingKey {
                case talks
                case notifications
                case latestArticles = "latest-articles"
                case latestVideos = "latest-videos"
                case latestRadios = "latest-radios"
                case latestTalks = "latest-talks"
                case subscribedEntries = "subscribed-entries"
                case subscribedEntities = "subscribed-entities"
                case subscribedGames = "subscribed-games"
                case subscribedTags = "subscribed-tags"
                case subscribedCategories = "subscribed-categories"
                case subscribedAlbums = "subscribed-albums"
                case subscribedCollections = "subscribed-collections"
                case subscribedTopics = "subscribed-topics"
                case subscribedTalks = "subscribed-talks"
                case entities
                case originals
                case articles
                case radios
                case videos
                case followers
                case followees
                case preference
                case bookmarks
                case subscriptions
                case tickets
                case giveawayRecords = "giveaway-records"
                case userAnnualSummary = "user-annual-summary"
            }
        }
        
        struct Meta: Codable {
            let followshipId: String? //TODO: Specify the type to conforms Codable protocol
            let inverseFollowshipId: String? //TODO: Specify the type to conforms Codable protocol
            private enum CodingKeys: String, CodingKey {
                case followshipId = "followship-id"
                case inverseFollowshipId = "inverse-followship-id"
            }
        }
        let id: String
        let type: String
        let relationships: Relationships?
        let attributes: Attributes?
        let meta: Meta?
    }
    
    struct Meta: Codable {
        let recordCount: Int
        private enum CodingKeys: String, CodingKey {
            case recordCount = "record-count"
        }
    }
    let data: [Data]
    let meta: Meta
    
    func formalize() -> [TalkUser] {
        var users = [TalkUser]()
        for dt in data {
            let nickname = dt.attributes?.nickname ?? "nil"
            var src: String
            if let thumb = dt.attributes?.thumb {
                src = GCORES_IMAGE_HOST + thumb + GCORES_IMAGE_SCALE_SETTING
            } else {
                src = GCORES_DEFAULT_PROFILE_URL
            }
            
            var _createdAt: Date?
            if let _dateString = dt.attributes?.createdAt {
                _createdAt = DateUtils.dateFromString(string: _dateString, platform: .gcores)
            }
            let profile = TalkImage(src: src, isSpoiler: false, width: 60, height: 60, downloadable: true )
            users.append(TalkUser(
                id: dt.id,
                nickname: nickname,
                profile: profile,
                downloadable: !(dt.attributes?.disableImageDownload ?? false),
                location: dt.attributes?.location,
                isFresh: dt.attributes?.isFresh,
                intro: dt.attributes?.intro,
                sex: dt.attributes?.sex,
                followersCount: dt.attributes?.followersCount,
                followeesCount: dt.attributes?.followeesCount,
                _createdAt: _createdAt,
                psnId: dt.attributes?.psnId,
                liveId: dt.attributes?.liveId,
                nintendoFriendcode: dt.attributes?.nintendoFriendcode,
                steamId: dt.attributes?.steamId,
                isDeleted: dt.attributes?.isDeleted,
                isTreated: dt.attributes?.isTreated,
                followshipId: dt.meta?.followshipId,
                inverseFollowshipId: dt.meta?.inverseFollowshipId,
                _notificationFeedsLastSeenAt: nil,
                notificationFeedsUnseenCount: nil,
                _subscriptionFeedsLastSeenAt: nil,
                subscriptionFeedsUnseenCount: nil,
                _topicFeedsLastSeenAt: nil,
                topicFeedsUnseenCount: nil,
                privateMailsUnreadCount: nil
            ))
            
        }
        return users
    }
}
