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

class TopicListModel {
    var avata: String?
    var nodeName: String?
    var userName: String?
    var topicTitle: String?
    var date: String?
    var lastReplyUserName: String?
    var replies: String?
    
    class func getTopicList(completionHandler: V2Response<[TopicListModel]> -> Void)->Void{
        
        Alamofire.request(.GET, "https://www.v2ex.com/?tab=hot", parameters: ["tag":"hot"], encoding: .URL, headers: ["user-agent":USER_AGENT]).responseString { (response: Response<String,NSError>) -> Void in
            var resultArray:[TopicListModel] = []

            if let html = response .result.value{
                let jiHtml = Ji(htmlString: html);
                if let aRootNode = jiHtml?.xPath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box'][1]/div[@class='cell item']"){
                    for aNode in aRootNode {
                        let avata = aNode.xPath("./table/tr/td[1]/a[1]/img[@class='avatar']")[0]["src"]
                        let nodeName = aNode.xPath("./table/tr/td[3]/span[1]/a[1]")[0].content
                        let userName = aNode.xPath("./table/tr/td[3]/span[1]/strong[1]/a[1]")[0].content
                        let topicTitle = aNode.xPath("./table/tr/td[3]/span[2]/a[1]")[0].content
                        let date = aNode.xPath("./table/tr/td[3]/span[3]")[0].content
                        let lastReplyUserName = aNode.xPath("./table/tr/td[3]/span[3]/strong[1]/a[1]")[0].content
                        let replies = aNode.xPath("./table/tr/td[4]/a[1]")[0].content
                        
                        let topic = TopicListModel()
                        topic.avata  = avata
                        topic.nodeName  = nodeName
                        topic.userName  = userName
                        topic.topicTitle  = topicTitle
                        topic.date  = date
                        topic.lastReplyUserName  = lastReplyUserName
                        topic.replies  = replies
                        
                        resultArray.append(topic);
                    }
                }
            }
            
            let t = V2Response<Array<TopicListModel>>(value:resultArray, success: response.result.isSuccess)
            completionHandler(t);
            
        }
    }
    
}
