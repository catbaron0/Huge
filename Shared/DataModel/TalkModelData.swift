//
//  TalkModel.swift
//  GCoresTalk
//
//  Created by catbaron on 2021/11/26.
//

import Foundation
import Combine
import SwiftUI

struct GCoresFont {
    static let body = Font.system(size: 15)
}

enum AppSize: CGFloat {
    case width = 380
}

enum RequestState: String {
    case succeed
    case failed
    case sending
    case empty
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

struct SearchStatus {
    var searchResults = [TalkRelated]()
    var requestEarlier: RequestState = .succeed
    var requestLatest: RequestState = .succeed
}

enum NotificationType: String, Codable {
    case comment
    case like
    case reply
    case follow
}

struct GCoresNotification: Identifiable, Equatable {
    let id: String
    let type: NotificationType
    let object: [TalkRelated]
    let target: TalkRelated?
    var actors: [TalkUser]
    var unRead: Bool
    static func == (lhs: GCoresNotification, rhs: GCoresNotification) -> Bool {
        lhs.id == rhs.id && lhs.type == rhs.type
    }
    
    var url: String? {
        if object[0].type == .games || object[0].type == .articles || object[0].type == .radios || object[0].type == .videos {
            return GCORES_HOST + "\(object[0].type)/\(object[0])"
        }
        return nil
    }
    
    var actorNames: String {
        return actors[0].nickname
//        if actors.count > 1 {
//            return actors[0].nickname + " 等人"
//        } else {
//            return actors[0].nickname
//        }
    }
    
    var verb: String {
        switch type {
        case .comment, .reply:
            return "回复了"
        case .like:
            return "喜欢了"
        case .follow:
            return "关注了"
        }
    }
    
    var objectStr: [String] {
        if object.isEmpty {
            return ["内容", ""]
        }
        let objType = object[0].type
        switch objType {
        case .videos:
            return ["你参与的视频: ", object[0].title!]
        case .radios:
            return ["你参与的电台: ", object[0].title!]
        case .articles:
            return ["你发布的文章: ", object[0].title!]
        case .talks:
            return ["你发布的动态: ", object[0].contentString!]
        case .comments:
            if let target = target {
                switch target.type {
                case .talks:
                    return ["你的动态: ", object[0].contentString!]
                case .comments:
                    return ["你的评论: ", object[0].contentString!]
                default:
                    return ["你发布的内容", ""]
                }
            }
            return ["评论: ", object[0].contentString!]
        case .users:
            return ["你", ""]
        default:
            print("objType: \(objType)")
            return ["内容", ""]
        }
    }
    var desc: AttributedString {
        var styledActorName = AttributedString(actorNames)
        styledActorName.foregroundColor = .red
        styledActorName.font = .body.bold()
        if actors.count > 1 {
            styledActorName += AttributedString("等人")
        }
        var styledVerb = AttributedString(verb + objectStr[0])
        styledVerb.font = .body.weight(.light)
        var styledObject = AttributedString(objectStr[1])
        styledObject.font = .body.bold()
        return styledActorName + styledVerb + styledObject
    }
    
}

// MARK: Status of the talk model to decide data and views to display
class ViewStatus: Identifiable, Equatable, ObservableObject {
    static func == (lhs: ViewStatus, rhs: ViewStatus) -> Bool {
        lhs.id == rhs.id
    }
    
    init(id: String, sceneType: TalkSceneType, statusType: TalkStatusType, title: String, icon: String) {
        self.id = id
        self.statusType = statusType
        self.title = title
        self.icon = icon
        self.sceneType = sceneType
    }
    
    // Common properties
    let id: String
    let sceneType: TalkSceneType
    let statusType: TalkStatusType
    var title: String
    var icon: String
    @Published var loadingLatest: LoadingStatus = .loaded
    @Published var loadingEarlier: LoadingStatus = .loaded
    @Published var requestState: RequestState?
    @Published var searchSuggestion = [String]()
    @Published var unreadCount = 0

    // For Timeline
    @Published var talks = [TalkCard]()
    @Published var targetTopic: TalkRelated?
    //    var selectedCardIndex: Int?
    //    var selectedCard: TalkCard?
    
