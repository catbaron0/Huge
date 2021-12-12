//
//  GCores.swift
//  GCoresTalk
//
//  Created by catbaron on 2021/11/25.
//

import Foundation
import SwiftUI


// MARK: GCoresTalk Model

class GCoresTalk: ObservableObject{
    
    @Published var publisherTrigger = ""
    @Published var user: TalkUser? = nil
    @Published var loginInfo: LoginInfo
    
    //    @Published var topicCategories = [TalkTopicCategory]()
    //    @Published var selectedTopics = [TalkRelated]()
    //    @Published var selectedTopicCategory: TalkTopicCategory?
    
    //    @Published var NSWindowRequestStates = [String: RequestState]()
    //    @Published var NSWindowStatus = [String: ViewStatus]()
    let uds = UserDefaults.standard
    
    
    @Published var talkScenes: [TalkScene] = [
        TalkScene(
            sceneType: .followee,
            label: "Followee",
            selectedIcon: "star.bubble.fill",
            unselectedIcon: "star.bubble"),
        TalkScene(
            sceneType: .recommend,
            label: "Recommend",
            selectedIcon: "bubble.left.fill",
            unselectedIcon: "bubble.left"),
        TalkScene(
            sceneType: .topics,
            label: "Topic",
            selectedIcon: "tag.fill",
            unselectedIcon: "tag"),
        TalkScene(
            sceneType: .profile,
            label: "Profile",
            selectedIcon: "person.fill",
            unselectedIcon: "person")
    ]
    
    @Published var selectedTalkSceneType: TalkSceneType = .followee
    @Published var statusForScene: [TalkSceneType: [ViewStatus]]
    //    = TalkSceneType.allCases.reduce(into: [TalkSceneType: [TalkModelStatus]]()) {
    //        $0[$1] = [initStatus(for: $1)]
    //    }
    
    //    static
    func initStatus(for sceneType: TalkSceneType) -> ViewStatus {
        switch sceneType {
        case .recommend:
            let status = ViewStatus(
                id: "\(sceneType)-\(TalkStatusType.recommendTimeline)-0", sceneType: sceneType,
                statusType: .recommendTimeline, title: "推荐", icon: "bubble.left.fill")
            status.talks = [TalkCard]()
            return status
        case .topics:
            return ViewStatus(
                id: "\(sceneType)-\(TalkStatusType.topicTimeline)-0", sceneType: sceneType,
                statusType: .topics, title: "话题", icon: "tag.fill"
            )
        case .followee:
            let status = ViewStatus(
                id: "\(sceneType)-\(TalkStatusType.followeeTimeline)-0", sceneType: sceneType,
                statusType: .followeeTimeline, title: "关注", icon: "star.bubble.fill")
            status.talks = [TalkCard]()
            return status
        case .profile:
            return ViewStatus(
                id: "\(sceneType)-\(TalkStatusType.profile)-0", sceneType: sceneType,
                statusType: .profile, title: "用户", icon: "person.fill", userId: loginInfo.userId)
        case .newWindow:
            return ViewStatus(
                id: "\(sceneType)-\(TalkStatusType.newTalk)-0", sceneType: sceneType,
                statusType: .profile, title: "核态", icon: "pencil.and.outline")
        }
    }
    
    
    init() {
        
        // Initialize variables
        publisherTrigger = ""
        user = nil
        
        talkScenes = [
            TalkScene(
                sceneType: .followee,
                label: "Followee",
                selectedIcon: "star.bubble.fill",
                unselectedIcon: "star.bubble"),
            TalkScene(
                sceneType: .recommend,
                label: "Recommend",
                selectedIcon: "bubble.left.fill",
                unselectedIcon: "bubble.left"),
            TalkScene(
                sceneType: .topics,
                label: "Topic",
                selectedIcon: "tag.fill",
                unselectedIcon: "tag"),
            TalkScene(
                sceneType: .profile,
                label: "Profile",
                selectedIcon: "person.fill",
                unselectedIcon: "person")
        ]
        
        selectedTalkSceneType = .topics
        statusForScene = [TalkSceneType: [ViewStatus]]()
        
        // Check login states
        loginInfo = LoginInfo(userId: nil, token: nil, cookie: nil, loginState: .logout)
        if let udsLoginInfo = uds.object(forKey: "loginInfo") as? [String: String] {
            loginInfo.token = udsLoginInfo["token"]
            loginInfo.userId = udsLoginInfo["userId"]
            loginInfo.cookie = udsLoginInfo["cookie"]
            loginInfo.loginState = .succeed
            if let userId = loginInfo.userId {
                readUserInfo(userId: userId, status: nil)
            }
        }
        
        //        topicCategories = [TalkTopicCategory]()
        //        selectedTopics = [TalkRelated]()
        //        selectedTopicCategory = nil
        
        // Initialize all initial status
        TalkSceneType.allCases.forEach {
            self.statusForScene[$0] = [self.initStatus(for: $0)]
        }
    }
    
    private let session = URLSession.shared
    let mainQueue = DispatchQueue.main
    //    func readCurrentStatus() -> TalkModelStatus {
    //        return statusForScene[selectedTalkSceneType]!.last!
    //    }
    
    func readStatusOf(sceneType: TalkSceneType, of id: String) -> ViewStatus? {
        return statusForScene[sceneType]!.first { $0.id == id}
    }
    
