//
//  GCoresTalk.swift
//  GCoresTalk
//
//  Created by catbaron on 2021/12/01.
//

import Foundation


// MARK: GCoresTalk talk data
struct GCoresTalkDataAttributes: Decodable {
    let title: String?
    let contentString: String?
    let createdAt: String?
    let updatedAt: String?
    let likesCount: Int?
    let commentsCount: Int?
    let score: Float?
    let auditState: String?
    let publishedAt: String?
    let isEditorSelected: Bool?
    
    enum CodingKeys: String, CodingKey {
        case title
        case contentString = "content"
        case createdAt = "created-at"
        case updatedAt = "updated-at"
        case likesCount = "likes-count"
        case commentsCount = "comments-count"
        case score
        case auditState = "audit-state"
        case publishedAt = "published-at"
        case isEditorSelected = "is-editor-selected"
    }
    
    var content: Content? {
        guard let jsonData = self.contentString?.data(using: .utf8) else {
            return nil
        }
        return try! JSONDecoder().decode(Content.self, from: jsonData)
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
}

struct GCoresTalkIncludedAttributes: Decodable {
    // The properties varies with types, so most of them should be optional
    
    
    // For type of articles/videos
    let title: String?
    let content: String?
    let desc: String?
    let isVerified: Int?
    let createdAt: String?
    let duration: Int?
    let thumb: String?
    //  let appCover: Bool?
    let cover: String?
    let optionIsFocusShowcase: Bool?
    let optionIsOfficial: Bool?
    let isPublished: Int?
    let publishedAt: String?
    let bookmarksCount: Int?
    let isCommentHidden: Bool?
    let isModified: Bool?
    let isOfficial: Bool?
    let speechPath: String?
    let authorModifiedAt: String?
    let isListable: Bool?
    // let vol: Any?
    let likesCount: Int?
    let commentsCount: Int?
    let isFree: Bool?
    let hasGiveaway: Bool?
    
    // For type of users
    let nickname: String?
    // let thumb: String?
    let location: String?
    let isFresh: Bool?
    let intro: String?
    let sex: Int?
    let followersCount: Int?
    let followeesCount: Int?
    let followshipId: String?
    let inverseFollowshipId: String?
    let psnId: String?
    let liveId: String?
    let nintendoFriendcode: String?
    let steamId: String?
    let isDeleted: Bool?
    let isTreated: Bool?
    let disableImageDownload: Bool?
    
    // For type of topics
    struct previewImage: Decodable {
        let type: String?
        let src: String?
        let content: String?
    }
    //    let title: String?
    //    let desc: String?
    //    let cover: String?
    //    let isPublished: Int?
    //    let publishedAt: String?
    //    let createdAt: String?
    let updatedAt: String?
    let participantsCount: Int?
    let banner: String?
    let lastContributedAt: String?
    let preview: [previewImage]?
    // let isTreated: Bool?
    // let hasGiveAway: Bool?
    
    // For type of games
    // title
    let description: String?
    // cover
    let releasedAt: String?
    let demosticReleasedAt: String?
    // createdAt
    // updatedAt
    let modifiedAt: String?
    let isBoom: Bool?
    let officialNames: [String]?
    let otherNames: [String]?
    let isbn: Bool?
    // let episodes: Any?
    let screenshots: [String]?
    let subscriptionsCount: Int?
    let reviewsCount: Int?
    // let myReviewId: Any?
    let revised: Bool?
    // let trailers: Any?
    
    enum CodingKeys: String, CodingKey {
        case title, content, desc, duration, thumb, cover
        case isVerified = "is-verified"
        case createdAt = "created-at"
        case optionIsFocusShowcase = "option-is-focus-showcase"
        case optionIsOfficial = "option-is-official"
        case isPublished = "is-published"
        case publishedAt = "published-at"
        case bookmarksCount = "bookmarks-count"
        case isCommentHidden = "is-cooment-hidden"
        case isModified = "is-modified"
        case isOfficial = "is-official"
        case speechPath = "speech-path"
        case authorModifiedAt = "author-modified-at"
        case isListable = "is-listable"
        case likesCount = "likes-count"
        case commentsCount = "comments-count"
        case isFree = "is-free"
        case hasGiveaway = "has-giveaway"
        
        case nickname, location, intro, sex
        case isFresh = "is-fresh"
        case followersCount = "followers-count"
        case followeesCount = "followees-count"
        case psnId = "psn-id"
        case liveId = "live-id"
        case nintendoFriendcode = "nintendo-friendcode"
        case steamId = "steam-id"
        case isDeleted = "is-deleted"
        case isTreated = "is-treated"
        case disableImageDownload = "disable-image-download"
        case followshipId = "followship-id"
        case inverseFollowshipId = "inverse-followship-id"
        