    // For Comments
    var targetTalkId: String?
    @Published var comments = [TalkCommentCard]()
    @Published var targetRelated: TalkRelated?
    @Published var targetTalk: TalkCard?
    
    // For replies
    var targetCommentId: String?
    @Published var targetComment: TalkCommentCard?
    @Published var replies = [TalkCommentCard]()
    // For profile
    var userId: String?
    @Published var user: TalkUser?
    @Published var followers = [TalkUser]()
    @Published var followees = [TalkUser]()
    
    // For Topic
    @Published var selectedTopicCategory: TalkTopicCategory?
    @Published var topicCategories = [TalkTopicCategory]()
    @Published var topics = [TalkRelated]()

    // For search
    @Published var searchResults = [TalkRelated]()
    @Published var requestEarlier: RequestState = .succeed
    @Published var requestLatest: RequestState = .succeed
    
    // For notifications
    @Published var notifications = [GCoresNotification]()
//    @Published var unreadNotificationsCount = 0
    func getUserOfReplyTo(replyToId: String?) -> TalkUser? {
        guard let replyToId = replyToId else {
            return nil
        }
        if let comment = comments.first(where: { $0.id == replyToId}) {
            return comment.user
        } else if targetComment?.id == replyToId {
            return targetComment?.user
        } else {
            return (replies.first {$0.id == replyToId})?.user
        }
    }
    func readAllNotifications() {
//        unreadCount = 0
        for i in 0..<notifications.count {
            notifications[i].unRead = false
        }
    }
    func updateFollowship(userId: String, followshipId: String?) {
        if user?.id == userId {
            user?.followshipId = followshipId
        }
        if let idx = followees.firstIndex(where: {$0.id == userId}) {
            followees[idx].followshipId = followshipId
        }
        if let idx = followers.firstIndex(where: {$0.id == userId}) {
            followers[idx].followshipId = followshipId
        }
        
    }
    func newNotifications(_ newNotifications: [GCoresNotification], earlier: Bool) {
        if earlier {
            newNotifications.forEach { notification in
                if !notification.object.isEmpty && !(self.notifications.contains(where: {$0 == notification})) {
                    self.notifications.append(notification)
                }
            }
            return
        }
        // The latest is loaded
        notifications = newNotifications
    }
    
//    func readNotification(_ notification: GCoresNotification) {
//        if let index = notifications.firstIndex(of: notification) {
//            if notifications[index].unRead {
//                unreadNotificationsCount -= 1
//            }
//            notifications[index].unRead = false
//        }
//    }
    
