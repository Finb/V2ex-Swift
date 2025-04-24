//
//  TopicListModel.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/13/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

import ObjectMapper
import Alamofire

import Ji
import YYText
import KVOController

class TopicListModel:NSObject, HtmlModelArrayProtocol {

    class func createModelArray(ji: Ji) -> [Any] {
        var resultArray:[TopicListModel] = []
        if let aRootNode = ji.xPath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box']//div[@class='cell item']"){
            for aNode in aRootNode {
                let topic = TopicListModel(rootNode:aNode)
                resultArray.append(topic);
            }
            
            //更新通知数量
            V2User.sharedInstance.getNotificationsCount(ji.rootNode!)
            
            DispatchQueue.global().async {
                //领取每日奖励
                if let aRootNode = ji.xPath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box']/div[@class='inner']/a[@href='/mission/daily']")?.first {
                    if aRootNode.content == "领取今日的登录奖励" {
                        print("有登录奖励可领取")
                        UserModel.dailyRedeem()
                    }
                }
            }
        }
        return resultArray
    }
    
    var topicId: String?
    var avata: String?
    var nodeName: String?
    var userName: String?
    var topicTitle: String?
    var topicTitleLayout: YYTextLayout?

    var date: String?
    var lastReplyUserName: String?
    var replies: String?

    var hits: String?

    override init() {
        super.init()
    }
    init(rootNode: JiNode) {
        super.init()

        self.avata = rootNode.xPath("./table/tr/td[1]/a[1]/img[@class='avatar']").first?["src"]
        self.nodeName = rootNode.xPath("./table/tr/td[3]/span[1]/a[1]").first?.content
        self.userName = rootNode.xPath("./table/tr/td[3]/span[1]/strong[1]/a[1]").first?.content

        let node = rootNode.xPath("./table/tr/td[3]/span[2]/a[1]").first
        self.topicTitle = node?.content

        var topicIdUrl = node?["href"];

        if var id = topicIdUrl {
            if let range = id.range(of: "/t/") {
                id.replaceSubrange(range, with: "");
            }
            if let range = id.range(of: "#") {
                topicIdUrl = String(id[..<range.lowerBound])
            }
        }
        self.topicId = topicIdUrl


        self.date = rootNode.xPath("./table/tr/td[3]/span[3]").first?.content

        var lastReplyUserName:String? = nil
        if let lastReplyUser = rootNode.xPath("./table/tr/td[3]/span[3]/strong[1]/a[1]").first{
            lastReplyUserName = lastReplyUser.content
        }
        self.lastReplyUserName = lastReplyUserName

        var replies:String? = nil;
        if let reply = rootNode.xPath("./table/tr/td[4]/a[1]").first {
            replies = reply.content
        }
        self.replies  = replies

    }
}

class FavoriteListModel: TopicListModel {
    override class func createModelArray(ji: Ji) -> [Any] {
        var resultArray:[FavoriteListModel] = []
        if let aRootNode = ji.xPath("//*[@class='cell item']"){
            for aNode in aRootNode {
                let topic = FavoriteListModel(favoritesRootNode:aNode)
                resultArray.append(topic);
            }
        }
        return resultArray
    }
    
    init(favoritesRootNode:JiNode) {
        super.init()
        self.avata = favoritesRootNode.xPath("./table/tr/td[1]/a[1]/img[@class='avatar']").first?["src"]
        self.nodeName = favoritesRootNode.xPath("./table/tr/td[3]/span[2]/a[1]").first?.content
        self.userName = favoritesRootNode.xPath("./table/tr/td[3]/span[2]/strong[1]/a").first?.content
        
        let node = favoritesRootNode.xPath("./table/tr/td[3]/span/a[1]").first
        self.topicTitle = node?.content

        var topicIdUrl = node?["href"];
        
        if var id = topicIdUrl {
            if let range = id.range(of: "/t/") {
                id.replaceSubrange(range, with: "");
            }
            if let range = id.range(of: "#") {
                topicIdUrl = String(id[..<range.lowerBound])
            }
        }
        self.topicId = topicIdUrl
        
        
        let date = favoritesRootNode.xPath("./table/tr/td[3]/span[2]").first?.content
        if let date = date {
            let array = date.components(separatedBy: "•")
            if array.count == 4 {
                self.date = array[3].trimmingCharacters(in: NSCharacterSet.whitespaces)
                
            }
        }
        
        self.lastReplyUserName = favoritesRootNode.xPath("./table/tr/td[3]/span[2]/strong[2]/a[1]").first?.content
        
        self.replies = favoritesRootNode.xPath("./table/tr/td[4]/a[1]").first?.content
    }
}

class NodeTopicListModel: TopicListModel {
    
    override class func createModelArray(ji: Ji) -> [Any] {
        var resultArray:[NodeTopicListModel] = []
        if let aRootNode = ji.xPath("//*[@id='Wrapper']/div[@class='content']/div[@class='box']/div[@class='cell']"){
            for aNode in aRootNode {
                let topic = NodeTopicListModel(nodeRootNode: aNode)
                resultArray.append(topic);
            }
            
            //更新通知数量
            V2User.sharedInstance.getNotificationsCount(ji.rootNode!)
        }
        return resultArray
    }
    
    init(nodeRootNode:JiNode) {
        super.init()
        self.avata = nodeRootNode.xPath("./table/tr/td[1]/a[1]/img[@class='avatar']").first?["src"]
        self.userName = nodeRootNode.xPath("./table/tr/td[3]/span[2]/strong").first?.content
        
        let node = nodeRootNode.xPath("./table/tr/td[3]/span/a[1]").first
        self.topicTitle = node?.content
        
        var topicIdUrl = node?["href"];
        
        if var id = topicIdUrl {
            if let range = id.range(of: "/t/") {
                id.replaceSubrange(range, with: "");
            }
            if let range = id.range(of: "#") {
                topicIdUrl = String(id[..<range.lowerBound])
            }
        }
        self.topicId = topicIdUrl
        
        
        self.hits = nodeRootNode.xPath("./table/tr/td[3]/span[last()]/text()").first?.content
        if let hits = self.hits {
            self.hits = String(hits[hits.index(hits.startIndex, offsetBy: 5)...])
        }
        var replies:String? = nil;
        if let reply = nodeRootNode.xPath("./table/tr/td[4]/a[1]").first {
            replies = reply.content
        }
        self.replies  = replies
    }
}


//MARK: - Request
extension TopicListModel {
    /**
     收藏节点
     
     - parameter nodeId: 节点ID
     - parameter type:   操作 0 : 收藏 1：取消收藏
     */
    class func favorite(
        _ nodeId:String,
        type:NSInteger
    ){
        V2User.sharedInstance.getOnce { (response) in
            if(response.success){
                let action = type == 0 ? "favorite/node/" : "unfavorite/node/"
                let url = V2EXURL + action + nodeId + "?once=" + V2User.sharedInstance.once!
                Alamofire.request(url , headers: MOBILE_CLIENT_HEADERS).responseJiHtml { (response) in
                    
                }
            }
        }
    }

}


