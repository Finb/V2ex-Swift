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
        let result = AnalyzURLResult(url: url)
        dispatch_sync_safely_main_queue { () -> () in
            switch result.type {
            case .url:
                if let url = result.params["value"] {
                    let controller = V2WebViewViewController(url: url)
                    V2Client.sharedInstance.topNavigationController.pushViewController(controller, animated: true)
                }
            case .member:
                if let username = result.params["value"] {
                    let memberViewController = MemberViewController()
                    memberViewController.username = username
                    V2Client.sharedInstance.topNavigationController.pushViewController(memberViewController, animated: true)
                }
            case .topic:
                if let topicID = result.params["value"] {
                    let controller = TopicDetailViewController()
                    controller.topicId = topicID
                    V2Client.sharedInstance.topNavigationController.pushViewController(controller, animated: true)
                }
            case .undefined:break
            }
        }
        if result.type == .undefined {
            return false
        }
        else{
            return true
        }
    }
    
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
            let result = AnalyzURLResult(url: url)
            assert(result.type == .member, "不能解析member : " + url )
        }
        
        urls = [
            "member/finab",
            "www.baidu.com/member/finab",
            "com/member/finab",
            "www.baidu.com",
            "http://www.baidu.com"
        ]
        urls.forEach { (url) in
            let result = AnalyzURLResult(url: url)
            assert(result.type != .member, "解析了不是member的URL : " + url )
        }
    }
}


enum AnalyzURLResultType : Int {
    /// 普通URL链接
    case url = 0
    /// 用户
    case member
    /// 帖子链接
    case topic
    /// 未定义
    case undefined
}
class AnalyzURLResult :NSObject {
    var type:AnalyzURLResultType = .undefined
    var params:[String:String] = [:]

    fileprivate static let patterns = [
        "^(http|ftp|https):\\/\\/[\\w\\-_]+(\\.[\\w\\-_]+)+([\\w\\-\\.,@?^=%&amp;:/~\\+#]*[\\w\\-\\@?^=%&amp;/~\\+#])?",
        "^(http:\\/\\/|https:\\/\\/)?(www\\.)?(v2ex.com)?/member/[a-zA-Z0-9_]+$",
        "^(http:\\/\\/|https:\\/\\/)?(www\\.)?(v2ex.com)?/t/[0-9]+",
    ]
    init(url:String) {
        super.init()
        self.type = .undefined
        for pattern in AnalyzURLResult.patterns {
            let regex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            regex.enumerateMatches(in: url, options: .withoutAnchoringBounds, range: NSMakeRange(0, url.Lenght), using: { (result, _, _) -> Void in
                if let result = result {
                    let range = result.range
                    if range.location == NSNotFound || range.length <= 0 {
                        return ;
                    }

                    self.type = AnalyzURLResultType(rawValue: AnalyzURLResult.patterns.index(of: pattern)!)!
                    
                    switch self.type {
                    case .url:
                        self.params["value"] = url

                    case .member :
                        if  let range = url.range(of: "/member/") {
                            let username = url.substring(from: range.upperBound)
                            self.params["value"] = username
                        }

                    case .topic:
                        if  let range = url.range(of: "/t/") {
                            var topicID = url.substring(from: range.upperBound)
                            
                            if let range = topicID.range(of: "?"){
                                topicID = topicID.substring(to: range.lowerBound)
                            }
                            
                            if let range = topicID.range(of: "#"){
                               topicID = topicID.substring(to: range.lowerBound)
                            }
                            self.params["value"] = topicID
                        }

                    default:break
                    }
                }
            })
        }
    }
}
