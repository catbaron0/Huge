//
//  TalkModel.swift
//  GCoresTalk
//
//  Created by catbaron on 2021/11/26.
//

import Foundation
import Combine

enum AppSize: CGFloat {
    case width = 380
}

enum RequestState: String {
    case succeed
    case failed
    case sending
}
enum Commentable: String {
    case talks
    case comments
}
enum VoteTargetType: String {
    // The type of targets of a vote
    // For now there're only two tpyes
    case comments
    case talks
}
enum Followship: String {
    case follower
    case followee
}

enum TopOffsetTrigger: Int {
    case timeline = 80
    case profile = 180
    case userList = 70
}

let DEFAULT_PROFILE_URL = "https://alioss.gcores.com/page_resources/misc/avatar-default.png"


enum LoginState: String {
    case succeed
    case failed
    case logout
}

struct LoginInfo {
    var userId: String?
    var token: String?
    var cookie: String?
    var loginState: LoginState
}

enum LoadingStatus: String {
    case loading
    case empty
    case loaded
}

// MARK: Status of the talk model to decide data and views to display
struct TalkStatus: Identifiable, Equatable {
    init(id: String, sceneType: TalkSceneType, statusType: TalkStatusType, title: String, icon: String, userId: String? = nil) {
        self.id = id
        self.statusType = statusType
        self.title = title
        self.icon = icon
        self.userId = userId
        self.sceneType = sceneType
    }
    // Common properties
    let id: String
    let sceneType: TalkSceneType
    let statusType: TalkStatusType
    var title: String
    var icon: String
    var loadingLatest: LoadingStatus = .loaded
    var loadingEarlier: LoadingStatus = .loaded
//    var sendState: SendState? = nil
    
    // For Timeline
    var talks = [TalkCard]()
    var topic: Topic?
    //    var selectedCardIndex: Int?
    //    var selectedCard: TalkCard?
    
    // For Comments
    var comments = [TalkCommentCard]()
    var targetTalk: TalkCard?
    
    // For replies
    var targetComment: TalkCommentCard?
    var replies = [TalkCommentCard]()
    // For User
    let userId: String?
    var user: TalkUser?
    var followers = [TalkUser]()
    var followees = [TalkUser]()
    var triggerUpdate = ""
    
    // For tag
    var resentHotSearch: [String]? = ["test"]
    
    mutating func updateVotes(targetId: String, targetType: VoteTargetType, isVoting: Bool) {
        switch targetType {
        case .comments:
            if let idx = comments.firstIndex(where: {$0.id == targetId}) {
                print("idx: \(idx)")
                print("\(String(describing: comments[idx].isVoting))")
                comments[idx].isVoting = isVoting
                print("\(String(describing: comments[idx].isVoting))")
                print("I'm changed!")
            }
            if let idx = replies.firstIndex(where: {$0.id == targetId}) {
                replies[idx].isVoting = isVoting
            }
            if targetComment != nil {
                targetComment!.isVoting = isVoting
            }
            
        case.talks:
            if let idx = talks.firstIndex(where: {$0.id == targetId}) {
                talks[idx].isVoting = isVoting
            }
            if targetTalk != nil {
                // The target talk MUST be the only targetTalk
                targetTalk!.isVoting = isVoting
            }
        }
        triggerUpdate = "updateVotes!"
    }
    mutating func updateVotes(targetId: String, targetType: VoteTargetType, voteFlag: Bool?,  voteId: String?) {
        // targetId: The ID to a comment or a talk
        // voteTargetType: .comments or .talks
        // voteFlag: Bool? (good/bad/cancel)
        // voteId: String? Returned from the server when voteFlag is not nil
        switch targetType {
        case .comments:
            // For the case of comentsList(TalkStatusType.comments), there is a list of comments to locate our target
            // For the case of replies(TalkStatusType.replies), besides the list of replies(comments), there is an extral target comment.
            if let idx = comments.firstIndex(where: {$0.id == targetId}) {
                comments[idx].voteFlag = voteFlag
                comments[idx].isVoting = false
                let likesCount = comments[idx].likesCount ?? 0
                if let _ = voteFlag {
                    comments[idx].voteId = voteId
                    comments[idx].likesCount = likesCount + 1
                } else {
                    comments[idx].voteId = nil
                    comments[idx].likesCount = likesCount - 1
                }
            }
            if let idx = replies.firstIndex(where: {$0.id == targetId}) {
                replies[idx].voteFlag = voteFlag
                replies[idx].isVoting = false
                let likesCount = replies[idx].likesCount ?? 0
                if let _ = voteFlag {
                    replies[idx].voteId = voteId
                    replies[idx].likesCount = likesCount + 1
                } else {
                    replies[idx].voteId = nil
                    replies[idx].likesCount = likesCount - 1
                }
            }
            if targetComment != nil {
                targetComment!.isVoting = false
                targetComment!.voteFlag = voteFlag
                let likesCount = targetComment!.likesCount ?? 0
                if let _ = voteFlag {
                    targetComment!.voteId = voteId
                    targetComment!.likesCount = likesCount + 1
                } else {
                    targetComment!.voteId = nil
                    targetComment!.likesCount = likesCount - 1
                }
            }
        case.talks:
            
            // For timelines(TalkStatusType.*timeline), there is a list of talks
            if let idx = talks.firstIndex(where: {$0.id == targetId}) {
                talks[idx].voteFlag = voteFlag
                talks[idx].isVoting = false
                let likesCount = talks[idx].likesCount ?? 0
                if let _ = voteFlag {
                    talks[idx].voteId = voteId
                    talks[idx].likesCount = likesCount + 1
                } else {
                    talks[idx].voteId = nil
                    talks[idx].likesCount = likesCount - 1
                }
            }
            if targetTalk != nil {
                // The target talk MUST be the only targetTalk
                targetTalk!.isVoting = false
                targetTalk!.voteFlag = voteFlag
                let likesCount = targetTalk!.likesCount ?? 0
                if let _ = voteFlag {
                    targetTalk!.voteId = voteId
                    targetTalk!.likesCount = likesCount + 1
                } else {
                    targetTalk!.voteId = nil
                    targetTalk!.likesCount = likesCount - 1
                }
            }
        }
        triggerUpdate = "updateVoteFlags!"
    }
}

