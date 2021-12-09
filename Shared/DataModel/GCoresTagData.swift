//
//  GCoresTagData.swift
//  GCoresTalk
//
//  Created by catbaron on 2021/12/01.
//

import Foundation

struct GCoresTagCategoryResponse: Codable {
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
            let scope: GCoresType
            
            enum CodingKeys: String, CodingKey {
                case name, desc, logo, background, scope
                case createdAt = "created-at"
                case updatedAt = "updated-at"
                case subscriptionCount = "subscription-count"
            }
        }
        
        let id: String
        let type: GCoresType
        let attributes: Attributes
        let meta: Meta
    }
    
    let data: [Data]
    let meta: Meta
    
    func formalize() -> [TalkTagCategory] {
        var talkTagCategory = [TalkTagCategory]()
        data.forEach { _category in
            talkTagCategory.append(
                TalkTagCategory(
                    id: _category.id,
                    name: _category.attributes.name,
                    desc: _category.attributes.name,
                    logo: _category.attributes.logo,
                    background: _category.attributes.background
//                    tags: [TalkTag]()
                )
            )
        }
        return talkTagCategory
    }
    
}

struct GCoresTagResponse: Codable {
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
                let type: GCoresType
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
            let latestContributedAt: String
            let customSection: [Section]
            let preview: [Preview]
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
        let type: GCoresType
        let attributes: Attributes
        let meta: Meta
    }
    
    let data: [Data]
    let meta: Meta
    
    func formalize() -> [TalkTag] {
        var talkTags = [TalkTag]()
        data.forEach { _tag in
            talkTags.append(
                TalkTag(
                    id: _tag.id,
                    title: _tag.attributes.title,
                    desc: _tag.attributes.desc,
                    cover: _tag.attributes.cover,
                    banner: _tag.attributes.banner)
            )
        }
        return talkTags
    }
}
