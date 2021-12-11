//
//  GCoresSearchData.swift
//  GCoresTalk
//
//  Created by catbaron on 2021/12/10.
//

import Foundation

struct GCoresSearchResponse: Codable {
    struct Data: Codable {
        let id: String
        let type: GCoresRelatedType
        let attributes: Attributes
        struct Attributes: Codable {
            let title: String
            let desc: String?
            let description: String?
            let cover: String?
            let thumb: String?
        }
    }
    
    struct Meta: Codable {
        let recordCount: Int
        private enum CodingKeys: String, CodingKey {
            case recordCount = "record-count"
        }
    }
    let data: [Data]
    let meta: Meta
    
    func formalize() -> [TalkRelated] {
        var searchResults = [TalkRelated]()
        data.forEach { _data in
            let id = _data.id
            let title = _data.attributes.title
            let desc = _data.attributes.desc
            let description = _data.attributes.description
            var cover: String?
            if let src = _data.attributes.cover {
                cover = GCORES_IMAGE_HOST + src
            } else if let src = _data.attributes.thumb {
                cover = GCORES_IMAGE_HOST + src
            } else {
                cover = nil
            }
            searchResults.append(
                TalkRelated(id: id, type: _data.type, title: title, desc: desc ?? description, cover: cover, banner: nil, contentString: nil)
            )
            
        }
        return searchResults
    }
}
