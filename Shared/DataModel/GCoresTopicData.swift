//
//  GCoresTopicData.swift
//  GCoresTalk
//
//  Created by catbaron on 2021/12/01.
//

import Foundation

struct GCoresTopicCategoryResponse: Codable {
    struct Meta: Codable {
        let recordCount: Int?
        
        enum CondingKeys: String, CodingKey {
            case recordCount = "record-count"
        }
    }
    
    struct Data: Codable {
        struct Meta: Codable {
            let subscriptionId: String?
            let subscriptionWeight: Float?
            
            enum CodingKeys: String, CodingKey {
                case subscriptionId = "subscription-id"
                case subscriptionWeight = "subscription-weight"
            }
        }
        
        struct Attributes: Codable {
            let name: String
            let desc: String?
            let logo: String?
            let background: String?
            let createdAt: String
            let updatedAt: String
            let subscriptionCount: Int?
            let scope: String
            
            enum CodingKeys: String, CodingKey {
                case name, desc, logo, background, scope
                case createdAt = "created-at"
                case updatedAt = "updated-at"
                case subscriptionCount = "subscription-count"
            }
        }
        
        let id: String
        let type: GCoresRelatedType
        let attributes: Attributes
        let meta: Meta
    }
    
    let data: [Data]
    let meta: Meta
    
    func formalize() -> [TalkTopicCategory] {
        var topicCategory = [TalkTopicCategory]()
        data.forEach { _category in
            topicCategory.append(
                TalkTopicCategory(
                    id: _category.id,
                    name: _category.attributes.name,
                    desc: _category.attributes.name,
                    logo: _category.attributes.logo,
                    background: _category.attributes.background
//                    tags: [TalkTag]()
                )
            )
        }
        return topicCategory
    }
    
}

struct GCoresTopicResponse: Codable {
    struct Meta: Codable {
        let recordCount: Int?
        
        enum CondingKeys: String, CodingKey {
            case recordCount = "record-count"
        }
    }
    
    struct Data: Codable {
        struct Meta: Codable {
            let subscriptionId: String?
            let subscriptionWeight: Float?
            let isContentBlocked: Bool

            enum CodingKeys: String, CodingKey {
                case subscriptionId = "subscription-id"
                case subscriptionWeight = "subscription-weight"
                case isContentBlocked = "is-content-blocked"
            }

        }
        
        struct Attributes: Codable {
            struct Section: Codable {
                let type: String
                let title: String
            }
            struct Preview: Codable {
                let type: String?
                let src: String?
            }
            let title: String
            let desc: String?
            let cover: String?
            let isPublished: Int
            let publishedAt: String
            let createdAt: String
            let updatedAt: String
            let participantsCount: Int
            let banner: String?
            let latestContributedAt: String?
            let customSection: [Section]
            let preview: [Preview]?
            let isTreated: Bool
            let hasGiveaway: Bool
            
            enum CodingKeys: String, CodingKey {
                case title, desc, cover, banner, preview
                case isPublished = "is-published"
                case publishedAt = "published-at"
                case createdAt = "created-at"
                case updatedAt = "updated-at"
                case participantsCount = "participants-count"
                case latestContributedAt = "latest-contributed-at"
                case customSection = "custom-section"
                case isTreated = "is-treated"
                case hasGiveaway = "has-giveaway"
            }
        }
        let id: String
        let type: GCoresRelatedType
        let attributes: Attributes
        let meta: Meta
    }
    
    let data: [Data]
    let meta: Meta
    
    func formalize() -> [TalkRelated] {
        var topics = [TalkRelated]()
        data.forEach { _topic in
            topics.append(
                TalkRelated(
                    id: _topic.id,
                    type: .topics,
                    title: _topic.attributes.title,
                    desc: _topic.attributes.desc,
                    cover: _topic.attributes.cover,
                    banner: _topic.attributes.banner,
                    contentString: nil,
                    subscriptionId: _topic.meta.subscriptionId
                )
            )
        }
        return topics
    }
}