    func addStatusToCurrentScene(
        after curStatus: ViewStatus, statusType: TalkStatusType, title: String,
        icon: String, targetTalk: TalkCard? = nil, topic: TalkRelated? = nil,
        userId: String? = nil, targetComment: TalkCommentCard? = nil) {
            let sceneType = curStatus.sceneType
            let statusId = "\(sceneType)-\(statusType)-\(statusForScene[sceneType]!.count)"
            let status = ViewStatus(id: statusId, sceneType: sceneType, statusType: statusType, title: title, icon: icon, userId: userId)
            status.targetTalk = targetTalk
            status.topic = topic
            status.targetComment = targetComment
            // stop from jumping to itself
            // * From comments page to the same page
            if curStatus.statusType == .comments && statusType == .comments && curStatus.targetTalk == targetTalk {
                return
            }
            // * From user profile page
            //        if lastStatus.statusType == .profile && .profile == statusType && lastStatus.userId == status.userId {
            //            return
            //        }
            
            statusForScene[sceneType]!.append(status)
        }
    
    //    func indexOf(status: ViewStatus) -> Int? {
    //
    //        return statusForScene[status.sceneType]?.firstIndex(where: {$0.id == status.id} )
    //    }
    
    func isSelected(sidebarItem: TalkScene) -> Bool {
        return selectedTalkSceneType == sidebarItem.sceneType
    }
    
    
    func gcoresRequest(url: URL, httpMethod: String, body: Data? = nil, image: Bool = false, boundary: String? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue("application/vnd.api+json", forHTTPHeaderField: "Accept")
        request.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        request.setValue("GcoresMobile/602 CFNetwork/1325.0.1 Darwin/21.1.0", forHTTPHeaderField: "User-Agent")
        request.setValue("keep-alive", forHTTPHeaderField: "Connection")
        if image {
            //            let boundary = UUID().uuidString
            request.setValue("multipart/form-data; boundary=\(boundary!)", forHTTPHeaderField: "Content-Type")
        } else {
            
            request.setValue("application/vnd.api+json", forHTTPHeaderField: "Content-Type")
        }
        
        if loginInfo.loginState == .succeed {
            request.setValue("Token " + loginInfo.token!, forHTTPHeaderField: "Authorization")
            request.setValue(loginInfo.cookie, forHTTPHeaderField: "Cookie")
        }
        if let body = body {
            request.httpBody = body
        }
        return request
    }
    
    func checkResponse(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> String?{
        var message: String?
        
        if error != nil {
            message = "Error: \(String(describing: error))!"
        }
        else if let response = response{
            if let httpResponse = response as? HTTPURLResponse, 304 == httpResponse.statusCode {
                message = "Empty: No new data is available"
            }
            else if let httpResponse = response as? HTTPURLResponse, !((200...299).contains(httpResponse.statusCode)) {
                message = "Error: Failed to access the endpoint!(Status code: \(httpResponse.statusCode))"
                if let data = data {
                    message = message! + (String(data: data, encoding: .utf8) ?? "")
                }
                
            }
            else if let mime = response.mimeType, mime != "application/json", mime != "application/vnd.api+json", mime != "text/plain" {
                message = "Error: Unexpected MIME Type: \(String(describing: response.mimeType))!"
            }
            
        } else {
            message = "Error: Response is nil!"
        }
        return message
    }
    
    
    func talkContent(text: String, imgStr: String?) -> String {
        var content = ""
        if let imgStr = imgStr {
            content = "{\"blocks\":[{\"data\":{\"spoiler\":false},\"depth\":0,\"entityRanges\":[{\"key\":0,\"length\":1,\"offset\":0}],\"inlineStyleRanges\":[],\"key\":\"57tge\",\"text\":\"-\",\"type\":\"atomic\"},{\"data\":{\"spoiler\":false},\"depth\":0,\"entityRanges\":[],\"inlineStyleRanges\":[],\"key\":\"ikdgu\",\"text\":\"\(text)\",\"type\":\"unstyled\"}],\"entityMap\":{\"0\":{\"data\":{\"caption\":\"\",\"images\":[\(imgStr)]},\"mutability\":\"IMMUTABLE\",\"type\":\"GALLERY\"}}}"
        } else {
            content = "{\"blocks\":[{\"data\":{\"spoiler\":false},\"depth\":0,\"entityRanges\":[],\"inlineStyleRanges\":[],\"key\":\"30c8n\",\"text\":\"\(text)\",\"type\":\"unstyled\"}],\"entityMap\":{}}"
        }
        return content
    }
    
    func newTalk(content: String, topic: TalkRelated, related: TalkRelated?, status: ViewStatus) {
        status.requestState = .sending
        let jsonData = [
            "data": [
                "type": "talks",
                "attributes": [
                    "content": content
                ],
                "relationships": [
                    "topic": [
                        "data": [
                            "type": "topics",
                            "id": topic.id
                        ]
                    ],
                    "user": [
                        "data": [
                            "id": loginInfo.userId,
                            "type": "users"
                        ]
                    ],
                    "articles": [
                        "data": related?.type == .articles ? [["id": related!.id, "type": "articles"]] : [[String: String]]()
                    ],
                    "radios": [
                        "data": related?.type == .radios ? [["id": related!.id, "type": "radios"]] : [[String: String]]()
                    ],
                    "videos": [
                        "data": related?.type == .videos ? [["id": related!.id, "type": "videos"]] : [[String: String]]()
                    ],
                    "games": [
                        "data": related?.type == .games ? [["id": related!.id, "type": "games"]] : [[String: String]]()
                    ]
                ]
            ]
        ]
        
        let body = try! JSONSerialization.data(withJSONObject: jsonData, options: .prettyPrinted)
        let url = URL(
            string: "https://www.gcores.com/gapi/v1/talks?include=user%2Ctopic%2Cgames%2Carticles%2Cradios%2Cvideos&from-app=1")!
        let request = gcoresRequest(url: url, httpMethod: "POST", body: body)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let errMessage = self.checkResponse(data, response, error) {
                print(errMessage)
                status.requestState = .failed
                return
            }
            self.mainQueue.async {
                status.requestState = .succeed
                NSApplication.shared.keyWindow?.close()

            }
        }.resume()
    }
    