        case updatedAt = "updated-at"
        case participantsCount = "participants-count"
        case banner, preview
        case lastContributedAt = "last-contributed-at"
        
        case description
        case releasedAt = "released-at"
        case demosticReleasedAt = "demostic-released-at"
        case modifiedAt = "modified-at"
        case isBoom = "is-boom"
        case officialNames = "official-names"
        case otherNames = "other-names"
        case isbn, screenshots, revised
        case subscriptionsCount = "subscriptions-count"
        case reviewsCount = "reviews-count"
    }
}

struct GCoresTalkIncludedRelationships: Decodable {
    // No Need For Now
}


struct GCoresTalkData: Decodable{
    struct GCoresTalkDataRelationships: Codable {
        let topic: GCoresIDAndTypeData?
        let user: GCoresIDAndTypeData
        let games: GCoresIDAndTypeDataList?
        let radios: GCoresIDAndTypeDataList?
        let articles: GCoresIDAndTypeDataList?
        let videos: GCoresIDAndTypeDataList?
    }
    
    struct Meta: Decodable {
        let voteFlag: Bool?
        let voteId: String?
        let bookmarkId: String?
        
        enum CodingKeys: String, CodingKey {
            case voteFlag = "vote-flag"
            case voteId = "vote-id"
            case bookmarkId = "bookmark-id"
        }
    }
    
    let id: String
    let type: GCoresRelatedType
    let attributes: GCoresTalkDataAttributes
    let relationships: GCoresTalkDataRelationships
    let meta: Meta
}

struct GCoresTalkIncluded: Decodable {
    // types: users, articles, topics, videos, radios, games, comments
    // attributes and relationships varies with types
    let id: String
    let type: GCoresRelatedType
    let attributes: GCoresTalkIncludedAttributes
    
    // relationships is not necessary for now
    //  let relationships: GCoresTalkIncludedRelationships
}

struct GCoresTalksResponse: Decodable {
    let data: [GCoresTalkData]
    let included: [GCoresTalkIncluded]?
    
    func findTalkUser(with id: String, from included: [GCoresTalkIncluded]) -> TalkUser {
        let data = included.first(where: {$0.id == id && $0.type == .users})!
        let nickname = data.attributes.nickname ?? "nil"
        var src: String
        if let thumb = data.attributes.thumb {
            src = GCORES_IMAGE_HOST + thumb + GCORES_IMAGE_SCALE_SETTING
        } else {
            src = GCORES_DEFAULT_PROFILE_URL
        }
        
        let profile = TalkImage(src: src, isSpoiler: false, width: 60, height: 60, downloadable: true )
        return TalkUser(
            id: id,
            nickname: nickname,
            profile: profile,
            downloadable: !(data.attributes.disableImageDownload ?? false),
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
            followshipId: data.attributes.followshipId,
            inverseFollowshipId: data.attributes.inverseFollowshipId,
            _notificationFeedsLastSeenAt: nil,
            notificationFeedsUnseenCount: nil,
            _subscriptionFeedsLastSeenAt: nil,
            subscriptionFeedsUnseenCount: nil,
            _topicFeedsLastSeenAt: nil,
            topicFeedsUnseenCount: nil,
            privateMailsUnreadCount: nil
        )
    }
    
