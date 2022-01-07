//
//  GCoresComment.swift
//  GCoresTalk
//
//  Created by catbaron on 2021/12/01.
//

import Foundation

// MARK: GCoresTalk comment Data
struct GCoresTalkCommentData: Decodable {
    
    struct Attributes: Decodable {
        let body: String
        let depth: Int
        let likesCount: Int
        let score: Float
        let createdAt: String
        let descendantsCount: Int
        
        enum CodingKeys: String, CodingKey {
            case body, depth, score
            case likesCount = "likes-count"
            case createdAt = "created-at"
            case descendantsCount = "descendants-count"
        }
        
    }
    
    struct Relationships: Decodable {
        let user: GCoresIDAndTypeData
        // let root: Any
        let commentable: GCoresIDAndTypeData
        let parent: GCoresIDAndTypeData
        let descendants: GCoresIDAndTypeDataList?
        let oldestDescendants: GCoresIDAndTypeDataList?
        
        enum CodingKeys: String, CodingKey {
            case user, parent, descendants, commentable
            case oldestDescendants = "oldest-descendants"
        }
    }
    
    struct Meta: Decodable {
        let voteFlag: Bool?
        let voteId: String?
        
        enum CodingKeys: String, CodingKey {
            case voteFlag = "vote-flag"
            case voteId = "vote-id"
        }
    }
    
    let id: String
    let type: GCoresRelatedType
    let attributes: Attributes
    let relationships: Relationships
    let meta: Meta
    
//    enum CodingKeys: String, CodingKey {
//        case _id = "id"
//        case type, attributes, relationships, meta
//
//    var id: String {
//        return "gcorestalk-\(GCoresTalkCommentData.CodingKeys.type)-\(GCoresTalkCommentData.CodingKeys._id)"
//    }
}

struct GCoresTalkCommentIncluded: Decodable {
    struct Attributes: Decodable {
        // For type of comments
        let body: String?
        let depth: Int?
        let likesCount: Int?
        let score: Float?
        let createdAt: String?
        let descendantsCount: Int?
        
        // for type of users
        let nickname: String?
        let thumb: String?
        let location: String?
        let isFresh: Bool?
        let intro: String?
        let sex: Int?
        let followersCount: Int?
        let followeesCount: Int?
        let psnId: String?
        let liveId: String?
        let nintendoFriendcode: String?
        let steamId: String?
        let isDeleted: Bool?
        let isTreated: Bool?
//        let disableImageDownload: Bool?
        
        enum CodingKeys: String, CodingKey {
            case body, depth, score
            case likesCount = "likes-count"
            case createdAt = "created-at"
            case descendantsCount = "descendants-count"
            
            case nickname, location, intro, sex, thumb
            case isFresh = "is-fresh"
            case followersCount = "followers-count"
            case followeesCount = "followees-count"
            case psnId = "psn-id"
            case liveId = "live-id"
            case nintendoFriendcode = "nintendo-friendcode"
            case steamId = "steam-id"
            case isDeleted = "is-deleted"
            case isTreated = "is-treated"
//            case disableImageDownload = "disable-image-download"
        }
    }
    struct Relationships: Decodable {
        // Only for comments for now
        let user: GCoresIDAndTypeData?
        let parent: GCoresIDAndTypeData?
        let descendants: GCoresIDAndTypeDataList?
        let oldestDescendants: GCoresIDAndTypeDataList?
        enum CodingKeys: String, CodingKey {
            case user, parent, descendants
            case oldestDescendants = "oldest-descendants"
        }
    }

    struct Meta: Decodable {
        // For type of comment
        let voteFlag: Bool?
        let voteId: String?
        
        //for type of users
        let followshipId: String?
        let inverseFollowshipId: String?
        
        enum CodingKeys: String, CodingKey {
            case voteFlag = "vote-flag"
            case voteId = "vote-id"
            case followshipId = "followship-id"
            case inverseFollowshipId = "inverse-followship-id"
        }
    }
    let id: String
    let type: GCoresRelatedType
    let attributes: Attributes
    let relationships: Relationships
    let meta: Meta
}