    func newTalk(text: String, imageUrls: [URL]?, topic: TalkRelated, related: TalkRelated?, status: ViewStatus) {
        // upload image
        
        var uploadedImages = [String: String]()
        
        let dispatchGroup = DispatchGroup()
        if let urls = imageUrls, !urls.isEmpty {
            urls.forEach{url in
                dispatchGroup.enter()
                print("Uploading image: \(url)")
                uploadImage(url: url)
            }
            dispatchGroup.notify(queue: .global()) {
                // Generate Content
                var imgStr = [String]()
                imageUrls?.forEach { url in
                    let img = NSImage(contentsOf: url)!
                    let src = uploadedImages[url.absoluteString]!
                    let width = img.size.width
                    let height = img.size.height
                    imgStr.append("{\"path\":\"\(src)\",\"width\":\(width),\"height\":\(height)}")
                }
                let content = self.talkContent(text: text, imgStr: imgStr.joined(separator: ","))
                self.newTalk(content: content, topic: topic, related: related, status: status)
            }
        }
        else {
            let content = self.talkContent(text: text, imgStr: nil)
            self.newTalk(content: content, topic: topic, related: related, status: status)
        }
        
        
        func uploadImage(url: URL) {
            let endPoint = URL(string: "https://www.gcores.com/gapi/v1/images")!
            let data = try? Data(contentsOf: url)
            let boundary = UUID().uuidString
            let body = createHttpBody(binaryData: data!, boundary: boundary, parameters: ["file": UUID().uuidString])
            let request = gcoresRequest(url: endPoint, httpMethod: "POST", body: body, image: true, boundary: boundary)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let errMessage = self.checkResponse(data, response, error) {
                    print(errMessage)
                    return
                }
                guard let data = data else{ return }
                
                let resp = try! JSONSerialization.jsonObject(with: data) as! [String: String]
                print(resp)
                uploadedImages[url.absoluteString] = resp["path"]
                dispatchGroup.leave()
            }
            task.resume()
        }
    }
    
    
    
    
    func createHttpBody(binaryData: Data, boundary: String, parameters: [String: String]?) -> Data {
        var postContent = "--\(boundary)\r\n"
        let fileName = "\(UUID().uuidString).jpeg"
        postContent += "Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n"
        postContent += "Content-Type: \(binaryData.mimeType!)\r\n\r\n"
        
        var data = Data()
        guard let postData = postContent.data(using: .utf8) else { return data }
        data.append(postData)
        data.append(binaryData)
        
        guard let endData = "\r\n--\(boundary)--\r\n".data(using: .utf8) else { return data }
        data.append(endData)
        return data
    }
    
    
    func readTalks(status: ViewStatus, endpoint endponit: TimelineEndPoint, earlier: Bool = false) {
        if earlier {
            status.loadingEarlier = .loading
        } else {
            status.loadingLatest = .loading
        }
        
        var before = ""
        var pageOffset = 0
        if earlier && !status.talks.isEmpty {
            before = "before="+DateUtils.stampFromDate(date: status.talks.last!._createdAt)
            pageOffset = status.talks.count
        }
        var url: URL
        
        switch endponit {
        case .recommend:
            url = URL(
                string: [
                    "https://www.gcores.com/gapi/v1/topics/recommend?",
                    "talk-include=user%2Ctopic%2Cradios%2Cvideos%2Cgames%2Carticles&\(before)",
                    "&order-by=time&limit%5D=40&from-app=1"
                ].reduce("", +)
            )!
        case .topic:
            let topicId = status.topic!.id
            url = URL(
                string: [
                    "https://www.gcores.com/gapi/v1/topics/\(topicId)/recommend?",
                    "talk-include=user%2Ctopic%2Cradios%2Cvideos%2Cgames%2Carticles",
                    "&original-include=user%2Cdjs%2Ccategory&order-by=time&\(before)&from-app=1"
                ].reduce("", +)
            )!
        case .followee:
            url = URL(string: "https://www.gcores.com/gapi/v1/topics/recommend?talk-include=user%2Ctopic%2Cradios%2Cvideos%2Cgames%2Carticles&\(before)&order-by=followee&from-app=1")!
        case .user:
            let userId = status.userId!
            url = URL(string: "https://www.gcores.com/gapi/v1/users/\(userId)/talks?include=topic,user,radios,videos,articles,games&sort=-created-at&page%5Blimit%5D=40&page%5Boffset%5D=\(pageOffset)&from-app=1")!
        }
        print(url)
        let request = gcoresRequest(url: url, httpMethod: "GET")
        
        let task = session.dataTask(with: request) { data, response, error in
            self.mainQueue.async {
                // the status is still alive
                //                guard self.statusForScene[status.sceneType]!.contains(where: {$0.id == status.id}) else { return }
                if earlier {
                    status.loadingEarlier = .loaded
                } else {
                    status.loadingEarlier = .loaded
                    status.loadingLatest = .loaded
                }
                if let errMessage = self.checkResponse(data, response, error) {
                    print(errMessage)
                    return
                }
                if let data = data {
                    let resp = try! JSONDecoder().decode(GCcoresTalkResponse.self, from: data)
                    let talks = resp.formalize()
                    if talks.isEmpty {
                        if earlier {
                            status.loadingEarlier = .empty
                        } else {
                            status.loadingLatest = .empty
                        }
                    }
                    status.talks += talks
                }
            }
        }
        task.resume()
    }
    
    func readTopics(status: ViewStatus, categoryId: String, append: Bool = false) {
        status.requestState = .sending
        if !append { status.selectedTopics.removeAll() }
        var urlString: String
        if categoryId == "popular" {
            urlString = [
                "https://www.gcores.com/gapi/v1/popular-topics?",
                "page%5Boffset%5D=\(status.selectedTopics.count)&page%5Blimit%5D=50&from-app=1"
            ].reduce("", +)
        } else if let userId = loginInfo.userId, categoryId == "subscribed" {
            urlString = [
                "https://www.gcores.com/gapi/v1/users/\(userId)/subscribed-topics?",
                "page%5Boffset%5D=\(status.selectedTopics.count)&page%5Blimit%5D=50&from-app=1"
            ].reduce("", +)
        } else {
            urlString = [
                "https://www.gcores.com/gapi/v1/categories/\(categoryId)/topics?",
                "page%5Boffset%5D=\(status.selectedTopics.count)&page%5Blimit%5D=50&from-app=1"
            ].reduce("", +)
        }
        let url = URL( string: urlString)!
        print("Reading topics from \(url)")
        var request = gcoresRequest(url: url, httpMethod: "GET")
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        let task = session.dataTask(with: request) { data, response, error in
            if let errMessage = self.checkResponse(data, response, error) {
                print(errMessage)
                status.requestState = .failed
                return
            }
            guard let data = data else{ return }
            let resp = try! JSONDecoder().decode(GCoresTopicResponse.self, from: data)
            let topics = resp.formalize()
            print("Got \(topics.count) topics")
            self.mainQueue.async {
                status.selectedTopics += topics
                print("update \(status.selectedTopics.count) topics")
                status.requestState = .succeed
                status.objectWillChange.send()
                if let recordCount = resp.meta.recordCount, status.selectedTopics.count < recordCount {
                    // There are more tags
                    self.readTopics(status: status, categoryId: categoryId, append: true)
                }
                
            }
        }
        task.resume()
    }
    
    
    func readTopicsCategories(status: ViewStatus) {
        let url = URL(
            string: [
                "https://www.gcores.com/gapi/v1/categories?",
                "filter%5Bscope%5D=topic&page%5Blimit%5D=100",
                "&page%5Boffset%5D=\(status.topicCategories.count)&from-app=1"
            ].reduce("", +)
        )!
        let request = gcoresRequest(url: url, httpMethod: "GET")
        let task = session.dataTask(with: request) { data, response, error in
            if let errMessage = self.checkResponse(data, response, error) {
                print(errMessage)
                return
            }
            guard let data = data else{
                return
            }
            let resp = try! JSONDecoder().decode(GCoresTopicCategoryResponse.self, from: data)
            let categories = resp.formalize()
            self.mainQueue.async {
                if status.topicCategories.isEmpty {
                    status.topicCategories.append(TalkTopicCategory(id: "popular", name: "热门", desc: nil, logo: nil, background: nil))
                    status.topicCategories.append(TalkTopicCategory(id: "subscribed", name: "收藏", desc: nil, logo: nil, background: nil))
                }
                status.topicCategories += categories
                if let recordCount = resp.meta.recordCount, status.topicCategories.count < recordCount {
                    // There are more categories
                    self.readTopicsCategories(status: status)
                }
            }
        }
        task.resume()
    }
    
    func readReplies(commentId: String, status: ViewStatus) {
        
        let url = URL(
            string: "https://www.gcores.com/gapi/v1/comments/\(commentId)?include=commentable%2Cuser%2Cparent.user%2Cdescendants.user%2Cdescendants.parent&from-app=1"
        )!
        let request = gcoresRequest(url: url, httpMethod: "GET", body: nil)
        
        let task = session.dataTask(with: request) { data, response, error in
            self.mainQueue.async {
                //                guard let _ = self.readStatusOf(sceneType: _status.sceneType, of: _status.id) else { return }
                status.loadingEarlier = .loaded
                if let errMessage = self.checkResponse(data, response, error) {
                    print("Failed to read replies!")
                    print(errMessage)
                    return
                }
                guard let data = data else{ return }
                
                let resp = try! JSONDecoder().decode(GCcoresTalkReplyResponse.self, from: data)
                let respCards = resp.formalize()
                let comment = respCards[0][0]
                let replies = respCards[1]

                status.loadingEarlier = .empty
                status.targetComment = comment
                status.replies += replies
            }
        }
        task.resume()
    }
    
    func readComments(talkId: String, status: ViewStatus, earlier: Bool) {
        let pageOffset = status.comments.count
        if earlier { status.loadingEarlier = .loading } else { status.loadingLatest = .loading }
        
        let url = URL(
            string: [
                "https://www.gcores.com/gapi/v1/talks/\(talkId)/comments?",
                "include=user%2Cparent.user%2Coldest-descendants.user%2Coldest-descendants.parent&sort=-created-at",
                "&page%5Boffset%5D=\(pageOffset)&page%5Blimit%5D=20&from-app=1"].reduce("", +)
        )!
        let request = gcoresRequest(url: url, httpMethod: "GET", body: nil)
        let task = session.dataTask(with: request) { data, response, error in
            self.mainQueue.async {
                //                guard let _ = self.readStatusOf(sceneType: _status.sceneType, of: _status.id) else { return }
                if earlier { status.loadingEarlier = .loaded } else { status.loadingLatest = .loaded }
                if let errMessage = self.checkResponse(data, response, error) {
                    print("Failed to read comments!")
                    print(errMessage)
                    return
                }
                guard let data = data else{ return }
                
                let resp = try! JSONDecoder().decode(GCcoresTalkCommentResponse.self, from: data)
                let respCards = resp.formalize()
                let comments = respCards[0]
                let replies = respCards[1]
                if comments.isEmpty {
                    if earlier {
                        status.loadingEarlier = .empty
                    } else {
                        status.loadingLatest = .empty
                    }
                } else if earlier{
                    status.comments += comments
                    status.replies += replies
                } else {
                    status.comments = comments
                    status.replies = replies
                }
            }
        }
        task.resume()
    }
    
    
    func readFollowship(status: ViewStatus, earlier: Bool) {
        //        let sceneType = _status.sceneType
        //        guard let idx = indexOf(status: _status) else {
        //            return
        //        }
        guard let userId = status.userId else { return }
        if earlier { status.loadingEarlier = .loading } else { status.loadingLatest = .loading }
        
        var pageOffset = status.followers.count
        var url: URL?
        if status.statusType == .followees {
            pageOffset = status.followees.count
            url = URL(string: [
                "https://www.gcores.com/gapi/v1/users/" + userId + "/followees?",
                "page%5Blimit%5D=40&page%5Boffset%5D=\(pageOffset)&from-app=1"
            ].reduce("", +))
        } else {
            //            status.followers.count
            url = URL(string: [
                "https://www.gcores.com/gapi/v1/users/" + userId + "/followers?",
                "page%5Blimit%5D=40&page%5Boffset%5D=\(pageOffset)&from-app=1"
            ].reduce("", +))
        }
        
        let request = gcoresRequest(url: url!, httpMethod: "GET", body: nil)
        
        let task = session.dataTask(with: request) { data, response, error in
            self.mainQueue.async {
                // The status can be alreaded popped out
                //                guard let _ = self.readStatusOf(sceneType: _status.sceneType, of: _status.id) else { return }
                if earlier { status.loadingEarlier = .loaded } else { status.loadingLatest = .loaded }
                if let errMessage = self.checkResponse(data, response, error) {
                    print("Failed to read users of \(status.statusType)!")
                    print(errMessage)
                    return
                }
                guard let data = data else{ return }
                
                let resp = try! JSONDecoder().decode(GCoresFollowshipResponse.self, from: data)
                let users = resp.formalize()
                if users.isEmpty {
                    if earlier {
                        status.loadingEarlier = .empty
                    } else {
                        status.loadingLatest = .empty
                    }
                } else if earlier{
                    if status.statusType == .followers {
                        status.followers += users
                    } else {
                        status.followees += users
                    }
                } else {
                    if status.statusType == .followers {
                        status.followers = users
                    } else {
                        status.followees = users
                    }
                }
                
                //                self.publisherTrigger = "Read users!"
            }
        }
        task.resume()
    }
    
    
    func readUserInfo(userId: String, status: ViewStatus?) {
        let url = URL(
            string: [
                "https://www.gcores.com/gapi/v1/users/\(userId)?",
                "include=latest-articles.user%2Clatest-articles.category%2Clatest-radios.user%2Clatest-radios.category%2Clatest-videos.user%2C",
                "latest-videos.category%2Centities.involvements.entry&fields%5Barticles%5D=category%2Cuser%2Cdjs%2Ccollections%2C",
                "published-collections%2Ccomments%2Cdjs%2Centities%2Centries%2Clatest-collection%2Cmedia%2Csimilarities%2Cskus%2Ctags%2C",
                "app-cover%2Cbookmarks-count%2Ccomments-count%2Ccover%2Cdesc%2Cduration%2Cpublished-at%2Cis-comment-hidden%2Cis-published%2C",
                "is-verified%2Cis-free%2Clikes-count%2Coption-is-focus-showcase%2Coption-is-official%2Cthumb%2Ctitle%2Cvol%2Cis-official%2C",
                "speech-path%2Chas-giveaway&fields%5Bradios%5D=albums%2Ccategory%2Cuser%2Cdjs%2Cpublished-albums%2Ccollections%2Ccomments%2C",
                "djs%2Centities%2Centries%2Clatest-collection%2Cmedia%2Csimilarities%2Cskus%2Ctags%2Capp-cover%2Cbookmarks-count%2C",
                "comments-count%2Ccover%2Cdesc%2Cduration%2Cpublished-at%2Cis-comment-hidden%2Cis-published%2Cis-verified%2Cis-free%2C",
                "likes-count%2Ctimelines-images-url%2Coption-is-focus-showcase%2Coption-is-official%2Cthumb%2Ctitle%2Cvol%2Cis-official%2C",
                "speech-path%2Chas-giveaway&fields%5Bvideos%5D=category%2Cuser%2Cdjs%2Ccollections%2Cpublished-collections%2Ccomments%2Cdjs%2C",
                "entities%2Centries%2Clatest-collection%2Cmedia%2Csimilarities%2Cskus%2Ctags%2Capp-cover%2Cbookmarks-count%2Ccomments-count%2C",
                "cover%2Cdesc%2Cduration%2Cpublished-at%2Cis-comment-hidden%2Cis-published%2Cis-verified%2Cis-free%2Clikes-count%2C",
                "option-is-focus-showcase%2Coption-is-official%2Cthumb%2Ctitle%2Cvol%2Cis-official%2Cspeech-path%2Chas-giveaway&from-app=1"
            ].reduce("", +)
        )!
        let request = gcoresRequest(url: url, httpMethod: "GET")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let errMessage = self.checkResponse(data, response, error) {
                print("Failed to read comments!")
                print(errMessage)
                return
            }
            guard let data = data else{ return }
            
            let resp = try! JSONDecoder().decode(GCoresUserResponse.self, from: data)
            let user = resp.formalize()
            self.mainQueue.async {
                if let status = status {
                    status.user = user
                }
                if let me = self.user {
                    if me.id == user.id {
                        self.user = user
                    }
                } else {
                    self.user = user
                }
            }
        }
        task.resume()
    }
    
    
    
    
    // MARK: Intends
    func cancelVote(targetId: String, targetType: VoteTargetType, voteId: String, status: ViewStatus) {
        //        let sceneType = status.sceneType
        //        let idx = indexOf(status: status)!
        status.updateVotes(targetId: targetId, targetType: targetType, isVoting: true)
        objectWillChange.send()
        let url = URL(string: "https://www.gcores.com/gapi/v1/votes/\(voteId)?from-app=1")!
        let request = gcoresRequest(url: url, httpMethod: "DELETE")
        URLSession.shared.dataTask(with: request) { data, response, error in
            self.mainQueue.async {
                //                guard let _ = self.readStatusOf(sceneType: status.sceneType, of: status.id) else {return}
                if let errorMessage = self.checkResponse(data,  response, error) {
                    print("Failed to vote to \(targetType)(\(targetId))!")
                    print(errorMessage)
                    status.updateVotes(targetId: targetId, targetType: targetType, isVoting: false)
                    return
                }
                status.updateVotes(targetId: targetId, targetType: targetType, voteFlag: nil, voteId: nil)
                
            }
        }
        .resume()
        
    }
    func voteTo(targetId: String, targetType: VoteTargetType, voteFlag: Bool, status: ViewStatus) {
        //        {
        //          "data": {
        //            "attributes": {
        //              "vote-flag": true
        //            },
        //            "relationships": {
        //              "votable": {
        //                "data": {
        //                  "id": "144942",
        //                  "type": "talks"
        //                }
        //              },
        //              "voter": {
        //                "data": {
        //                  "id": "17551",
        //                  "type": "users"
        //                }
        //              }
        //            },
        //            "type": "votes"
        //          }
        //        }
        //        let status = readCurrentStatus()
        // set the vote flag of a card to success/failed/progress
        //        let sceneType = _status.sceneType
        //        guard let idx = indexOf(status: _status) else {
        //            return
        //        }
        let userId = loginInfo.userId
        status.updateVotes(targetId: targetId, targetType: targetType, isVoting: true)
        //        publisherTrigger = "voting"
        
        // send the request
        let parameters: [String: Any] = [
            "data": [
                "attributes": [
                    "vote-flag": voteFlag
                ],
                "relationships": [
                    "votable": [
                        "data": [
                            "id": targetId,
                            "type": String(targetType.rawValue)
                        ]
                    ],
                    "voter": [
                        "data": [
                            "id": userId,
                            "type": "users"
                        ]
                    ],
                ],
                "type": "votes"
            ]
        ]
        let voteData = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        let url = URL(string: "https://www.gcores.com/gapi/v1/votes?from-app=1")!
        let request = gcoresRequest(url: url, httpMethod: "POST", body: voteData)
        URLSession.shared.dataTask(with: request) { data, response, error in
            self.mainQueue.async {
                //                guard let _ = self.readStatusOf(sceneType: _status.sceneType, of: _status.id) else {return}
                if let errorMessage = self.checkResponse(data,  response, error) {
                    print("Failed to vote to \(targetType)(\(targetId))!")
                    print(errorMessage)
                    status.updateVotes(targetId: targetId, targetType: targetType, isVoting: false)
                    //                    self.publisherTrigger = "voting"
                    return
                }
                
                guard let res = response as? HTTPURLResponse, res.statusCode == 201, let data = data else {
                    switch targetType {
                    case .comments:
                        let idx = status.comments.firstIndex(where: {$0.id == targetId})!
                        status.comments[idx].isVoting = false
                    case .talks:
                        let idx = status.talks.firstIndex(where: {$0.id == targetId})!
                        status.talks[idx].isVoting = false
                    }
                    return
                }
                let voteRes = try! JSONDecoder().decode(GCoresVoteResponse.self, from: data)
                status.updateVotes(targetId: targetId, targetType: targetType, voteFlag: voteRes.data.attributes.voteFlag, voteId: voteRes.data.id)
            }
        }
        .resume()
    }
    
    func sendComment(talkId: String, commentId: String?, status: ViewStatus, comment: String) {
        //        let sceneType = _status.sceneType
        //        guard let idx = indexOf(status: _status) else { return }
        let userId = loginInfo.userId
        //        NSWindowRequestStates[uuid] = .sending
        status.requestLatest = .sending
        //        self.statusForScene[sceneType]![idx].sendState = .sending
        var data: [String: String]? = nil
        if let commentId = commentId {
            data = [
                "id": commentId,
                "type": "comments"
            ]
        }
        let parameters: [String: Any] = [
            "data": [
                "attributes": [
                    "body": comment
                ],
                "relationships": [
                    "commentable": [
                        "data": [
                            "id": talkId,
                            "type": "talks"
                        ]
                    ],
                    "parent": [
                        "data": data,
                    ],
                    "subcommentable": [
                        "data": nil
                    ],
                    "user": [
                        "data": [
                            "id": userId,
                            "type": "users"
                        ]
                    ],
                ],
                "type": "comments"
            ]
        ]
        let commentData = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        let url = URL(string: "https://www.gcores.com/gapi/v1/comments?include=user%2Ccommentable%2Cparent.user&from-app=1")!
        let request = gcoresRequest(url: url, httpMethod: "POST", body: commentData)
        URLSession.shared.dataTask(with: request) { data, response, error in
            self.mainQueue.async {
                //                guard let _ = self.readStatusOf(sceneType: _status.sceneType, of: _status.id) else {return}
                if let errorMessage = self.checkResponse(data,  response, error) {
                    print("Failed to comment to \(talkId)-(\(String(describing: commentId)))!")
                    print(errorMessage)
                    //                    self.NSWindowRequestStates[uuid] = .failed
                    status.requestLatest = .failed
                    return
                }
                
                guard let res = response as? HTTPURLResponse, res.statusCode == 201, let data = data else {
                    //                    self.NSWindowRequestStates[uuid] = .failed
                    status.requestLatest = .failed
                    return
                }
                let commentRes = try! JSONDecoder().decode(NewCommentResponse.self, from: data)
                let comment = commentRes.formalize()
                //                let comment = testComment
                // Got response from the server about the sent comment
                // Insert the comment to the list maintained by current status
                // * For talkTimeLine status:
                // The comment is to a talk.
                //  Update the number of comments to the target talk.
                if let targetTalkIndex = status.talks.firstIndex(where: {$0.id == talkId}) {
                    let count = status.talks[targetTalkIndex].commentsCount ?? 0
                    status.talks[targetTalkIndex].commentsCount = count + 1
                }
                // * For commentsList status, update the comment count of target Talk
                if let _ = status.targetTalk {
                    let count = status.targetTalk!.commentsCount ?? 0
                    status.targetTalk!.commentsCount = count + 1
                }
                
                if commentId == nil {
                    //  And
                    //      * If the comment is replied to the target talk, add the comment to the commentList
                    status.comments.insert(comment, at: 0)
                } else {
                    //      * If the comment is replied to a comment or a reply, append the new comment to the replies list,
                    status.replies.append(comment)
                    //      * If the comment is replied to a comment ,locate the targetComment and nsert the new commentId to its oldestDecendant list
                    if let index = status.comments.firstIndex(where: {$0.id == commentId}) {
                        status.comments[index].oldestDescendants.append(comment.id)
                    }
                    //      * If the comment is replied to a reply, locate the targetComment by its parentId
                    else if let commendIndex = status.comments.firstIndex(where: { element in
                        if element.oldestDescendants.contains(where: {$0 == comment.replyTo}) {
                            return true
                        } else {
                            return false
                        }
                    }){
                        status.comments[commendIndex].oldestDescendants.append(comment.id)
                    }
                    
                }
                NSApplication.shared.keyWindow?.close()
            }
        }
        .resume()
    }
    
    func logout() {
        // TODO: post to server to logout
        uds.removeObject(forKey: "loginInfo")
        uds.synchronize()
        loginInfo.token = nil
        loginInfo.userId = nil
        loginInfo.loginState = .logout
    }
    
    func login(userName: String, password: String) {
        
        let parameters: [String: Any] = [
            "data": [
                "code": nil,
                "password": password,
                "provider": "identity",
                "remember": true,
                "uid": nil,
                "username": userName
            ]
        ]
        
        
        let loginData = try? JSONSerialization.data(withJSONObject: parameters)
        
        let url = URL(string: "https://www.gcores.com/gapi/v1/tokens/refresh?from-app=1")!
        let request = gcoresRequest(url: url, httpMethod: "POST", body: loginData)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let errorMessage = self.checkResponse(data,  response, error) {
                print("Failed to login with errors!")
                print(errorMessage)
                self.mainQueue.async {
                    self.loginInfo.loginState = .failed
                }
                return
            }
            guard let data = data else{ return }
            self.mainQueue.async {
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    let data = json["data"] as! [String: String]
                    let userId = data["user-id"]!
                    let token = data["token"]!
                    let cookie = (response as! HTTPURLResponse).value(forHTTPHeaderField: "Set-Cookie")
                    self.loginInfo.loginState = .succeed
                    self.loginInfo.token = token
                    self.loginInfo.userId = userId
                    self.loginInfo.cookie = cookie
                    
                    self.readUserInfo(userId: userId, status: self.statusForScene[.profile]?.first)
                    
                    let loginData = ["userId": userId, "token": token, "cookie": cookie]
                    self.uds.set(loginData, forKey: "loginInfo")
                    self.uds.synchronize()
                    
                    print("Login sucessed!")
                    print("userId: \(userId)")
                    print("token: \(token)")
                } else {
                    print("Failed to login!")
                    print("No json data was returned from the server!")
                    self.loginInfo.loginState = .failed
                }
            }
        }
        task.resume()
    }
    
    func back() {
        if let count = statusForScene[selectedTalkSceneType]?.count, count > 1 {
            _ = statusForScene[selectedTalkSceneType]!.popLast()
        }
    }
    
    //    func readRelated(_status: ViewStatus, )
    
    func readTimeline(status: ViewStatus, earlier: Bool, userId: String? = nil) {
        var endpoint: TimelineEndPoint
        switch status.statusType {
        case .followeeTimeline:
            endpoint = .followee
        case .topicTimeline:
            endpoint = .topic
        case .profile:
            endpoint = .user
        case .recommendTimeline:
            endpoint = .recommend
        default:
            endpoint = .recommend
            break
        }
        readTalks(status: status, endpoint: endpoint, earlier: earlier)
        
    }
    
    
    func select(sidebarItem: TalkScene) {
        selectedTalkSceneType = sidebarItem.sceneType
        print(selectedTalkSceneType)
    }
    
    //    func select(topicCategory: TalkTopicCategory, ) {
    //        selectedTopicCategory = topicCategory
    //    }
    
    func search(status: ViewStatus, endponit: GCoresRelatedType, query: String, earlier: Bool, recommend: Bool) {
        //        guard NSWindowStatus[searchId] != nil else { return }
        if query == "" && !recommend {
            return
        }
        if earlier {
            status.requestLatest = .succeed
            status.requestEarlier = .sending
        } else {
            status.requestEarlier = .succeed
            status.requestLatest = .sending
            status.searchResults.removeAll()
        }
        var pageOffset = 0
        if earlier {
            pageOffset = status.searchResults.count
        }
        var urlStr: String
        if recommend {
            switch endponit {
            case .games:
                urlStr = [
                    "https://www.gcores.com/gapi/v1/games/search?sort=-onsale-start",
                    "&filter%5Bonsale%5D=true&filter%5Brevised%5D=true&page%5Boffset%5D=\(pageOffset)&page%5Blimit%5D=20&from-app=1"
                ].reduce("", +)
            case .articles, .videos, .radios:
                urlStr = [
                    "https://www.gcores.com/gapi/v1/\(endponit)?sort=-published-at",
                    "&filter%5Blist-all%5D=0&page%5Boffset%5D=\(pageOffset)&page%5Blimit%5D=20",
                    "&fields%5Bradios%5D=albums%2Ccategory%2Cuser%2Cdjs%2Cpublished-albums%2Ccollections%2Ccomments%2Cdjs%2Centities%2C",
                    "entries%2Clatest-collection%2Cmedia%2Csimilarities%2Cskus%2Ctags%2Capp-cover%2Cbookmarks-count%2Ccomments-count%2C",
                    "cover%2Cdesc%2Cduration%2Cpublished-at%2Cis-comment-hidden%2Cis-published%2Cis-verified%2Cis-free%2Clikes-count%2C",
                    "timelines-images-url%2Coption-is-focus-showcase%2Coption-is-official%2Cthumb%2Ctitle%2Cvol%2Cis-official%2Cspeech-path%2Chas-giveaway",
                    "&fields%5Barticles%5D=category%2Cuser%2Cdjs%2Ccollections%2Cpublished-collections%2Ccomments%2Cdjs%2Centities%2Centries%2C",
                    "latest-collection%2Cmedia%2Csimilarities%2Cskus%2Ctags%2Capp-cover%2Cbookmarks-count%2Ccomments-count%2Ccover%2Cdesc%2C",
                    "duration%2Cpublished-at%2Cis-comment-hidden%2Cis-published%2Cis-verified%2Cis-free%2Clikes-count%2Coption-is-focus-showcase%2C",
                    "option-is-official%2Cthumb%2Ctitle%2Cvol%2Cis-official%2Cspeech-path%2Chas-giveaway&fields%5Bvideos%5D=category%2Cuser%2Cdjs%2C",
                    "collections%2Cpublished-collections%2Ccomments%2Cdjs%2Centities%2Centries%2Clatest-collection%2Cmedia%2Csimilarities%2Cskus%2Ctags%2C",
                    "app-cover%2Cbookmarks-count%2Ccomments-count%2Ccover%2Cdesc%2Cduration%2Cpublished-at%2Cis-comment-hidden%2Cis-published%2Cis-verified%2C",
                    "is-free%2Clikes-count%2Coption-is-focus-showcase%2Coption-is-official%2Cthumb%2Ctitle%2Cvol%2Cis-official%2Cspeech-path%2Chas-giveaway&from-app=1"
                ].reduce("", +)
            default:
                return
            }
        } else {
            urlStr = [
                "https://www.gcores.com/gapi/v1/search?",
                "query=\(query)&type=\(endponit)&order-by=score&page[offset]=\(pageOffset)&page[limit]=20&from-app=1"
            ].reduce("", +).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        }
        print(urlStr)
        let url = URL( string: urlStr )!
        
        let request = gcoresRequest(url: url, httpMethod: "GET")
        
        let task = session.dataTask(with: request) { data, response, error in
            self.mainQueue.async {
                // the status is still alive
                //                guard self.NSWindowStatus[searchId] != nil else { return }
                if let errMessage = self.checkResponse(data, response, error) {
                    print(errMessage)
                    return
                }
                if let data = data {
                    let resp = try! JSONDecoder().decode(GCoresSearchResponse.self, from: data)
                    let searchResults = resp.formalize()
                    if searchResults.isEmpty || status.searchResults.count >= resp.meta.recordCount {
                        if earlier {
                            status.requestEarlier = .empty
                        } else {
                            status.requestLatest = .empty
                        }
                        return
                    }
                    
                    
                    if let newLast = searchResults.last, let oldLast = status.searchResults.last, newLast == oldLast {
                        if earlier {
                            status.requestEarlier = .succeed
                        } else {
                            status.requestLatest = .succeed
                        }
                        return
                    }
                    if earlier {
                        status.searchResults += searchResults
                    } else {
                        status.searchResults = searchResults
                    }
                    if earlier {
                        status.requestEarlier = .succeed
                    } else {
                        status.requestLatest = .succeed
                    }
                    //                    print("count: \(count)")
                }
            }
        }
        task.resume()
    }
}