    func formalize() -> [TalkCard]{
        var talkCards = [TalkCard]()
        for talkItem in data {
            let talkCardId = talkItem.id
            
            // Find the user from included
            let userId = talkItem.relationships.user.data!.id
            let user = findTalkUser(with: userId, from: included!)
            
            // Datetimes
            let createdAt = DateUtils.dateFromString(string: talkItem.attributes.createdAt!, platform: .gcores)
            var _updatedAt = talkItem.attributes.updatedAt
            if _updatedAt == nil  {
                _updatedAt = talkItem.attributes.createdAt
            }
            let updatedAt = DateUtils.dateFromString(string: _updatedAt!, platform: .gcores)
            
            // tags
            var topics = [TalkRelated]()
            if let topicId = talkItem.relationships.topic?.data?.id {
                let includedTopic = included!.first(where: {$0.id == topicId && $0.type == .topics})
                topics.append(TalkRelated(
                    id: topicId,
                    type: .topics,
                    title: (includedTopic?.attributes.title)!,
                    desc: includedTopic?.attributes.desc,
                    cover: includedTopic?.attributes.cover,
                    banner: includedTopic?.attributes.banner,
                    contentString: nil
                ))
            }
            
            let likesCount = talkItem.attributes.likesCount
            let commentsCount = talkItem.attributes.commentsCount
            
            // contents and images
            var images: [TalkImage]?
            var caption: String?
            let entityMap = talkItem.attributes.content?.entityMap
            let downloadable = user.downloadable
            if let entityMap = entityMap, !entityMap.isEmpty {
                if let imgData = entityMap["0"]?.data {
                    caption = imgData.caption
                    images = [TalkImage]()
                    if let path = imgData.path, entityMap["0"]!.type == "IMAGE" {
                        let src = GCORES_IMAGE_HOST + path
                        let width = 600
                        let height = 600
                        images?.append(TalkImage(src: src, isSpoiler: false, width: width, height: height, downloadable: downloadable))
                    }
                    if let _ = imgData.images {
                        for img in imgData.images! {
                            let src = GCORES_IMAGE_HOST + img.path
                            let width = img.width ?? 600
                            let height = img.height ?? 600
                            images?.append(TalkImage(src: src, isSpoiler: false, width: width, height: height, downloadable: downloadable))
                        }
                    }
                    
                }
            }
            // text
            var texts = [TalkText]()
            if let blocks = talkItem.attributes.content?.blocks {
                for idx in 0..<blocks.count {
                    let block = blocks[idx]
                    // There may be multiple pice of text on one talkcard
                    // An id is needed for ForEach view
                    if let images = images, !images.isEmpty, idx == 0 {
                        continue
                    }
                    let textId = "\(talkItem.id)-text-\(idx)"
                    texts.append(TalkText(id: textId, content: block.text, isSpoiler: block.data.spoiler ?? false))
                }
            }

            // Related
            var talkRelated: TalkRelated?
            for related in [
                talkItem.relationships.games,
                talkItem.relationships.radios,
                talkItem.relationships.articles,
                talkItem.relationships.videos
            ] {
                if let relatedData = related?.data, !relatedData.isEmpty {
                    // find in related
                    let relatedContent = included!.first { $0.id == relatedData[0].id && $0.type == relatedData[0].type}!
                    var desc = ""
                    if let descStr = relatedContent.attributes.description {
                        desc = descStr
                    } else if let descStr = relatedContent.attributes.desc {
                        desc = descStr
                    }
                    var cover: String? = nil
                    if let src = relatedContent.attributes.thumb {
                        cover = GCORES_IMAGE_HOST + src
                    } else if let src = relatedContent.attributes.cover {
                        cover = GCORES_IMAGE_HOST + src
                    }
                    talkRelated = TalkRelated(id: relatedContent.id, type: relatedContent.type, title: relatedContent.attributes.title, desc: desc, cover: cover, banner: relatedContent.attributes.banner, contentString: relatedContent.attributes.content
                    )
                }
            }
            
            let talkCard = TalkCard(
                id: talkCardId,
                platform: .gcores,
                user: user,
                _createdAt: createdAt,
                _updatedAt: updatedAt,
                edited: false,
                texts: texts,
                images: images,
                caption: caption,
                topics: topics,
                likesCount: likesCount,
                voteFlag: talkItem.meta.voteFlag,
                voteId: talkItem.meta.voteId,
                bookMarkId: talkItem.meta.bookmarkId,
                commentsCount: commentsCount,
                shareUrl: nil,
                related: talkRelated
            )
            talkCards.append(talkCard)
        }
        return talkCards
    }
}

struct GCoresTalkResponse: Decodable {
    let data: GCoresTalkData
    let included: [GCoresTalkIncluded]?
    
    func findTalkUser(with id: String, from included: [GCoresTalkIncluded]) -> TalkUser {
        let data = included.first(where: {$0.id == id && $0.type == .users})!
        let nickname = data.attributes.nickname ?? "nil"
        var src: String
        if let thumb = data.attributes.thumb {
            src = GCORES_IMAGE_HOST + thumb + GCORES_IMAGE_SCALE_SETTING
        } else {
            src = GCORES_DEFAULT_PROFILE_URL
        }
        
        let profile = TalkImage(src: src, isSpoiler: false, width: 60, height: 60, downloadable: true )
        return TalkUser(
            id: id,
            nickname: nickname,
            profile: profile,
            downloadable: !(data.attributes.disableImageDownload ?? false),
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
            followshipId: data.attributes.followshipId,
            inverseFollowshipId: data.attributes.inverseFollowshipId,
            _notificationFeedsLastSeenAt: nil,
            notificationFeedsUnseenCount: nil,
            _subscriptionFeedsLastSeenAt: nil,
            subscriptionFeedsUnseenCount: nil,
            _topicFeedsLastSeenAt: nil,
            topicFeedsUnseenCount: nil,
            privateMailsUnreadCount: nil
        )
    }
    