struct GCoresTalkCommentMeta: Decodable {
    let recordCount: Int
    enum CodingKeys: String, CodingKey {
        case recordCount = "record-count"
    }
    
}

struct GCoresTalkCommentResponse: Decodable {
    let data: [GCoresTalkCommentData]
    let included: [GCoresTalkCommentIncluded]?
    let meta: GCoresTalkCommentMeta
    
    func findTalkUser(with id: String, from included: [GCoresTalkCommentIncluded]) -> TalkUser {
        let data = included.first(where: {$0.id == id && $0.type == .users})!
        let nickname = data.attributes.nickname ?? "nil"
        var src: String
        if let thumb = data.attributes.thumb {
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
            location: data.attributes.location,
            isFresh: data.attributes.isFresh,
            intro: data.attributes.intro,
            sex: data.attributes.sex,
            followersCount: data.attributes.followersCount,
            followeesCount: data.attributes.followeesCount,
            _createdAt: DateUtils.dateFromString(string: data.attributes.createdAt!, platform: .gcores),
            psnId: data.attributes.psnId,
            liveId: data.attributes.liveId,
            nintendoFriendcode: data.attributes.nintendoFriendcode,
            steamId: data.attributes.steamId,
            isDeleted: data.attributes.isDeleted,
            isTreated: data.attributes.isTreated,
            followshipId: data.meta.followshipId,
            inverseFollowshipId: data.meta.inverseFollowshipId,
            _notificationFeedsLastSeenAt: nil,
            notificationFeedsUnseenCount: nil,
            _subscriptionFeedsLastSeenAt: nil,
            subscriptionFeedsUnseenCount: nil,
            _topicFeedsLastSeenAt: nil,
            topicFeedsUnseenCount: nil,
            privateMailsUnreadCount: nil
        )
    }

    private func commentFrom(commentIncluded: GCoresTalkCommentIncluded) -> TalkCommentCard {
        
        let userId = commentIncluded.relationships.user!.data!.id
        let user = findTalkUser(with: userId, from: included!)
        var descendants: [String]? = nil
        if let _decendants = commentIncluded.relationships.descendants?.data {
            descendants = _decendants.map({$0.id})
        }
        var oldestDescendants: [String]? = nil
        if let _decendants = commentIncluded.relationships.oldestDescendants?.data {
            oldestDescendants = _decendants.map({$0.id})
        }
        return TalkCommentCard(
            id: commentIncluded.id,
            platform: .gcores,
            user: user,
            _createdAt: DateUtils.dateFromString(string: commentIncluded.attributes.createdAt!, platform: .gcores),
            _updatedAt: DateUtils.dateFromString(string: commentIncluded.attributes.createdAt!, platform: .gcores),
            edited: false,
            replyTo: commentIncluded.relationships.parent?.data?.id,
            descendantsCount: commentIncluded.attributes.descendantsCount,
            descendants: descendants ?? [String](),
            oldestDescendants: oldestDescendants ?? [String](),
            depth: commentIncluded.attributes.depth!,
            text: commentIncluded.attributes.body!,
            images: nil, caption: nil, topics: nil, likesCount: commentIncluded.attributes.likesCount,
            voteFlag: commentIncluded.meta.voteFlag, voteId: commentIncluded.meta.voteId,
            bookMarkId: nil, shareUrl: nil, related: nil)

    }
    
