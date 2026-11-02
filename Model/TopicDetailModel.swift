//
//  TopicDetailModel.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/16/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

import Alamofire
import Ji
import YYText
import Kingfisher
class TopicDetailModel:NSObject,BaseHtmlModelProtocol {
    var topicId:String?
    
    var avata: String?
    var nodeName: String?
    var node: String?
    
    var userName: String?
    
    var topicTitle: String?
    var topicContent: String?
    var date: String?
    var favorites: String?
    
    var topicCommentTotalCount: String?
    
    var token:String?

    var commentTotalPages:Int = 1
    
    override init() {
        
    }
    required init(rootNode: JiNode) {
        let node = rootNode.xPath("./div[1]//a[starts-with(@href, '/go/')]").first
        self.nodeName = node?.content
        
        if let nodeUrl = node?["href"], let index = nodeUrl.range(of: "/", options: .backwards) {
            let temp = nodeUrl[index.upperBound...]
            self.node = String(temp)
        }
        
        self.avata = rootNode.xPath("./div[1]/div[1]/a/img").first?["src"]
        
        self.userName = rootNode.xPath("./div[1]/small/a").first?.content
        
        self.topicTitle = rootNode.xPath("./div[1]/h1").first?.content
        
        self.topicContent = rootNode.xPath("./div[@class='cell']/div").first?.rawContent
        if self.topicContent == nil {
            self.topicContent = ""
        }
        // Append
        let appendNodes = rootNode.xPath("./div[@class='subtle']") ;
        
        for node in appendNodes {
            if let content =  node.rawContent {
                self.topicContent! += content
            }
        }
        
        
        self.date = rootNode.xPath("./div[1]/small/span").first?.content
            ?? rootNode.xPath("./div[1]/small/text()[2]").first?.content
        
        self.favorites = rootNode.xPath("./div[3]/div/span").first?.content
        
        let token = rootNode.xPath("div/div/a[@class='op'][1]").first?["href"]
        if let token = token {
            let array = token.components(separatedBy: "?once=")
            if array.count == 2 {
                self.token = array[1]
            }
        }
    }
}


//MARK: -  Request
extension TopicDetailModel {
    private class func comments(in html: Ji) -> [TopicCommentModel] {
        let nodes = html.xPath("//*[@id='topic-replies']/div[contains(concat(' ', normalize-space(@class), ' '), ' box ')]/div[starts-with(@id, 'r_')] | //*[@id='Wrapper']/div[@class='content']/div[@class='box']/div[@id and @class='cell']") ?? []
        return nodes.map { TopicCommentModel(rootNode: $0) }
    }

    class func getTopicDetailById(
        _ topicId: String,
        completionHandler: @escaping (V2ValueResponse<(TopicDetailModel?,[TopicCommentModel])>) -> Void
        )->Void{
        
        let url = V2EXURL + "t/" + topicId + "?p=1"
        AF.request(url, headers: HTTPHeaders(MOBILE_CLIENT_HEADERS)).responseJiHtml { (response) -> Void in
            if let error = response.error {
                completionHandler(V2ValueResponse(success: false, message: error.underlyingError?.localizedFailureReason ?? error.localizedFailureReason ?? "请求失败"))
                return
            }
            var topicModel: TopicDetailModel? = nil
            var topicCommentsArray : [TopicCommentModel] = []
            if  let jiHtml = response.value {
                //获取帖子内容
                if let aRootNode = jiHtml.xPath("//*[@id='Main']/div[div[contains(concat(' ', normalize-space(@class), ' '), ' header ')]][1]")?.first
                    ?? jiHtml.xPath("//*[@id='Wrapper']/div/div[1]")?.first {
                    topicModel = TopicDetailModel(rootNode: aRootNode);
                    topicModel?.topicId = topicId
                }
                
                //获取评论
                topicCommentsArray = comments(in: jiHtml)
                
                //获取评论总数
                topicModel?.topicCommentTotalCount = jiHtml.xPath("//*[@id='topic-replies']/div[contains(concat(' ', normalize-space(@class), ' '), ' box ')]/div/span[@class='gray']")?.first?.content
                    ?? jiHtml.xPath("//*[@id='Wrapper']/div[@class='content']/div[@class='box']/div[@class='cell']/span[@class='gray']")?.first?.content
                
                //获取页数总数
                let pageMax = jiHtml.xPath("//*[@id='topic-replies']//input[@class='page_input']")?.first?["max"]
                let pageLinks = jiHtml.xPath("//*[@id='topic-replies']//a[@class='page_normal' or @class='page_current'] | //*[@id='Wrapper']/div[@class='content']/div[@class='box']/div[last()]/a[@class='page_normal' or @class='page_current']") ?? []
                let pages = pageLinks.compactMap { $0.content.flatMap { Int($0) } }.max() ?? 1
                topicModel?.commentTotalPages = max(Int(pageMax ?? "") ?? 1, pages)
                
                //更新通知数量
                V2User.sharedInstance.getNotificationsCount(jiHtml.rootNode!)
            }
            
            let t = V2ValueResponse<(TopicDetailModel?,[TopicCommentModel])>(value:(topicModel,topicCommentsArray), success: response.error == nil)
            
            completionHandler(t);
        }
    }
    
