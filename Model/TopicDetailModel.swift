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
        let node = rootNode.xPath("./div[1]/a[2]").first
        self.nodeName = node?.content
        
        let nodeUrl = node?["href"]
        let index = nodeUrl?.rangeOfString("/", options: .BackwardsSearch, range: nil, locale: nil)
        self.node = nodeUrl?.substringFromIndex(index!.endIndex)
        
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
        
        
        self.date = rootNode.xPath("./div[1]/small/text()[2]").first?.content
        
        self.favorites = rootNode.xPath("./div[3]/div/span").first?.content
        
        let token = rootNode.xPath("div/div/a[@class='op'][1]").first?["href"]
        if let token = token {
            let array = token.componentsSeparatedByString("?t=")
            if array.count == 2 {
                self.token = array[1]
            }
        }
    }
}


//MARK: -  Request
extension TopicDetailModel {
    class func getTopicDetailById(
        topicId: String,
        completionHandler: V2ValueResponse<(TopicDetailModel?,[TopicCommentModel])> -> Void
        )->Void{
        
        let url = V2EXURL + "t/" + topicId + "?p=1"
        
        Alamofire.request(.GET, url, parameters: nil, encoding: .URL, headers: MOBILE_CLIENT_HEADERS).responseJiHtml { (response) -> Void in
            var topicModel: TopicDetailModel? = nil
            var topicCommentsArray : [TopicCommentModel] = []
            if  let jiHtml = response.result.value {
                //获取帖子内容
                if let aRootNode = jiHtml.xPath("//*[@id='Wrapper']/div/div[1]")?.first{
                    topicModel = TopicDetailModel(rootNode: aRootNode);
                    topicModel?.topicId = topicId
                }
                
                //获取评论
                if let aRootNode = jiHtml.xPath("//*[@id='Wrapper']/div/div[@class='box'][2]/div[attribute::id]"){
                    for aNode in aRootNode {
                        topicCommentsArray.append(TopicCommentModel(rootNode: aNode))
                    }
                }
                
                //获取评论总数
                if let commentTotalCount = jiHtml.xPath("//*[@id='Wrapper']/div/div[3]/div[1]/span") {
                    topicModel?.topicCommentTotalCount = commentTotalCount.first?.content
                }
                
                //获取页数总数
                if let commentTotalPages = jiHtml.xPath("//*[@id='Wrapper']/div/div[@class='box'][2]/div[last()]/a[last()]")?.first?.content {
                    if let pages = Int(commentTotalPages) {
                        topicModel?.commentTotalPages = pages
                    }
                }
                
                //更新通知数量
                V2User.sharedInstance.getNotificationsCount(jiHtml.rootNode!)
            }
            
            let t = V2ValueResponse<(TopicDetailModel?,[TopicCommentModel])>(value:(topicModel,topicCommentsArray), success: response.result.isSuccess)
            
            completionHandler(t);
        }
    }
    
    class func getTopicCommentsById(
        topicId: String,
        page:Int,
        completionHandler: V2ValueResponse<[TopicCommentModel]> -> Void
        ) {
        let url = V2EXURL + "t/" + topicId + "?p=\(page)"
        Alamofire.request(.GET, url, parameters: nil, encoding: .URL, headers: MOBILE_CLIENT_HEADERS).responseJiHtml { (response) -> Void in
            var topicCommentsArray : [TopicCommentModel] = []
            if  let jiHtml = response.result.value {
                //获取评论
                if let aRootNode = jiHtml.xPath("//*[@id='Wrapper']/div/div[@class='box'][2]/div[attribute::id]"){
                    for aNode in aRootNode {
                        topicCommentsArray.append(TopicCommentModel(rootNode: aNode))
                    }
                }
                
            }
            let t = V2ValueResponse(value: topicCommentsArray, success: response.result.isSuccess)
            completionHandler(t);
        }
    }
    
    /**
     感谢主题
     */
    class func topicThankWithTopicId(topicId:String , token:String ,completionHandler: V2Response -> Void) {
        let url  = V2EXURL + "thank/topic/" + topicId + "?t=" + token
        Alamofire.request(.POST, url, parameters: nil, encoding: .URL, headers: MOBILE_CLIENT_HEADERS).responseString { (response: Response<String,NSError>) -> Void in
            if response.result.isSuccess {
                if let result = response.result.value {
                    if result.Lenght == 0 {
                        completionHandler(V2Response(success: true))
                        return;
                    }
                }
            }
            completionHandler(V2Response(success: false))
        }
    }
    
    /**
     收藏主题
     */
    class func favoriteTopicWithTopicId(topicId:String , token:String ,completionHandler: V2Response -> Void) {
        let url  = V2EXURL + "favorite/topic/" + topicId + "?t=" + token
        Alamofire.request(.GET, url, parameters: nil, encoding: .URL, headers: MOBILE_CLIENT_HEADERS).responseString { (response: Response<String,NSError>) -> Void in
            if response.result.isSuccess {
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
    class func ignoreTopicWithTopicId(topicId:String ,completionHandler: V2Response -> Void) {
        
        V2User.sharedInstance.getOnce { (response) -> Void in
            if response.success ,let once = V2User.sharedInstance.once {
                let url  = V2EXURL + "ignore/topic/" + topicId + "?once=" + once
                Alamofire.request(.GET, url, parameters: nil, encoding: .URL, headers: MOBILE_CLIENT_HEADERS).responseString { (response: Response<String,NSError>) -> Void in
                    if response.result.isSuccess {
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