    private func commentFrom(commentData: GCoresTalkCommentData) -> TalkCommentCard {
        
        let userId = commentData.relationships.user.data!.id
        let user = findTalkUser(with: userId, from: included!)
        
        var descendants: [String]? = nil
        if let _decendants = commentData.relationships.descendants?.data {
            descendants = _decendants.map({$0.id})
        }
        var oldestDescendants: [String]? = nil
        if let _decendants = commentData.relationships.oldestDescendants?.data {
            oldestDescendants = _decendants.map({$0.id})
        }
        return TalkCommentCard(
            id: commentData.id,
            platform: .gcores,
            user: user,
            _createdAt: DateUtils.dateFromString(string: commentData.attributes.createdAt, platform: .gcores),
            _updatedAt: DateUtils.dateFromString(string: commentData.attributes.createdAt, platform: .gcores),
            edited: false,
            replyTo: nil,
            descendantsCount: commentData.attributes.descendantsCount,
            descendants: descendants ?? [String](),
            oldestDescendants: oldestDescendants ?? [String](),
            depth: commentData.attributes.depth,
            text: commentData.attributes.body,
            images: nil, caption: nil, topics: nil, likesCount: commentData.attributes.likesCount,
            voteFlag: commentData.meta.voteFlag, voteId: commentData.meta.voteId,
            bookMarkId: nil, shareUrl: nil, related: nil)
    }
    
    func formalize() -> [[TalkCommentCard]] {
        var comments = [TalkCommentCard]()
        var replies = [TalkCommentCard]()
        if meta.recordCount == 0 {
            return [comments, replies]
        }
        
        data.forEach { item in
            comments.append(commentFrom(commentData: item))
        }
        if let included = included {
            included.forEach { item in
                if item.type == .comments {
                    replies.append(commentFrom(commentIncluded: item))
                }
                
            }
        }
        return [comments, replies]
    }
}

