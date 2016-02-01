//
//  MemberModel.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2/1/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import Alamofire
import Ji

class MemberModel: NSObject ,BaseHtmlModelProtocol{
    var avata: String?
    var userName:String?
    var introduce:String?
    var topics:[MemberTopicsModel] = []
    var replies:[MemberRepliesModel] = []
    required init(rootNode: JiNode) {
        self.avata = rootNode.xPath("./td[1]/img").first?["src"]
        self.userName = rootNode.xPath("./td[3]/h1").first?.content
        self.introduce = rootNode.xPath("./td[3]/span[1]").first?.content
    }
    
    class func getMemberInfo(username:String , completionHandler: (V2ValueResponse<MemberModel> -> Void)? = nil) {
    
        let url = V2EXURL + "member/" + username
        Alamofire.request(.GET, url, parameters: nil, encoding: .URL, headers: MOBILE_CLIENT_HEADERS).responseString { (response: Response<String,NSError>) -> Void in
            if let html = response .result.value{
                if let jiHtml = Ji(htmlString: html){
                    
                    if let aRootNode = jiHtml.xPath("//*[@id='Wrapper']/div/div[1]/div[1]/table/tr")?.first{
                        
                        let member = MemberModel(rootNode: aRootNode);
                        if let rootNodes = jiHtml.xPath("//*[@id='Wrapper']/div/div[@class='box'][2]/div[@class='cell item']") {
                            for rootNode  in rootNodes {
                                member.topics.append(MemberTopicsModel(memberTopicRootNode:rootNode))
                            }
                        }
                        
                        if let rootNodes = jiHtml.xPath("//*[@id='Wrapper']/div/div[@class='box'][3]/div[@class='dock_area']") {
                            for rootNode in rootNodes {
                                let replyModel = MemberRepliesModel(rootNode:rootNode)

                                if  let replyNode = rootNode.nextSibling {
                                    replyModel.reply = replyNode.xPath("./div").first?.content
                                }
                                
                                member.replies.append(replyModel)
                            }
                        }
                        
                        completionHandler?(V2ValueResponse(value: member, success: true))
                        
                        
                    }
                }

            }
            completionHandler?(V2ValueResponse(success: false))
        }
    }
    
}

class MemberTopicsModel: TopicListModel {
    init(memberTopicRootNode:JiNode){
        super.init()
        
        self.nodeName = memberTopicRootNode.xPath("./table/tr/td[1]/span[1]/a[1]").first?.content
        self.userName = memberTopicRootNode.xPath("./table/tr/td[1]/span[1]/strong[1]/a[1]")[0].content
        
        let node = memberTopicRootNode.xPath("./table/tr/td[1]/span[2]/a[1]")[0]
        self.topicTitle = node.content
        
        var topicIdUrl = node["href"];
        
        if var id = topicIdUrl {
            if let range = id.rangeOfString("/t/") {
                id.replaceRange(range, with: "");
            }
            if let range = id.rangeOfString("#") {
                id = id.substringToIndex(range.startIndex)
                topicIdUrl = id
            }
        }
        self.topicId = topicIdUrl
        
        
        self.date = memberTopicRootNode.xPath("./table/tr/td[1]/span[3]")[0].content
        
        var lastReplyUserName:String? = nil
        if let lastReplyUser = memberTopicRootNode.xPath("./table/tr/td[1]/span[3]/strong[1]/a[1]").first{
            lastReplyUserName = lastReplyUser.content
        }
        self.lastReplyUserName = lastReplyUserName
        
        var replies:String? = nil;
        if let reply = memberTopicRootNode.xPath("./table/tr/td[2]/a[1]").first {
            replies = reply.content
        }
        self.replies  = replies

        
    }
}
class MemberRepliesModel: NSObject ,BaseHtmlModelProtocol{
    var topicId: String?
    var date: String?
    var title: String?
    var reply: String?
    
    required init(rootNode: JiNode) {
        let node = rootNode.xPath("./table/tr/td[1]/span[1]/a[1]")[0]
        self.title = node.content
        
        var topicIdUrl = node["href"];
        
        if var id = topicIdUrl {
            if let range = id.rangeOfString("/t/") {
                id.replaceRange(range, with: "");
            }
            if let range = id.rangeOfString("#") {
                id = id.substringToIndex(range.startIndex)
                topicIdUrl = id
            }
        }
        self.topicId = topicIdUrl
        self.date = rootNode.xPath("./table/tr/td/div/span")[0].content
    }
}