enum TalkStatusType {
    case recommendTimeline
    case followeeTimeline
    case topicTimeline
    case userTimeline
    case comments
    case replies
    case topics
    case profile
    case followers
    case followees
}


enum LoadingState{
    case loaded
    case loading
    case empty
    case error(err: String)
}

enum TalkSceneType: String, CaseIterable {
    case recommend
    case followee
    case topics
    case profile
}

struct TalkScene: Identifiable, Equatable {
    let sceneType: TalkSceneType
    let label: String
    let selectedIcon: String
    let unselectedIcon: String
    
    var id: TalkSceneType {
        return sceneType
    }
}

struct TalkImage: Identifiable, Equatable {
    var id: String {
        src
    }
    let src: String
    let isSpoiler: Bool
    let width: Int
    let height: Int
    let downloadable: Bool
}

struct TalkUser: Identifiable, Equatable {
    let id: String
    let nickname: String
    let profile: TalkImage
    let downloadable: Bool
    let location: String?
    let isFresh: Bool?
    let intro: String?
    let sex: Int?
    let followersCount: Int?
    let followeesCount: Int?
    let _createdAt: Date?
    let psnId: String?
    let liveId: String?
    let nintendoFriendcode: String?
    let steamId: String?
    let isDeleted: Bool?
    let isTreated: Bool?
    let followshipId: String?
    let inverseFollowshipId: String?
    
    let _notificationFeedsLastSeenAt: Date?
    let notificationFeedsUnseenCount: Int?
    let _subscriptionFeedsLastSeenAt: Date?
    let subscriptionFeedsUnseenCount: Int?
    let _topicFeedsLastSeenAt: Date?
    let topicFeedsUnseenCount: Int?
    let privateMailsUnreadCount: Int?
    var createdAt: String {
        if let date = _createdAt {
            return DateUtils.stringFromDate(date: date, platform: .gcores)
        } else {
            return "nil"
        }
    }
    var notificationFeedsLastSeenAt: String {
        if let date = _notificationFeedsLastSeenAt {
            return DateUtils.stringFromDate(date: date, platform: .gcores)
        } else {
            return "nil"
        }
    }
    var subscriptionFeedsLastSeenAt: String {
        if let date = _subscriptionFeedsLastSeenAt {
            return DateUtils.stringFromDate(date: date, platform: .gcores)
        } else {
            return "nil"
        }
    }
    