struct GCoresTalkReplyResponse: Codable {
    struct Data: Codable {
        struct Attributes: Codable {
            let body: String
            let depth: Int
            let likesCount: Int
            let score: Double
            let createdAt: String
            let descendantsCount: Int
            private enum CodingKeys: String, CodingKey {
                case body
                case depth
                case likesCount = "likes-count"
                case score
                case createdAt = "created-at"
                case descendantsCount = "descendants-count"
            }
        }
        struct Relationships: Codable {
            struct User: Codable {
                struct Data: Codable {
                    let type: String
                    let id: String
                }
                let data: Data
            }
            let user: User
            struct Root: Codable {
            }
            let root: Root
            struct Commentable: Codable {
                struct Data: Codable {
                    let type: GCoresRelatedType
                    let id: String
                }
                let data: Data
            }
            let commentable: Commentable
            struct Subcommentable: Codable {
            }
            let subcommentable: Subcommentable
            struct Parent: Codable {
                struct Data: Codable {
                    let type: GCoresRelatedType
                    let id: String
                }
                let data: Data?
            }
            let parent: Parent?
            struct Children: Codable {
            }
            let children: Children
            struct Descendants: Codable {
                struct Data: Codable {
                    let type: GCoresRelatedType
                    let id: String
                }
                let data: [Data]?
            }
            let descendants: Descendants?
            let oldestDescendants: Descendants?
            struct Ancestors: Codable {
            }
            let ancestors: Ancestors
            private enum CodingKeys: String, CodingKey {
                case user
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
        struct Meta: Codable {
            let voteFlag: Bool?
            let voteId: String?
            private enum CodingKeys: String, CodingKey {
                case voteFlag = "vote-flag"
                case voteId = "vote-id"
            }
        }
        let id: String
        let type: GCoresRelatedType
        let attributes: Attributes
        let relationships: Relationships
        let meta: Meta
    }
    struct Included: Codable {
        let id: String
        let type: GCoresRelatedType
        struct Attributes: Codable {
            let body: String?
            let depth: Int?
            let likesCount: Int?
            let score: Double?
            let createdAt: String?
            let descendantsCount: Int?
            let nickname: String?
            let cover: String?
            let desc: String?
            let description: String?
            let thumb: String?
            let location: String?
            let isFresh: Bool?
            let intro: String?
            let sex: Int?
            let followersCount: Int?
            let followeesCount: Int?
            let psnId: String?
            let liveId: String?
            let nintendoFriendcode: String?
            let steamId: String?
            let isDeleted: Bool?
            let isTreated: Bool?
            let disableImageDownload: Bool?
            let title: String?
            let content: String?
            let updatedAt: String?
            let commentsCount: Int?
            let auditState: String?
            let publishedAt: String?
            let isEditorSelected: Bool?
            private enum CodingKeys: String, CodingKey {
                case body
                case depth
                case likesCount = "likes-count"
                case score
                case createdAt = "created-at"
                case descendantsCount = "descendants-count"
                case nickname
                case cover
                case desc
                case description
                case thumb
                case location
                case isFresh = "is-fresh"
                case intro
                case sex
                case followersCount = "followers-count"
                case followeesCount = "followees-count"
                case psnId = "psn-id"
                case liveId = "live-id"
                case nintendoFriendcode = "nintendo-friendcode"
                case steamId = "steam-id"
                case isDeleted = "is-deleted"
                case isTreated = "is-treated"
                case disableImageDownload = "disable-image-download"
                case title
                case content
                case updatedAt = "updated-at"
                case commentsCount = "comments-count"
                case auditState = "audit-state"
                case publishedAt = "published-at"
                case isEditorSelected = "is-editor-selected"
            }
        }
        let attributes: Attributes
        struct Relationships: Codable {
            struct User: Codable {
                struct Data: Codable {
                    let type: GCoresRelatedType
                    let id: String
                }
                let data: Data?
            }
            let user: User?
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
                struct Data: Codable {
                    let type: GCoresRelatedType
                    let id: String
                }
                let data: Data?
            }
            let parent: Parent?
            struct Children: Codable {
            }
            let children: Children?
            struct Descendants: Codable {
                struct Data: Codable {
                    let type: GCoresRelatedType
                    let id: String
                }
                let data: [Data]?
            }
            let descendants: Descendants?
            let oldestDescendants: Descendants?
            struct Ancestors: Codable {
            }
            let ancestors: Ancestors?
            struct Talks: Codable {
            }
            let talks: Talks?
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
            struct Preference: Codable {
            }
            let preference: Preference?
            struct Bookmarks: Codable {
            }
            let bookmarks: Bookmarks?
            struct Subscriptions: Codable {
            }
            let subscriptions: Subscriptions?
            struct Tickets: Codable {
            }
            let tickets: Tickets?
            struct GiveawayRecords: Codable {
            }
            let giveawayRecords: GiveawayRecords?
            struct UserAnnualSummary: Codable {
            }
            let userAnnualSummary: UserAnnualSummary?
            struct Topic: Codable {
            }
            let topic: Topic?
            struct Comments: Codable {
            }
            let comments: Comments?
            struct UpVoters: Codable {
            }
            let upVoters: UpVoters?
            struct Games: Codable {
            }
            let games: Games?
            private enum CodingKeys: String, CodingKey {
                case user
                case root
                case commentable
                case subcommentable
                case parent
                case children
                case descendants
                case oldestDescendants = "oldest-descendants"
                case ancestors
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
                case topic
                case comments
                case upVoters = "up-voters"
                case games
            }
        }
        let relationships: Relationships
        struct Meta: Codable {
            let voteFlag: Bool?
            let voteId: String?
            let followshipId: String?
            let inverseFollowshipId: String?
            let bookmarkId: String?
            private enum CodingKeys: String, CodingKey {
                case voteFlag = "vote-flag"
                case voteId = "vote-id"
                case followshipId = "followship-id"
                case inverseFollowshipId = "inverse-followship-id"
                case bookmarkId = "bookmark-id"
            }
        }
        let meta: Meta
    }
    let data: Data
    let included: [Included]?
    var target: Data.Relationships.Commentable.Data {
        return data.relationships.commentable.data
    }
    func findTalkUser(with id: String, from included: [Included]) -> TalkUser {
        let data = included.first(where: {$0.id == id && $0.type == .users})!
        let nickname = data.attributes.nickname ?? "nil"
        var src: String
        if let thumb = data.attributes.thumb {
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
            location: data.attributes.location,
            isFresh: data.attributes.isFresh,
            intro: data.attributes.intro,
            sex: data.attributes.sex,
            followersCount: data.attributes.followersCount,
            followeesCount: data.attributes.followeesCount,
            _createdAt: DateUtils.dateFromString(string: data.attributes.createdAt!, platform: .gcores),
            psnId: data.attributes.psnId,
            liveId: data.attributes.liveId,
            nintendoFriendcode: data.attributes.nintendoFriendcode,
            steamId: data.attributes.steamId,
            isDeleted: data.attributes.isDeleted,
            isTreated: data.attributes.isTreated,
            followshipId: data.meta.followshipId,
            inverseFollowshipId: data.meta.inverseFollowshipId,
            _notificationFeedsLastSeenAt: nil,
            notificationFeedsUnseenCount: nil,
            _subscriptionFeedsLastSeenAt: nil,
            subscriptionFeedsUnseenCount: nil,
            _topicFeedsLastSeenAt: nil,
            topicFeedsUnseenCount: nil,
            privateMailsUnreadCount: nil
        )
    }
    private func commentFrom(commentData: Data) -> TalkCommentCard {
        
        let userId = commentData.relationships.user.data.id
        let user = findTalkUser(with: userId, from: included!)
        
        var descendants: [String]? = nil
        if let _decendants = commentData.relationships.descendants?.data {
            descendants = _decendants.map({$0.id})
        }
        var oldestDescendants: [String]? = nil
        if let _decendants = commentData.relationships.oldestDescendants?.data {
            oldestDescendants = _decendants.map({$0.id})
        }
        return TalkCommentCard(
            id: commentData.id,
            platform: .gcores,
            user: user,
            _createdAt: DateUtils.dateFromString(string: commentData.attributes.createdAt, platform: .gcores),
            _updatedAt: DateUtils.dateFromString(string: commentData.attributes.createdAt, platform: .gcores),
            edited: false,
            replyTo: nil,
            descendantsCount: commentData.attributes.descendantsCount,
            descendants: descendants ?? [String](),
            oldestDescendants: oldestDescendants ?? [String](),
            depth: commentData.attributes.depth,
            text: commentData.attributes.body,
            images: nil, caption: nil, topics: nil, likesCount: commentData.attributes.likesCount,
            voteFlag: commentData.meta.voteFlag, voteId: commentData.meta.voteId,
            bookMarkId: nil, shareUrl: nil, related: nil)

    }
    private func commentFrom(commentIncluded: Included) -> TalkCommentCard {
        
        let userId = commentIncluded.relationships.user!.data!.id
        let user = findTalkUser(with: userId, from: included!)
        var descendants: [String]? = nil
        if let _decendants = commentIncluded.relationships.descendants?.data {
            descendants = _decendants.map({$0.id})
        }
        var oldestDescendants: [String]? = nil
        if let _decendants = commentIncluded.relationships.oldestDescendants?.data {
            oldestDescendants = _decendants.map({$0.id})
        }
        return TalkCommentCard(
            id: commentIncluded.id,
            platform: .gcores,
            user: user,
            _createdAt: DateUtils.dateFromString(string: commentIncluded.attributes.createdAt!, platform: .gcores),
            _updatedAt: DateUtils.dateFromString(string: commentIncluded.attributes.createdAt!, platform: .gcores),
            edited: false,
            replyTo: commentIncluded.relationships.parent?.data?.id,
            descendantsCount: commentIncluded.attributes.descendantsCount,
            descendants: descendants ?? [String](),
            oldestDescendants: oldestDescendants ?? [String](),
            depth: commentIncluded.attributes.depth!,
            text: commentIncluded.attributes.body!,
            images: nil, caption: nil, topics: nil, likesCount: commentIncluded.attributes.likesCount,
            voteFlag: commentIncluded.meta.voteFlag, voteId: commentIncluded.meta.voteId,
            bookMarkId: nil, shareUrl: nil, related: nil)

    }
    