    func updateVotes(targetId: String, targetType: VoteTargetType, isVoting: Bool) {
        switch targetType {
        case .comments:
            if let idx = comments.firstIndex(where: {$0.id == targetId}) {
                comments[idx].isVoting = isVoting
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
        objectWillChange.send()
    }
    func updateVotes(targetId: String, targetType: VoteTargetType, voteFlag: Bool?,  voteId: String?) {
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
        objectWillChange.send()
    }
    func copy() -> ViewStatus {
        let status = ViewStatus(id: self.id, sceneType: self.sceneType, statusType: self.statusType, title: self.title, icon: self.icon)
        status.targetTopic = self.targetTopic
        status.comments = self.comments
        status.replies = self.replies
        
        status.targetTalk = self.targetTalk
        status.targetTalkId = self.targetTalkId
        status.targetComment = self.targetComment
        status.targetCommentId = self.targetCommentId
        status.user = self.user
        status.userId = self.userId
//        status.replyToId = self.replyToId
        status.comments = self.comments
        status.replies = self.replies
        status.talks = self.talks
        status.followers = self.followers
        status.followees = self.followees
        return status
    }
    
    func addComment(comment: TalkCommentCard, replyTargetCommentId: String?) {
        if replyTargetCommentId == nil {
            // reply to a talk
            comments.append(comment)
        } else {
//            let _replies = replies
//            let _comments = comments
            //      * If the comment is replied to a comment or a reply, append the new comment to the replies list,
            replies.append(comment)
//            let _new_replies = replies
            //      * If the comment is replied to a comment ,locate the targetComment and nsert the new commentId to its oldestDecendant list
            if let targetComment = targetComment, targetComment.id == replyTargetCommentId {
                self.targetComment!.oldestDescendants.append(comment.id)
            }
            if let index = comments.firstIndex(where: {$0.id == replyTargetCommentId}) {
                comments[index].oldestDescendants.append(comment.id)
            }
            //      * If the comment is replied to a reply, locate the targetComment by its parentId
            if let commendIndex = comments.firstIndex(where: { element in
                if element.oldestDescendants.contains(where: {$0 == comment.replyTo}) {
                    return true
                } else {
                    return false
                }
            }){
                comments[commendIndex].oldestDescendants.append(comment.id)
            }
            if let _ = targetComment {
                if targetComment!.oldestDescendants.contains(where: {$0 == comment.replyTo}) {
                    targetComment!.oldestDescendants.append(comment.id)
                }
            }
        }
        objectWillChange.send()
    }


    // TODO: Protocal of Deletable to make the code simpler
    func setDeleteFlagToComment(commentId: String, flag: Bool) {
        if let idx = comments.firstIndex(where: { $0.id == commentId}) {
            comments[idx].onDelete = flag
        } else if let idx = replies.firstIndex(where: { $0.id == commentId }) {
            replies[idx].onDelete = flag
        }
    }
    
    func deleteComment(commentId: String) {
        if let idx = comments.firstIndex(where: { $0.id == commentId}) {
            comments.remove(at: idx)
        } else if let idx = replies.firstIndex(where: { $0.id == commentId }) {
            replies.remove(at: idx)
        }
    }
    
    func deleteTalk(talkId: String) {
        if let idx = talks.firstIndex(where: {$0.id == talkId}) {
            talks.remove(at: idx)
        }
    }
    
    func setDeleteFlagToTalk(talkId: String, flag: Bool) {
        if let idx = talks.firstIndex(where: {$0.id == talkId}) {
            talks[idx].onDelete = flag
        }
    }

}

enum TalkStatusType {
    case newTalk
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
    case notification
}


enum LoadingState {
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
    case newWindow
    case notification
}

struct TalkScene: Identifiable, Equatable {
    let sceneType: TalkSceneType
    let label: String
    var selectedIcon: String
    var unselectedIcon: String
    var selectedBadgeIcon: String
    var unselectedBadgeIcon: String
    var unread: Bool = false
    var selected: Bool = false
    
    var id: TalkSceneType {
        return sceneType
    }
    var icon: String {
        if selected {
            return unread ? selectedBadgeIcon : selectedIcon
        } else {
            return unread ? unselectedBadgeIcon : unselectedIcon
        }
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
    var followshipId: String?
    var inverseFollowshipId: String?
    
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

struct TalkRelated: Identifiable, Equatable {
    let id: String
    let type: GCoresRelatedType
    let title: String?
    let desc: String?
    let cover: String?
    let banner: String?
    let contentString: String?
    var shareUrl: String {
        return GCORES_HOST + "\(type)/\(id)"
    }
    var subscriptionId: String?
}
//struct SearchResult: Identifiable, Equatable {
//    let id: String
//    let type: String
//    let title: String
//    let desc: String?
//    let cover: String?
//}
struct TalkTopicCategory: Equatable, Identifiable {
    let id: String
    let name: String
    let desc: String?
    let logo: String?
    let background: String?
    //    var tags: [TalkTag]
}

//struct Topic: Equatable, Identifiable{
//    let id: String
//    let title: String
//    let desc: String?
//    let cover: String?
//    let banner: String?
//}

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
    let topics: [TalkRelated]?
    var likesCount: Int?
    var voteFlag: Bool?
    var voteId: String?
    var isVoting: Bool? = false
    let bookMarkId: String?
    var commentsCount: Int?
    let shareUrl: String?
    var onDelete = false


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
    let topics: [TalkRelated]?
    var isVoting: Bool? = false
    var likesCount: Int?
    var voteFlag: Bool?
    var voteId: String?
    let bookMarkId: String?
    let shareUrl: String?
    var onDelete = false
    
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

