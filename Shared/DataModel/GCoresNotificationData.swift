//
//  GCoresNotificationData.swift
//  GCoresTalk
//
//  Created by catbaron on 2021/12/13.
//

import Foundation
import SwiftUI
struct GCoresNotificationResponse: Codable {
    struct Data: Codable {
        let id: String
        let type: String
        struct Attributes: Codable {
            let image: String?
            let verb: NotificationType
            let actorsCount: Int
            let objectsCount: Int
            let createdAt: String?
            let updatedAt: String?
            private enum CodingKeys: String, CodingKey {
                case image
                case verb
                case actorsCount = "actors-count"
                case objectsCount = "objects-count"
                case createdAt = "created-at"
                case updatedAt = "updated-at"
            }
        }
        let attributes: Attributes
        struct Relationships: Codable {
            struct LeadActors: Codable {
                struct Data: Codable {
                    let type: GCoresRelatedType
                    let id: String
                }
                let data: [Data]
            }
            let leadActors: LeadActors
            struct LeadObjects: Codable {
                struct Data: Codable {
                    let type: GCoresRelatedType
                    let id: String
                }
                let data: [Data]
            }
            let leadObjects: LeadObjects
            struct Target: Codable {
                struct Data: Codable {
                    let type: GCoresRelatedType
                    let id: String
                }
                let data: Data?
            }
            let target: Target
            private enum CodingKeys: String, CodingKey {
                case leadActors = "lead-actors"
                case leadObjects = "lead-objects"
                case target
            }
        }
        let relationships: Relationships
    }
    let data: [Data]
    struct Included: Codable {
        let id: String
        let type: GCoresRelatedType
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
            let ban: Bool?
            let nameChangedAt: String?
            let isDeleted: Bool?
            let isTreated: Bool?
            let disableImageDownload: Bool?
            let title: String?
            let content: String?
            let updatedAt: String?
            let likesCount: Int?
            let commentsCount: Int?
            let score: Double?
            let auditState: String?
            let publishedAt: String?
            let isEditorSelected: Bool?
            let desc: String?
            let cover: String?
            let isPublished: Int?
            let participantsCount: Int?
            let banner: String?
            let latestContributedAt: String?
            let description: String?
            struct CustomSection: Codable {
                let type: String
                let title: String
            }
            let customSection: [CustomSection]?
            struct Preview: Codable {
                let type: String
                let src: String
            }
            let preview: [Preview]?
            let hasGiveaway: Bool?
            let body: String?
            let depth: Int?
            let descendantsCount: Int?
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
                case ban
                case nameChangedAt = "name-changed-at"
                case isDeleted = "is-deleted"
                case isTreated = "is-treated"
                case disableImageDownload = "disable-image-download"
                case title
                case content
                case updatedAt = "updated-at"
                case likesCount = "likes-count"
                case commentsCount = "comments-count"
                case score
                case auditState = "audit-state"
                case publishedAt = "published-at"
                case isEditorSelected = "is-editor-selected"
                case desc
                case cover
                case isPublished = "is-published"
                case participantsCount = "participants-count"
                case banner
                case latestContributedAt = "latest-contributed-at"
                case customSection = "custom-section"
                case preview
                case hasGiveaway = "has-giveaway"
                case body
                case depth
                case descendantsCount = "descendants-count"
                case description
            }
        }
        let attributes: Attributes
        struct Relationships: Codable {
            struct Comments: Codable {
            }
            let comments: Comments?
            struct Talks: Codable {
            }
            let talks: Talks?
            struct Drafts: Codable {
            }
            let drafts: Drafts?
            struct Notifications: Codable {
            }
            let notifications: Notifications?
            struct LatestArticles: Codable {
            }
            let latestArticles: LatestArticles?
            struct LatestVideos: Codable {
            }
            let latestVideos: LatestVideos?
            struct LatestRadios: Codable {
            }
            let latestRadios: LatestRadios?
            struct LatestTalks: Codable {
            }
            let latestTalks: LatestTalks?
            struct NotificationFeeds: Codable {
            }
            let notificationFeeds: NotificationFeeds?
            struct SubscriptionFeeds: Codable {
            }
            let subscriptionFeeds: SubscriptionFeeds?
            struct TimelineFeeds: Codable {
            }
            let timelineFeeds: TimelineFeeds?
            struct TopicFeeds: Codable {
            }
            let topicFeeds: TopicFeeds?
            struct PrivateMailThreads: Codable {
            }
            let privateMailThreads: PrivateMailThreads?
            struct SubscribedEntries: Codable {
            }
            let subscribedEntries: SubscribedEntries?
            struct SubscribedEntities: Codable {
            }
            let subscribedEntities: SubscribedEntities?
            struct SubscribedGames: Codable {
            }
            let subscribedGames: SubscribedGames?
            struct SubscribedTags: Codable {
            }
            let subscribedTags: SubscribedTags?
            struct SubscribedCategories: Codable {
            }
            let subscribedCategories: SubscribedCategories?
            struct SubscribedAlbums: Codable {
            }
            let subscribedAlbums: SubscribedAlbums?
            struct SubscribedCollections: Codable {
            }
            let subscribedCollections: SubscribedCollections?
            struct SubscribedTopics: Codable {
            }
            let subscribedTopics: SubscribedTopics?
            struct SubscribedTalks: Codable {
            }
            let subscribedTalks: SubscribedTalks?
            struct Entities: Codable {
            }
            let entities: Entities?
            struct PrivateMails: Codable {
            }
            let privateMails: PrivateMails?
            struct Originals: Codable {
            }
            let originals: Originals?
            struct Articles: Codable {
            }
            let articles: Articles?
            struct Radios: Codable {
            }
            let radios: Radios?
            struct Videos: Codable {
            }
            let videos: Videos?
            struct Followers: Codable {
            }
            let followers: Followers?
            struct Followees: Codable {
            }
            let followees: Followees?
            struct Role: Codable {
            }
            let role: Role?
            struct Preference: Codable {
            }
            let preference: Preference?
            struct Bookmarks: Codable {
            }
            let bookmarks: Bookmarks?
            struct Subscriptions: Codable {
            }
            let subscriptions: Subscriptions?
            struct BlacklistedUsers: Codable {
            }
            let blacklistedUsers: BlacklistedUsers?
            struct BlockedTopics: Codable {
            }
            let blockedTopics: BlockedTopics?
            struct BlockedAuthors: Codable {
            }
            let blockedAuthors: BlockedAuthors?
            struct Tickets: Codable {
            }
            let tickets: Tickets?
            struct GiveawayRecords: Codable {
            }
            let giveawayRecords: GiveawayRecords?
            struct PostAddresses: Codable {
            }
            let postAddresses: PostAddresses?
            struct DefaultPostAddress: Codable {
            }
            let defaultPostAddress: DefaultPostAddress?
            struct UserAnnualSummary: Codable {
            }
            let userAnnualSummary: UserAnnualSummary?
            struct GotyVote: Codable {
            }
            let gotyVote: GotyVote?
            struct Topic: Codable {
            }
            let topic: Topic?
            struct User: Codable {
            }
            let user: User?
            struct UpVoters: Codable {
            }
            let upVoters: UpVoters?
            struct Games: Codable {
            }
            let games: Games?
            struct RecommendedTalks: Codable {
            }
            let recommendedTalks: RecommendedTalks?
            struct EditorSelections: Codable {
            }
            let editorSelections: EditorSelections?
            struct RandomTalks: Codable {
            }
            let randomTalks: RandomTalks?
            struct OperationalEvents: Codable {
            }
            let operationalEvents: OperationalEvents?
            struct Tags: Codable {
            }
            let tags: Tags?
            struct Entries: Codable {
            }
            let entries: Entries?
            struct RecommendedTopics: Codable {
            }
            let recommendedTopics: RecommendedTopics?
            struct LinkedTopics: Codable {
            }
            let linkedTopics: LinkedTopics?
            struct LinkedOriginals: Codable {
            }
            let linkedOriginals: LinkedOriginals?
            struct LinkedArticles: Codable {
            }
            let linkedArticles: LinkedArticles?
            struct LinkedRadios: Codable {
            }
            let linkedRadios: LinkedRadios?
            struct LinkedVideos: Codable {
            }
            let linkedVideos: LinkedVideos?
            struct LinkedAlbums: Codable {
            }
            let linkedAlbums: LinkedAlbums?
            struct LinkedCollections: Codable {
            }
            let linkedCollections: LinkedCollections?
            struct LinkedGames: Codable {
            }
            let linkedGames: LinkedGames?
            struct Category: Codable {
            }
            let category: Category?
            struct Root: Codable {
            }
            let root: Root?
            struct Commentable: Codable {
            }
            let commentable: Commentable?
            struct Subcommentable: Codable {
            }
            let subcommentable: Subcommentable?
            struct Parent: Codable {
            }
            let parent: Parent?
            struct Children: Codable {
            }
            let children: Children?
            struct Descendants: Codable {
            }
            let descendants: Descendants?
            struct OldestDescendants: Codable {
            }
            let oldestDescendants: OldestDescendants?
            struct Ancestors: Codable {
            }
            let ancestors: Ancestors?
            private enum CodingKeys: String, CodingKey {
                case comments
                case talks
                case drafts
                case notifications
                case latestArticles = "latest-articles"
                case latestVideos = "latest-videos"
                case latestRadios = "latest-radios"
                case latestTalks = "latest-talks"
                case notificationFeeds = "notification-feeds"
                case subscriptionFeeds = "subscription-feeds"
                case timelineFeeds = "timeline-feeds"
                case topicFeeds = "topic-feeds"
                case privateMailThreads = "private-mail-threads"
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
                case privateMails = "private-mails"
                case originals
                case articles
                case radios
                case videos
                case followers
                case followees
                case role
                case preference
                case bookmarks
                case subscriptions
                case blacklistedUsers = "blacklisted-users"
                case blockedTopics = "blocked-topics"
                case blockedAuthors = "blocked-authors"
                case tickets
                case giveawayRecords = "giveaway-records"
                case postAddresses = "post-addresses"
                case defaultPostAddress = "default-post-address"
                case userAnnualSummary = "user-annual-summary"
                case gotyVote = "goty-vote"
                case topic
                case user
                case upVoters = "up-voters"
                case games
                case recommendedTalks = "recommended-talks"
                case editorSelections = "editor-selections"
                case randomTalks = "random-talks"
                case operationalEvents = "operational-events"
                case tags
                case entries
                case recommendedTopics = "recommended-topics"
                case linkedTopics = "linked-topics"
                case linkedOriginals = "linked-originals"
                case linkedArticles = "linked-articles"
                case linkedRadios = "linked-radios"
                case linkedVideos = "linked-videos"
                case linkedAlbums = "linked-albums"
                case linkedCollections = "linked-collections"
                case linkedGames = "linked-games"
                case category
                case root
                case commentable
                case subcommentable
                case parent
                case children
                case descendants
                case oldestDescendants = "oldest-descendants"
                case ancestors
            }
        }
        let relationships: Relationships
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
            let voteFlag: Bool?
            let voteId: String?
            let bookmarkId: String?
            let subscriptionId: String?
            let subscriptionWeight: Int?
            let isContentBlocked: Bool?
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
                case voteFlag = "vote-flag"
                case voteId = "vote-id"
                case bookmarkId = "bookmark-id"
                case subscriptionId = "subscription-id"
                case subscriptionWeight = "subscription-weight"
                case isContentBlocked = "is-content-blocked"
            }
        }
        let meta: Meta
    }
    let included: [Included]
    struct Meta: Codable {
        let notificationFeedsLastSeenAt: String
        let notificationFeedsUnseenCount: Int
        let recordCount: Int
        private enum CodingKeys: String, CodingKey {
            case notificationFeedsLastSeenAt = "notification-feeds-last-seen-at"
            case notificationFeedsUnseenCount = "notification-feeds-unseen-count"
            case recordCount = "record-count"
        }
    }
    let meta: Meta
    
    func findTalkUser(with id: String) -> TalkUser {
        let includedData = included.first(where: {$0.id == id && $0.type == .users})!
        let nickname = includedData.attributes.nickname ?? "nil"
        var src: String
        if let thumb = includedData.attributes.thumb {
            src = GCORES_IMAGE_HOST + thumb + GCORES_IMAGE_SCALE_SETTING
        } else {
            src = GCORES_DEFAULT_PROFILE_URL
        }
        let profile = TalkImage(src: src, isSpoiler: false, width: 60, height: 60, downloadable: true)
        return TalkUser(
            id: id,
            nickname: nickname,
            profile: profile,
            downloadable: true,
            location: includedData.attributes.location,
            isFresh: includedData.attributes.isFresh,
            intro: includedData.attributes.intro,
            sex: includedData.attributes.sex,
            followersCount: includedData.attributes.followersCount,
            followeesCount: includedData.attributes.followeesCount,
            _createdAt: DateUtils.dateFromString(string: includedData.attributes.createdAt!, platform: .gcores),
            psnId: includedData.attributes.psnId,
            liveId: includedData.attributes.liveId,
            nintendoFriendcode: includedData.attributes.nintendoFriendcode,
            steamId: includedData.attributes.steamId,
            isDeleted: includedData.attributes.isDeleted,
            isTreated: includedData.attributes.isTreated,
            followshipId: includedData.meta.followshipId,
            inverseFollowshipId: includedData.meta.inverseFollowshipId,
            _notificationFeedsLastSeenAt: nil,
            notificationFeedsUnseenCount: nil,
            _subscriptionFeedsLastSeenAt: nil,
            subscriptionFeedsUnseenCount: nil,
            _topicFeedsLastSeenAt: nil,
            topicFeedsUnseenCount: nil,
            privateMailsUnreadCount: nil
        )
    }
    
    struct Content: Codable {
        struct Block: Codable {
            struct Data: Codable {
                let spoiler: Bool?
            }
            struct EntityRange: Codable {
                let key: Int
                let length: Int
                let offset: Int
            }
            let data: Data
            let depth: Int
            let entityRanges: [EntityRange]
            let key: String
            let text: String
            let type: String?
        }
        
        struct EntityMap: Codable {
            struct Data: Codable {
                struct Image: Codable {
                    let path: String
                    let width: Int?
                    let height: Int?
                }
                let caption: String?
                let images: [Image]?
                let path: String?
            }
            let data: Data
            let mutability: String?
            let type: String?
        }
        let blocks: [Block]
        let entityMap: [String: EntityMap]
    }

    func findRelated(id: String, type: GCoresRelatedType) -> TalkRelated {
        let includedData = included.first(where: {$0.id == id && $0.type == type})!
        var cover: String?
        if let src = includedData.attributes.cover {
            cover = GCORES_IMAGE_HOST + src
        } else if let src = includedData.attributes.thumb {
            cover = GCORES_IMAGE_HOST + src
        } else {
            cover = nil
        }
        
        var text = ""
        if let content = includedData.attributes.content {
            let jsonData = content.data(using: .utf8)!
            let contentData = try! JSONDecoder().decode(Content.self, from: jsonData)
            let blocks = contentData.blocks
            text = ""
            for block in blocks {
                text += block.text
            }
        }
        
        return TalkRelated(
            id: id, type: type, title: includedData.attributes.title,
            desc: includedData.attributes.desc ?? includedData.attributes.description,
            cover: cover, banner: nil, contentString: includedData.attributes.body ?? text)
    }

    func formalize() -> [Notification] {
        let lastReadDate = DateUtils.dateFromString(string: meta.notificationFeedsLastSeenAt, platform: .gcores)
        return data.map { d in
            let ntfId = d.id
            let ntfType = d.attributes.verb
            
            // actors
            let actors = d.relationships.leadActors.data.map { findTalkUser(with: $0.id)}
            
            // object
            let object = d.relationships.leadObjects.data.map {
                findRelated(id: $0.id, type: $0.type)
            }
            var target: TalkRelated? = nil
            if let targetData = d.relationships.target.data {
                target = findRelated(id: targetData.id, type: targetData.type)
            }
            
            let notificationDate = DateUtils.dateFromString(string: d.attributes.createdAt!, platform: .gcores)
            return Notification(id: ntfId, type: ntfType, object: object, target: target, actors: actors, unRead: notificationDate > lastReadDate)
            
        }
        
    }
}