    func getRelated() -> TalkRelated? {
        let commentable = data.relationships.commentable.data
        switch commentable.type {
        case .articles, .games, .radios, .videos:
            if let includedData = included?.first(where: { $0.id == commentable.id && $0.type == commentable.type}) {
                let id = includedData.id
                let title = includedData.attributes.title
                let desc = includedData.attributes.desc
                let description = includedData.attributes.description
                var cover: String?
                if let src = includedData.attributes.cover {
                    cover = GCORES_IMAGE_HOST + src
                } else if let src = includedData.attributes.thumb {
                    cover = GCORES_IMAGE_HOST + src
                } else {
                    cover = nil
                }
                return TalkRelated(id: id, type: includedData.type, title: title, desc: desc ?? description, cover: cover, banner: nil, contentString: nil)
            } else {
                return nil
            }
        default:
            return nil
        }
    }

    func formalize() -> [[TalkCommentCard]] {
        var comment: TalkCommentCard
        var replies = [TalkCommentCard]()
        
        comment = commentFrom(commentData: data)
        if let included = included {
            included.forEach { item in
                if item.type == .comments {
                    replies.append(commentFrom(commentIncluded: item))
                }
                
            }
        }
        return [[comment], replies]
    }
}


struct NewCommentResponse: Codable {
    struct Data: Codable {
        let id: String
        let type: GCoresRelatedType
        struct Attributes: Codable {
            let body: String
            let depth: Int
            let likesCount: Int
            let score: Int
            let createdAt: String
            let descendantsCount: Int
            private enum CodingKeys: String, CodingKey {
                case body
                case depth
                case likesCount = "likes-count"
                case score
                case createdAt = "created-at"
                case descendantsCount = "descendants-count"
            }
        }
        let attributes: Attributes
        struct Relationships: Codable {
            struct User: Codable {
                struct Data: Codable {
                    let type: String
                    let id: String
                }
                let data: Data
            }
            let user: User
            struct Root: Codable {
            }
            let root: Root
            struct Commentable: Codable {
                struct Data: Codable {
                    let type: String
                    let id: String
                }
                let data: Data
            }
            let commentable: Commentable
            struct Subcommentable: Codable {
            }
            let subcommentable: Subcommentable
            struct Parent: Codable {
                struct Data: Codable {
                    let type: String
                    let id: String
                }
                let data: Data?
                
            }
            let parent: Parent
            struct Children: Codable {
            }
            let children: Children
            struct Descendants: Codable {
                struct Data: Codable {
                    let type: GCoresRelatedType
                    let id: String
                }
                let data: [Data]?
            }
            let descendants: Descendants?
            let oldestDescendants: Descendants?
            struct Ancestors: Codable {
            }
            let ancestors: Ancestors
            private enum CodingKeys: String, CodingKey {
                case user
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
            let voteFlag: Bool?
            let voteId: String?
            private enum CodingKeys: String, CodingKey {
                case voteFlag = "vote-flag"
                case voteId = "vote-id"
            }
        }
        let meta: Meta
    }