    var topicFeedsLastSeenAt: String {
        if let date = _topicFeedsLastSeenAt {
            return DateUtils.stringFromDate(date: date, platform: .gcores)
        } else {
            return "nil"
        }
    }
}

struct TalkRelated {
    let id: Int
    let type: String
    let title: String
    let contentString: String
}

struct TalkTopicCategory: Equatable, Identifiable {
    let id: String
    let name: String
    let desc: String?
    let logo: String?
    let background: String?
    //    var tags: [TalkTag]
}

struct Topic: Equatable, Identifiable{
    let id: String
    let title: String
    let desc: String?
    let cover: String?
    let banner: String?
}

struct TalkText: Identifiable {
    let id: String
    let content: String
    let isSpoiler: Bool
}

struct TalkCard: Identifiable, Equatable {
    static func == (lhs: TalkCard, rhs: TalkCard) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: String
    let platform: Platform
    let user: TalkUser
    let _createdAt: Date
    let _updatedAt: Date
    let edited: Bool
    let texts: [TalkText]
    let images: [TalkImage]?
    let caption: String?
    let topics: [Topic]?
    var likesCount: Int?
    var voteFlag: Bool?
    var voteId: String?
    var isVoting: Bool? = false
    let bookMarkId: String?
    var commentsCount: Int?
    let shareUrl: String?
    
    
    
    let related: TalkRelated? /* For gcores talks. It may related to some videos/podcasts/articles.*/
    
    var createdAt: String {
        return DateUtils.stringFromDate(date: _createdAt, platform: .gcores)
    }
    var updatedAt: String {
        return DateUtils.stringFromDate(date: _updatedAt, platform: .gcores)
    }
}

struct TalkCommentCard: Identifiable, Equatable {
    static func == (lhs: TalkCommentCard, rhs: TalkCommentCard) -> Bool {
        lhs.id == rhs.id
    }
        
    let id: String
    let platform: Platform
    let user: TalkUser
    let _createdAt: Date
    let _updatedAt: Date
    let edited: Bool
    let replyTo: String?
    var descendantsCount: Int?
    var descendants = [String]()
    var oldestDescendants = [String]()
    let depth: Int
    let text: String
    let images: [TalkImage]?
    let caption: String?
    let topics: [Topic]?
    var isVoting: Bool? = false
    var likesCount: Int?
    var voteFlag: Bool?
    var voteId: String?
    let bookMarkId: String?
    let shareUrl: String?
    
    let related: TalkRelated? /* For gcores talks. It may related to some videos/podcasts/articles.*/
    
    var createdAt: String {
        return DateUtils.stringFromDate(date: _createdAt, platform: .gcores)
    }
    var updatedAt: String {
        return DateUtils.stringFromDate(date: _updatedAt, platform: .gcores)
    }}


//class TalkModel: ObservableObject {
//    init() {
//        pullTalksOfPlatforms(from: .recommend)
//    }
//    // all the talk Cards from various platforms
//    var timeline = [TalkCard]()
//    let gcoresTalk = GCoresTalk()
//    var comments = [TalkCommentCard]()
//    let platforms = [GCoresTalk()]
//    
//    let mainQueue = DispatchQueue.main
//    
//    func updateTimeline(with cards: [TalkCard]) {
//        timeline = cards + timeline
//        mainQueue.sync {
//            objectWillChange.send()
//        }
//        
//    }
//    func getComment(to talk:TalkCard) {
//        // TODO: Need to select the correct model based on platform
//        platforms[0].getComments(for: talk.id, fromStart: true)
//    }
//    func pullTalksOfPlatforms(from endpoint: EndPoint) {
//        let dispatchGroup = DispatchGroup()
//        
//        var newCards = [TalkCard]()
//        platforms.forEach{platform in
//            dispatchGroup.enter()
////            platform.pullTalks(from: EndPoint.recommend, dispatchGroup: dispatchGroup)
//        }
//        dispatchGroup.notify(queue: .global()) {
//            self.platforms.forEach{ platform in
//                newCards += platform.talkCards
//            }
//            
////            mainQueue.sync {
//                print("PUlled: \(newCards.count)")
//                self.updateTimeline(with: newCards)
//                print("UPdated: \(newCards.count)")
////            }
//            
//
//        }
//    }
//}
