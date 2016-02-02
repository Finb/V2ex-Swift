//
//  NodeModel.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2/2/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import Alamofire
import Ji

class NodeModel: NSObject ,BaseHtmlModelProtocol{
    var nodeId:String?
    var nodeName:String?
    required init(rootNode: JiNode) {
        self.nodeName = rootNode.content
        
        if var href = rootNode["href"] {
            if let range = href.rangeOfString("/go/") {
                href.replaceRange(range, with: "");
                self.nodeId = href
            }
        }
    }
}
class NodeGroupModel: NSObject ,BaseHtmlModelProtocol{
    var groupName:String?
    var children:[NodeModel] = []
    required init(rootNode: JiNode) {
        self.groupName = rootNode.xPath("./td[1]/span").first?.content
        for node in rootNode.xPath("./td[2]/a") {
            self.children.append(NodeModel(rootNode: node))
        }
    }
    
    
    class func getNodes( completionHandler: (V2ValueResponse<[NodeGroupModel]> -> Void)? = nil ) {
        Alamofire.request(.GET, V2EXURL, parameters: nil, encoding: .URL, headers: MOBILE_CLIENT_HEADERS).responseJiHtml { (response) in
            var groupArray : [NodeGroupModel] = []
            if let jiHtml = response .result.value{
                if let nodes = jiHtml.xPath("//*[@id='Wrapper']/div/div[3]/div/table/tr") {
                    for rootNode in nodes {
                        let group = NodeGroupModel(rootNode: rootNode)
                        groupArray.append(group)
                    }
                }
                completionHandler?(V2ValueResponse(value: groupArray, success: true))
            }
            completionHandler?(V2ValueResponse(success: false, message: "获取失败"))
        }
    }
    
}