    struct Included: Codable {
        let id: String
        let type: GCoresRelatedType
        struct Attributes: Codable {
            let body: String?
            let depth: Int?
            let likesCount: Int?
            let score: Double?
            let createdAt: String?
            let descendantsCount: Int?
            let nickname: String?
            let thumb: String?
            let location: String?
            let isFresh: Bool?
            let intro: String?
            let sex: Int?
            let followersCount: Int?
            let followeesCount: Int?
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
            let commentsCount: Int?
            let auditState: String?
            let publishedAt: String?
            let isEditorSelected: Bool?
            private enum CodingKeys: String, CodingKey {
                case body
                case depth
                case likesCount = "likes-count"
                case score
                case createdAt = "created-at"
                case descendantsCount = "descendants-count"
                case nickname
                case thumb
                case location
                case isFresh = "is-fresh"
                case intro
                case sex
                case followersCount = "followers-count"
                case followeesCount = "followees-count"
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
                case commentsCount = "comments-count"
                case auditState = "audit-state"
                case publishedAt = "published-at"
                case isEditorSelected = "is-editor-selected"
            }
        }
        let attributes: Attributes
        struct Relationships: Codable {
            struct User: Codable {
                struct Data: Codable {
                    let type: String
                    let id: String
                }
                let data: Data?
            }
            let user: User?
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
                struct Data: Codable {
                    let type: String
                    let id: String
                }
                let data: Data?
            }
            let parent: Parent?
            struct Children: Codable {
            }
            let children: Children?
            struct Descendants: Codable {
                struct Data: Codable {
                    let type: GCoresRelatedType
                    let id: String
                }
                let data: [Data]?
            }
            let descendants: Descendants?
            let oldestDescendants: Descendants?
            struct Ancestors: Codable {
            }
            let ancestors: Ancestors?
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
            struct UpVoters: Codable {
            }
            let upVoters: UpVoters?
            struct Games: Codable {
            }
            let games: Games?
            private enum CodingKeys: String, CodingKey {
                case user
                case root
                case commentable
                case subcommentable
                case parent
                case children
                case descendants
                case oldestDescendants = "oldest-descendants"
                case ancestors
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
                case upVoters = "up-voters"
                case games
            }
        }
        let relationships: Relationships
        struct Meta: Codable {
            let voteFlag: Bool?
            let voteId: String?
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
            let bookmarkId: String?
            private enum CodingKeys: String, CodingKey {
                case voteFlag = "vote-flag"
                case voteId = "vote-id"
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
                case bookmarkId = "bookmark-id"
            }
        }
        let meta: Meta
    }
    let data: Data
    let included: [Included]?
    
