//
//  NotificationsModel.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/29/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

import Alamofire
import Ji

class NotificationsModel: NSObject,BaseHtmlModelProtocol {
    var avata: String?
    var userName: String?
    var title: String?
    var date: String?
    var reply: String?

    var topicId: String?
    
    required init(rootNode: JiNode) {
        self.avata = rootNode.xPath("./table/tr/td[1]/a/img[@class='avatar']").first?["src"]
        self.userName = rootNode.xPath("./table/tr/td[2]/span[1]/a[1]/strong").first?.content
        self.title = rootNode.xPath("./table/tr/td[2]/span[1]").first?.content
        self.date = rootNode.xPath("./table/tr/td[2]/span[2]").first?.content
        self.reply = rootNode.xPath("./table/tr/td[2]/div[@class='payload']").first?.content
        
        if let node = rootNode.xPath("./table/tr/td[2]/span[1]/a[2]").first {
            var topicIdUrl = node["href"];
            
            if var id = topicIdUrl {
                if let range = id.range(of: "/t/") {
                    id.replaceSubrange(range, with: "");
                }
                if let range = id.range(of: "#") {
                    topicIdUrl = String(id[..<range.lowerBound])
                }
            }
            self.topicId = topicIdUrl
        }
        
    }
}


//MARK: - Request
extension NotificationsModel {
    class func getNotifications(_ completionHandler: ((V2ValueResponse<[NotificationsModel]>) -> Void)? = nil){
        
        Alamofire.request(V2EXURL+"notifications", headers: MOBILE_CLIENT_HEADERS).responseJiHtml { (response) in
            var resultArray:[NotificationsModel] = []
            
            if let jiHtml = response.result.value {
                if let aRootNode = jiHtml.xPath("//*[@id='Wrapper']/div/div[@class='box']/div[attribute::id]"){
                    for aNode in aRootNode {
                        let notice = NotificationsModel(rootNode:aNode)
                        resultArray.append(notice);
                    }
                    
                    //更新通知数量
                    V2User.sharedInstance.getNotificationsCount(jiHtml.rootNode!)
                }
            }
            
            let t = V2ValueResponse<[NotificationsModel]>(value:resultArray, success: response.result.isSuccess)
            completionHandler?(t);
            
        }
        
    }

}
