//
//  File.swift
//  GCoresTalk
//
//  Created by catbaron on 2021/11/29.
//

import Foundation

let preview_talkText_0 = TalkText(
    id: "talktext-0",
    content: "两个游戏",
    isSpoiler: false
)
let preview_talkText_1 = TalkText(
    id: "talktext-1",
    content: "两个游戏两个游戏",
    isSpoiler: false
)


//let preview_tags = [
//    TalkTag(id: "101", title: "The first tag!", desc: nil, cover: nil, ),
//    TalkTag(id: "102", title: "Another tag!", desc: nil, cover: nil),
//]
let preview_talkImage_0 = TalkImage(src: "https://image.gcores.com/edc86894-4476-4ed5-bfcf-086c65313f8d.jpg", isSpoiler: false, width: 500, height: 500, downloadable: true)
//let preview_talkImage_1 = TalkImage(src: "https://image.gcores.com/333e8adf-95ed-4089-ac63-01c8a6b6a257.jpg", isSpoiler: false, width: 500, height: 500)
//let preview_images = [preview_talkImage_0, preview_talkImage_1]
//let preview_avarta = "https://image.gcores.com/03f62e64-49e4-483b-b559-208c6a516a8c.jpg"
//let preview_user = TalkUser(id: "0", nickname: "catbaron", avarta: preview_avarta)
//
//let preview_talkCard_0 = TalkCard(id: "card-0", platform: .gcores, user: preview_user, _createdAt: Date(), _updatedAt: Date(), edited: false, texts: [preview_talkText_0, preview_talkText_1], images: preview_images, caption: nil, tags: preview_tags, likesCount: 3, didLike: true, likeId: "123", bookMarkId: "223", commentsCount: 6, shareUrl: nil, related: nil)
//let preview_talkCard_1 = TalkCard(id: "card-1", platform: .gcores, user: preview_user, _createdAt: Date(), _updatedAt: Date(), edited: false, texts: [preview_talkText_0, preview_talkText_1], images: nil, caption: nil, tags: preview_tags, likesCount: 3, didLike: false, likeId: "123", bookMarkId: "223", commentsCount: 6, shareUrl: nil, related: nil)
//let preview_talkCard_2 = TalkCard(id: "card-2", platform: .gcores, user: preview_user, _createdAt: Date(), _updatedAt: Date(), edited: false, texts: [preview_talkText_0, preview_talkText_1], images: nil, caption: nil, tags: preview_tags, likesCount: 3, didLike: true, likeId: "123", bookMarkId: "223", commentsCount: 6, shareUrl: nil, related: nil)
//
//let replyTo = TalkCommentCard.ReplyComment(id: "123", user: preview_user, text: "一百四十多个小时刚把图舔差不多了，主线支线宝藏祭坛啥的基本都清了，趁黑五又买了季票.一百四十多个小时刚把图舔差不多了，主线支线宝藏祭坛啥的基本都清了，趁黑五又买了季票.一百四十多个小时刚把图舔差不多了，主线支线宝藏祭坛啥的基本都清了，趁黑五又买了季票")
//
//let preview_commentCard = TalkCommentCard(
//    id: "123", platform: .gcores, user: preview_user, _createdAt: Date(), _updatedAt: Date(), edited: false, replyTo: nil, depth: 0, repliesId: ["223"],
//    text: "一百四十多个小时刚把图舔差不多了，主线支线宝藏祭坛啥的基本都清了，趁黑五又买了季票.一百四十多个小时刚把图舔差不多了，主线支线宝藏祭坛啥的基本都清了，趁黑五又买了季票.一百四十多个小时刚把图舔差不多了，主线支线宝藏祭坛啥的基本都清了，趁黑五又买了季票",
//    images: nil, caption: nil, tags: nil, likesCount: 4, didLike: true, likeId: "1233", bookMarkId: nil, shareUrl: nil, related: nil)
//let preview_replyCard = TalkCommentCard(
//    id: "223", platform: .gcores, user: preview_user, _createdAt: Date(), _updatedAt: Date(), edited: false, replyTo: nil, depth: 1, repliesId: ["223"],
//    text: "确实是好玩的，不着急地玩，是能体验到一些好东西的",
//    images: nil, caption: nil, tags: nil, likesCount: 4, didLike: true, likeId: "1233", bookMarkId: nil, shareUrl: nil, related: nil)
//let preview_comments = [preview_commentCard, preview_replyCard]
let profile = TalkImage(src: "https://image.gcores.com/edc86894-4476-4ed5-bfcf-086c65313f8d.jpg", isSpoiler: false, width: 500, height: 500, downloadable: true)

let testUser =  TalkUser(
    id: "12355",
    nickname: "catbaron",
    profile: profile,
    downloadable: true,
    location: nil,
    isFresh: nil,
    intro: nil,
    sex: nil,
    followersCount: 0,
    followeesCount: 0,
    _createdAt: Date(),
    psnId: nil,
    liveId: nil,
    nintendoFriendcode: nil,
    steamId: nil,
    isDeleted: nil,
    isTreated: nil,
    followshipId: nil,
    inverseFollowshipId: nil,
    _notificationFeedsLastSeenAt: nil,
    notificationFeedsUnseenCount: nil,
    _subscriptionFeedsLastSeenAt: nil,
    subscriptionFeedsUnseenCount: nil,
    _topicFeedsLastSeenAt: nil,
    topicFeedsUnseenCount: nil,
    privateMailsUnreadCount: nil
)

let testComment = TalkCommentCard(
    id: "2333",
    platform: .gcores,
    user: testUser,
    _createdAt: Date(),
    _updatedAt: Date(),
    edited: false,
    replyTo: nil,
    descendantsCount: 0,
    descendants: [String](),
    oldestDescendants: [String](),
    depth: 1,
    text: "commentData.attributes.body",
    images: nil, caption: nil, tags: nil, likesCount: 0,
    voteFlag: nil, voteId: nil,
    bookMarkId: nil, shareUrl: nil, related: nil)