    private func findTalkUser(with id: String, from included: [Included]) -> TalkUser {
        let data = included.first(where: {$0.id == id && $0.type == .users})!
        let nickname = data.attributes.nickname ?? "nil"
        var src: String
        if let thumb = data.attributes.thumb {
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
            location: data.attributes.location,
            isFresh: data.attributes.isFresh,
            intro: data.attributes.intro,
            sex: data.attributes.sex,
            followersCount: data.attributes.followersCount,
            followeesCount: data.attributes.followeesCount,
            _createdAt: DateUtils.dateFromString(string: data.attributes.createdAt!, platform: .gcores),
            psnId: data.attributes.psnId,
            liveId: data.attributes.liveId,
            nintendoFriendcode: data.attributes.nintendoFriendcode,
            steamId: data.attributes.steamId,
            isDeleted: data.attributes.isDeleted,
            isTreated: data.attributes.isTreated,
            followshipId: data.meta.followshipId,
            inverseFollowshipId: data.meta.inverseFollowshipId,
            _notificationFeedsLastSeenAt: nil,
            notificationFeedsUnseenCount: nil,
            _subscriptionFeedsLastSeenAt: nil,
            subscriptionFeedsUnseenCount: nil,
            _topicFeedsLastSeenAt: nil,
            topicFeedsUnseenCount: nil,
            privateMailsUnreadCount: nil
        )
    }

    private func commentFrom(commentData: Data) -> TalkCommentCard {
        
        let userId = commentData.relationships.user.data.id
        let user = findTalkUser(with: userId, from: included!)
        
        var descendants: [String]? = nil
        if let _decendants = commentData.relationships.descendants?.data {
            descendants = _decendants.map({$0.id})
        }
        var oldestDescendants: [String]? = nil
        if let _decendants = commentData.relationships.oldestDescendants?.data {
            oldestDescendants = _decendants.map({$0.id})
        }
        return TalkCommentCard(
            id: commentData.id,
            platform: .gcores,
            user: user,
            _createdAt: DateUtils.dateFromString(string: commentData.attributes.createdAt, platform: .gcores),
            _updatedAt: DateUtils.dateFromString(string: commentData.attributes.createdAt, platform: .gcores),
            edited: false,
            replyTo: nil,
            descendantsCount: commentData.attributes.descendantsCount,
            descendants: descendants ?? [String](),
            oldestDescendants: oldestDescendants ?? [String](),
            depth: commentData.attributes.depth,
            text: commentData.attributes.body,
            images: nil, caption: nil, topics: nil, likesCount: commentData.attributes.likesCount,
            voteFlag: commentData.meta.voteFlag, voteId: commentData.meta.voteId,
            bookMarkId: nil, shareUrl: nil, related: nil)

    }
    func formalize() -> TalkCommentCard {
        return commentFrom(commentData: data)
    }
}

