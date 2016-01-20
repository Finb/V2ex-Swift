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
    var topicId: String?
    var avata: String?
    var nodeName: String?
    var userName: String?
    var topicTitle: String?
    var date: String?
    var lastReplyUserName: String?
    var replies: String?
    
    class func getTopicList(
        tab: String? = nil ,
        nodeName: String? = nil,
        completionHandler: V2Response<[TopicListModel]> -> Void
        )->Void{
            
            var params:[String:String] = [:]
            if let tab = tab {
                params["tab"]=tab
            }
            else {
                params["tab"] = "hot"
            }
            
            Alamofire.request(.GET, "https://www.v2ex.com", parameters: params, encoding: .URL, headers: CLIENT_HEADERS).responseString { (response: Response<String,NSError>) -> Void in
                var resultArray:[TopicListModel] = []
                
                if let html = response .result.value{
                    let jiHtml = Ji(htmlString: html);
                    if let aRootNode = jiHtml?.xPath("//body/div[@id='Wrapper']/div[@class='content']/div[@class='box'][1]/div[@class='cell item']"){
                        for aNode in aRootNode {
                            let avata = aNode.xPath("./table/tr/td[1]/a[1]/img[@class='avatar']")[0]["src"]
                            let nodeName = aNode.xPath("./table/tr/td[3]/span[1]/a[1]")[0].content
                            let userName = aNode.xPath("./table/tr/td[3]/span[1]/strong[1]/a[1]")[0].content

                            let node = aNode.xPath("./table/tr/td[3]/span[2]/a[1]")[0]
                            let topicTitle = node.content
                            
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
                            
                            
                            let date = aNode.xPath("./table/tr/td[3]/span[3]")[0].content
                            
                            var lastReplyUserName:String? = nil
                            if let lastReplyUser = aNode.xPath("./table/tr/td[3]/span[3]/strong[1]/a[1]").first{
                                lastReplyUserName = lastReplyUser.content
                            }
                            var replies:String? = nil;
                            if let reply = aNode.xPath("./table/tr/td[4]/a[1]").first {
                                replies = reply.content
                            }
                            
                            let topic = TopicListModel()
                            topic.topicId = topicIdUrl
                            topic.avata  = avata
                            topic.nodeName  = nodeName
                            topic.userName  = userName
                            topic.topicTitle  = topicTitle
                            topic.date  = date
                            if lastReplyUserName != nil {
                                topic.lastReplyUserName  = lastReplyUserName!
                            }
                            if replies != nil {
                                topic.replies  = replies!
                            }
                            resultArray.append(topic);
                        }
                    }
                }
                
                let t = V2Response<[TopicListModel]>(value:resultArray, success: response.result.isSuccess)
                completionHandler(t);
                
            }
    }
    
}