    class func getTopicCommentsById(
        _ topicId: String,
        page:Int,
        completionHandler: @escaping (V2ValueResponse<[TopicCommentModel]>) -> Void
        ) {
        let url = V2EXURL + "t/" + topicId + "?p=\(page)"
        AF.request(url, headers: HTTPHeaders(MOBILE_CLIENT_HEADERS)).responseJiHtml { (response) -> Void in
            var topicCommentsArray : [TopicCommentModel] = []
            if  let jiHtml = response.value {
                //获取评论
                topicCommentsArray = comments(in: jiHtml)
                
            }
            let t = V2ValueResponse(value: topicCommentsArray, success: response.error == nil)
            completionHandler(t);
        }
    }
    
    /**
     感谢主题
     */
    class func topicThankWithTopicId(_ topicId:String , token:String ,completionHandler: @escaping (V2Response) -> Void) {
        
        _ = TopicApi.provider.requestAPI(.thankTopic(topicId: topicId, once: token))
            .filterResponseError().subscribe(onNext: { (response) in
            if response["success"].boolValue {
                completionHandler(V2Response(success: true))
            }
            else{
                completionHandler(V2Response(success: false, message: response["message"].rawString() ?? ""))
            }
        }, onError: { (error) in
            completionHandler(V2Response(success: false))
        })
        
    }
    
    /**
     收藏主题
     */
    class func favoriteTopicWithTopicId(_ topicId:String , token:String ,completionHandler: @escaping (V2Response) -> Void) {
        let url  = V2EXURL + "favorite/topic/" + topicId + "?once=" + token
        AF.request(url, headers: HTTPHeaders(MOBILE_CLIENT_HEADERS)).responseString { (response: AFDataResponse<String>) -> Void in
            if response.error == nil {
                completionHandler(V2Response(success: true))
            }
            else{
                completionHandler(V2Response(success: false))
            }
        }
    }
    /**
     忽略主题
     */
    class func ignoreTopicWithTopicId(_ topicId:String ,completionHandler: @escaping (V2Response) -> Void) {
        
        V2User.sharedInstance.getOnce { (response) -> Void in
            if response.success ,let once = V2User.sharedInstance.once {
                let url  = V2EXURL + "ignore/topic/" + topicId + "?once=" + once
                AF.request(url, headers: HTTPHeaders(MOBILE_CLIENT_HEADERS)).responseString { (response: AFDataResponse<String>) -> Void in
                    if response.error == nil {
                        completionHandler(V2Response(success: true))
                        return
                    }
                    else{
                        completionHandler(V2Response(success: false))
                    }
                }
            }
            else{
                completionHandler(V2Response(success: false))
            }
        }
    }

}
