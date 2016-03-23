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
    var width:CGFloat = 0
    required init(rootNode: JiNode) {
        self.nodeName = rootNode.content
        if let nodeName = self.nodeName {
            //计算字符串所占的宽度
            //用于之后这个 node 在 cell 中所占的宽度
            let rect = (nodeName as NSString).boundingRectWithSize(
                CGSizeMake(SCREEN_WIDTH, NodeTableViewCell.fontSize),
                options: .UsesLineFragmentOrigin,
                attributes: [NSFontAttributeName:v2Font(NodeTableViewCell.fontSize)], context: nil)
            
            self.width = rect.width;
        }
        
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
    var childrenRows:[[Int]] = [[]]
    var children:[NodeModel] = []
    required init(rootNode: JiNode) {
        self.groupName = rootNode.xPath("./td[1]/span").first?.content
        for node in rootNode.xPath("./td[2]/a") {
            self.children.append(NodeModel(rootNode: node))
        }
        self.childrenRows = NodeGroupModel.getShowRows(self.children)
    }
    
    /**
     获取节点数据布局
     
     - returns: 得到一个节点 占多少行 每行有哪些节点的二维数组
     */
    class func getShowRows(nodes:[NodeModel]) -> [[Int]] {
        
        var row = 1
        
        var rows:[[Int]] = []
        
        var tempWidth:CGFloat = 0
        for var i in 0 ..< nodes.count {
            
            if rows.count < row {
                rows .append([])
            }
            
            let node = nodes[i]
            if tempWidth == 0 {
                tempWidth += NodeTableViewCell.leftAndRightSpacing
            }
            
            if tempWidth + node.width + NodeTableViewCell.nodeSpacing > SCREEN_WIDTH - NodeTableViewCell.leftAndRightSpacing
                && tempWidth > NodeTableViewCell.leftAndRightSpacing {
                    tempWidth = 0
                    i -= 1
                    row += 1
                    continue
            }
            
            rows[row-1].append(i)
            if i == 0 {
                tempWidth += node.width
            }
            else {
                tempWidth += node.width + NodeTableViewCell.nodeSpacing
            }
        }
        
        return rows
    }
    
    
    class func getNodes( completionHandler: (V2ValueResponse<[NodeGroupModel]> -> Void)? = nil ) {
        Alamofire.request(.GET, V2EXURL, parameters: nil, encoding: .URL, headers: MOBILE_CLIENT_HEADERS).responseJiHtml { (response) in
            var groupArray : [NodeGroupModel] = []
            if let jiHtml = response .result.value{
                if let nodes = jiHtml.xPath("//*[@id='Wrapper']/div/div[@class='box'][last()]/div/table/tr") {
                    for rootNode in nodes {
                        let group = NodeGroupModel(rootNode: rootNode)
                        groupArray.append(group)
                    }
                }
                completionHandler?(V2ValueResponse(value: groupArray, success: true))
                return;
            }
            completionHandler?(V2ValueResponse(success: false, message: "获取失败"))
        }
    }
    
}
