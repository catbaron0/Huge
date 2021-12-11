//
//  GCoresVote.swift
//  GCoresTalk
//
//  Created by catbaron on 2021/12/07.
//

import Foundation
struct GCoresVoteResponse: Codable {
    struct Data: Codable {
        let id: String
        let type: String
        struct Attributes: Codable {
            let voteFlag: Bool
            let updatedAt: String
            private enum CodingKeys: String, CodingKey {
                case voteFlag = "vote-flag"
                case updatedAt = "updated-at"
            }
        }
        let attributes: Attributes
        struct Relationships: Codable {
            struct Voter: Codable {
            }
            let voter: Voter
            struct Votable: Codable {
            }
            let votable: Votable
        }
        let relationships: Relationships
    }
    let data: Data
}
