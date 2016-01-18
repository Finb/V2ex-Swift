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

class TopicDetailModel: NSObject {
    var avata: String?
    var nodeName: String?
    var nodeUrl: String?
    
    var userName: String?
    
    var topicTitle: String?
    var topicContent: String?
    var date: String?
    var favorites: String?
    
    
    class func getTopicDetailById(
        topicId: String,
        completionHandler: V2Response<TopicDetailModel?> -> Void
        )->Void{
            
            let url = "https" + "://www.v2ex.com/t/" + topicId
            
            Alamofire.request(.GET, url, parameters: nil, encoding: .URL, headers: CLIENT_HEADERS).responseString { (response: Response<String,NSError>) -> Void in
                var model: TopicDetailModel? = nil
                if let html = response .result.value{
                    let jiHtml = Ji(htmlString: html);
                    if let aRootNode = jiHtml?.xPath("//*[@id='Wrapper']/div/div[1]")?.first{
                        
                        model = TopicDetailModel();
                        
                        let node = aRootNode.xPath("./div[1]/a[2]").first
                        model!.nodeName = node?.content
                        model!.nodeUrl = node?["href"]
                        
                        model!.avata = aRootNode.xPath("./div[1]/div[1]/a/img").first?["src"]
                        
                        model!.userName = aRootNode.xPath("./div[1]/small/a").first?.content
                     
                        model!.topicTitle = aRootNode.xPath("./div[1]/h1").first?.content
                        
                        model!.topicContent = aRootNode.xPath("./div[2]/div").first?.rawContent
                        
                        model!.date = aRootNode.xPath("./div[1]/small/text()[2]").first?.content
                        
                        model!.favorites = aRootNode.xPath("./div[3]/div/span").first?.content
                        
                        
                    }
                }
                let t = V2Response<TopicDetailModel?>(value:model, success: response.result.isSuccess)
                completionHandler(t);
            }
            
    }
    
}
