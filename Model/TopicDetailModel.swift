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

class TopicDetailModel:NSObject,BaseHtmlModelProtocol {
    var avata: String?
    var nodeName: String?
    var nodeUrl: String?
    
    var userName: String?
    
    var topicTitle: String?
    var topicContent: String?
    var date: String?
    var favorites: String?
    
    required init(rootNode: JiNode) {
        let node = rootNode.xPath("./div[1]/a[2]").first
        self.nodeName = node?.content
        self.nodeUrl = node?["href"]
        
        self.avata = rootNode.xPath("./div[1]/div[1]/a/img").first?["src"]
        
        self.userName = rootNode.xPath("./div[1]/small/a").first?.content
        
        self.topicTitle = rootNode.xPath("./div[1]/h1").first?.content
        
        self.topicContent = rootNode.xPath("./div[2]/div").first?.rawContent
        
        self.date = rootNode.xPath("./div[1]/small/text()[2]").first?.content
        
        self.favorites = rootNode.xPath("./div[3]/div/span").first?.content
    }
    
    
    class func getTopicDetailById(
        topicId: String,
        completionHandler: V2Response<(TopicDetailModel?,[TopicCommentModel])> -> Void
        )->Void{
            
            let url = "https" + "://www.v2ex.com/t/" + topicId + "?p=1"
            
            Alamofire.request(.GET, url, parameters: nil, encoding: .URL, headers: CLIENT_HEADERS).responseString { (response: Response<String,NSError>) -> Void in
                var topicModel: TopicDetailModel? = nil
                var topicCommentsArray : [TopicCommentModel] = []
                if let html = response .result.value{
                    let jiHtml = Ji(htmlString: html);
                    //获取帖子内容
                    if let aRootNode = jiHtml?.xPath("//*[@id='Wrapper']/div/div[1]")?.first{
                        topicModel = TopicDetailModel(rootNode: aRootNode);
                    }
                    
                    //获取评论
                    if let aRootNode = jiHtml?.xPath("//*[@id='Wrapper']/div/div[@class='box'][2]/div[attribute::id]"){
                        for aNode in aRootNode {
                            topicCommentsArray.append(TopicCommentModel(rootNode: aNode))
                        }
                    }
                }
                let t = V2Response<(TopicDetailModel?,[TopicCommentModel])>(value:(topicModel,topicCommentsArray), success: response.result.isSuccess)
                completionHandler(t);
            }
            
    }
}

class TopicCommentModel: NSObject,BaseHtmlModelProtocol {
    var avata: String?
    var userName: String?
    var date: String?
    var comment: String?
    var favorites: String?
    required init(rootNode: JiNode) {
        
        self.avata = rootNode.xPath("table/tr/td[1]/img").first?["src"]
        
        self.userName = rootNode.xPath("table/tr/td[3]/strong/a").first?.content
        
        self.date = rootNode.xPath("table/tr/td[3]/span").first?.content
        
        self.favorites =  rootNode.xPath("table/tr/td[3]/span[2]").first?.content
        
        self.comment = rootNode.xPath("table/tr/td[3]/div[@class='reply_content']").first?.content
    }
}
