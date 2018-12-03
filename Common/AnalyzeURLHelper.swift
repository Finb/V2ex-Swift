//
//  AnalyzeURLHelper.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2/18/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

class AnalyzeURLHelper {
    /**
     分析URL 进行相应的操作

     - parameter url: 各种URL 例如https://baidu.com 、/member/finab 、/t/100000
     */
    @discardableResult
    class func Analyze(_ url:String) -> Bool {
        let result = AnalyzURLResultType(url: url)
        switch result {
            
        case .url(let url):
            url.run()
            
        case .member(let member):
            member.run()
            
        case .topic(let topic):
            topic.run()
            
        case .node(let node):
            node.run()
            
        case .undefined :
            return false
        }
        
        return true
    }
}

enum AnalyzURLResultType {
    /// 普通URL链接
    case url(UrlActionModel)
    /// 用户
    case member(MemberActionModel)
    /// 帖子链接
    case topic(TopicActionModel)
    case node(NodeActionModel)
    /// 未定义
    case undefined
    
    private enum `Type` : Int {
        case url, member, topic , node, undefined
    }
    
    private static let patterns = [
        "^(http|ftp|https):\\/\\/[\\w\\-_]+(\\.[\\w\\-_]+)+([\\w\\-\\.,@?^=%&amp;:/~\\+#]*[\\w\\-\\@?^=%&amp;/~\\+#])?",
        "^(http:\\/\\/|https:\\/\\/)?(www\\.)?(v2ex.com)?/member/[a-zA-Z0-9_]+$",
        "^(http:\\/\\/|https:\\/\\/)?(www\\.)?(v2ex.com)?/t/[0-9]+",
        "^(http:\\/\\/|https:\\/\\/)?(www\\.)?(v2ex.com)?/go/[a-zA-Z0-9_]+$"
        ]
    
    init(url:String) {
        var resultType:AnalyzURLResultType = .undefined
        
        var type = Type.undefined
        for pattern in AnalyzURLResultType.patterns {
            let regex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            regex.enumerateMatches(in: url, options: .withoutAnchoringBounds, range: NSMakeRange(0, url.Lenght), using: { (result, _, _) -> Void in
                if let result = result {
                    let range = result.range
                    if range.location == NSNotFound || range.length <= 0 {
                        return ;
                    }
                    
                    type = Type(rawValue: AnalyzURLResultType.patterns.index(of: pattern)!)!
                    
                    switch type {
                    case .url:
                        if let action = UrlActionModel(url: url) {
                            resultType = .url(action)
                        }
                        
                    case .member :
                        if let action = MemberActionModel(url: url) {
                            resultType = .member(action)
                        }
                        
                    case .topic:
                        if let action = TopicActionModel(url: url) {
                            resultType = .topic(action)
                        }
                    case .node:
                        if let action = NodeActionModel(url: url) {
                            resultType = .node(action)
                        }
                        
                    default:break
                    }
                }
            })
        }
        
        self = resultType
    }
}

protocol AnalyzeURLActionProtocol {
    init?(url:String)
    func run()
}

struct UrlActionModel: AnalyzeURLActionProtocol{
    var url:String
    init?(url:String) {
        self.url = url;
    }
    func run() {
        let controller = V2WebViewViewController(url: url)
        V2Client.sharedInstance.topNavigationController.pushViewController(controller, animated: true)
    }
}

struct MemberActionModel: AnalyzeURLActionProtocol {
    var username:String
    init?(url:String) {
        if  let range = url.range(of: "/member/") {
            self.username = String(url[range.upperBound...])
        }
        else{
            return nil
        }
    }
    func run() {
        let memberViewController = MemberViewController()
        memberViewController.username = username
        V2Client.sharedInstance.topNavigationController.pushViewController(memberViewController, animated: true)
    }
}

struct TopicActionModel: AnalyzeURLActionProtocol {
    var topicID:String
    init?(url:String) {
        if  let range = url.range(of: "/t/") {
            var topicID = url[range.upperBound...]
            
            if let range = topicID.range(of: "?"){
                topicID = topicID[..<range.lowerBound]
            }
            
            if let range = topicID.range(of: "#"){
                topicID = topicID[..<range.lowerBound]
            }
            self.topicID = String(topicID)
        }
        else{
            return nil;
        }
    }
    func run() {
        let controller = TopicDetailViewController()
        controller.topicId = topicID
        V2Client.sharedInstance.topNavigationController.pushViewController(controller, animated: true)
    }
}

struct NodeActionModel: AnalyzeURLActionProtocol {
    var nodeID:String
    init?(url:String) {
        if  let range = url.range(of: "/go/") {
            var nodeID = url[range.upperBound...]
            
            if let range = nodeID.range(of: "?"){
                nodeID = nodeID[..<range.lowerBound]
            }
            
            if let range = nodeID.range(of: "#"){
                nodeID = nodeID[..<range.lowerBound]
            }
            self.nodeID = String(nodeID)
        }
        else{
            return nil;
        }
    }
    func run() {
        let node = NodeModel()
        node.nodeId = self.nodeID
        node.nodeName = self.nodeID
        
        let controller = NodeTopicListViewController()
        controller.node = node
        V2Client.sharedInstance.topNavigationController.pushViewController(controller, animated: true)
    }
}



extension AnalyzeURLHelper {
    /**
     测试
     */
    class func test() -> Void {
        var urls  = [
            "http://v2ex.com/member/finab",
            "https://v2ex.com/member/finab",
            "http://www.v2ex.com/member/finab",
            "https://www.v2ex.com/member/finab",
            "v2ex.com/member/finab",
            "www.v2ex.com/member/finab",
            "/member/finab",
            "/MEMBER/finab"
        ]
        urls.forEach { (url) in
            let result = AnalyzURLResultType(url: url)
            if case AnalyzURLResultType.member(let member) = result {
                print(member.username)
            }
            else{
                assert(false, "不能解析member : " + url )
            }
            
        }
        
        urls = [
            "member/finab",
            "www.baidu.com/member/finab",
            "com/member/finab",
            "www.baidu.com",
            "http://www.baidu.com"
        ]
        urls.forEach { (url) in
            let result = AnalyzURLResultType(url: url)
            if case AnalyzURLResultType.member(_) = result {
                assert(true, "解析了不是member的URL : " + url )
            }
        }
    }
}