    func formalize() -> TalkCard {
        var talkCard: TalkCard
        
        // Find the user from included
        let userId = data.relationships.user.data!.id
        let user = findTalkUser(with: userId, from: included!)
        
        // Datetimes
        let createdAt = DateUtils.dateFromString(string: data.attributes.createdAt!, platform: .gcores)
        var _updatedAt = data.attributes.updatedAt
        if _updatedAt == nil  {
            _updatedAt = data.attributes.createdAt
        }
        let updatedAt = DateUtils.dateFromString(string: _updatedAt!, platform: .gcores)
        
        // tags
        var topics = [TalkRelated]()
        if let topicId = data.relationships.topic?.data?.id {
            let includedTopic = included!.first(where: {$0.id == topicId && $0.type == .topics})
            topics.append(TalkRelated(
                id: topicId,
                type: .topics,
                title: (includedTopic?.attributes.title)!,
                desc: includedTopic?.attributes.desc,
                cover: includedTopic?.attributes.cover,
                banner: includedTopic?.attributes.banner,
                contentString: nil
            ))
        }
        
        let likesCount = data.attributes.likesCount
        let commentsCount = data.attributes.commentsCount
        
        // contents and images
        var images: [TalkImage]?
        var caption: String?
        let entityMap = data.attributes.content?.entityMap
        let downloadable = user.downloadable
        if let entityMap = entityMap, !entityMap.isEmpty {
            if let imgData = entityMap["0"]?.data {
                caption = imgData.caption
                images = [TalkImage]()
                if let path = imgData.path, entityMap["0"]!.type == "IMAGE" {
                    let src = GCORES_IMAGE_HOST + path
                    let width = 600
                    let height = 600
                    images?.append(TalkImage(src: src, isSpoiler: false, width: width, height: height, downloadable: downloadable))
                }
                if let _ = imgData.images {
                    for img in imgData.images! {
                        let src = GCORES_IMAGE_HOST + img.path
                        let width = img.width ?? 600
                        let height = img.height ?? 600
                        images?.append(TalkImage(src: src, isSpoiler: false, width: width, height: height, downloadable: downloadable))
                    }
                }
                
            }
        }
        // text
        var texts = [TalkText]()
        if let blocks = data.attributes.content?.blocks {
            for idx in 0..<blocks.count {
                let block = blocks[idx]
                // There may be multiple pice of text on one talkcard
                // An id is needed for ForEach view
                if let images = images, !images.isEmpty, idx == 0 {
                    continue
                }
                let textId = "\(data.id)-text-\(idx)"
                texts.append(TalkText(id: textId, content: block.text, isSpoiler: block.data.spoiler ?? false))
            }
        }
        
        // Related
        var talkRelated: TalkRelated?
        for related in [
            data.relationships.games,
            data.relationships.radios,
            data.relationships.articles,
            data.relationships.videos
        ] {
            if let relatedData = related?.data, !relatedData.isEmpty {
                // find in related
                let relatedContent = included!.first { $0.id == relatedData[0].id && $0.type == relatedData[0].type}!
                var desc = ""
                if let descStr = relatedContent.attributes.description {
                    desc = descStr
                } else if let descStr = relatedContent.attributes.desc {
                    desc = descStr
                }
                var cover: String? = nil
                if let src = relatedContent.attributes.thumb {
                    cover = GCORES_IMAGE_HOST + src
                } else if let src = relatedContent.attributes.cover {
                    cover = GCORES_IMAGE_HOST + src
                }
                talkRelated = TalkRelated(id: relatedContent.id, type: relatedContent.type, title: relatedContent.attributes.title, desc: desc, cover: cover, banner: relatedContent.attributes.banner, contentString: relatedContent.attributes.content
                )
            }
        }
        
        talkCard = TalkCard(
            id: data.id,
            platform: .gcores,
            user: user,
            _createdAt: createdAt,
            _updatedAt: updatedAt,
            edited: false,
            texts: texts,
            images: images,
            caption: caption,
            topics: topics,
            likesCount: likesCount,
            voteFlag: data.meta.voteFlag,
            voteId: data.meta.voteId,
            bookMarkId: data.meta.bookmarkId,
            commentsCount: commentsCount,
            shareUrl: nil,
            related: talkRelated
        )
        return talkCard
    }
}
