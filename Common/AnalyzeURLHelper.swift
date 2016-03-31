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
    class func Analyze(url:String) -> Bool {
        let result = AnalyzURLResult(url: url)
        dispatch_sync_safely_main_queue { () -> () in
            switch result.type {
            case .URL:
                if let url = result.params["value"] {
                    let controller = V2WebViewViewController(url: url)
                    V2Client.sharedInstance.topNavigationController.pushViewController(controller, animated: true)
                }
            case .Member:
                if let username = result.params["value"] {
                    let memberViewController = MemberViewController()
                    memberViewController.username = username
                    V2Client.sharedInstance.topNavigationController.pushViewController(memberViewController, animated: true)
                }
            case .Topic:
                if let topicID = result.params["value"] {
                    let controller = TopicDetailViewController()
                    controller.topicId = topicID
                    V2Client.sharedInstance.topNavigationController.pushViewController(controller, animated: true)
                }
            case .Undefined:break
            }
        }
        if result.type == .Undefined {
            return false
        }
        else{
            return true
        }
    }
}


enum AnalyzURLResultType : Int {
    /// 普通URL链接
    case URL = 0
    /// 用户
    case Member
    /// 帖子链接
    case Topic
    /// 未定义
    case Undefined
}
class AnalyzURLResult :NSObject {
    var type:AnalyzURLResultType = .Undefined
    var params:[String:String] = [:]

    private static let patterns = [
        "^(http|ftp|https):\\/\\/[\\w\\-_]+(\\.[\\w\\-_]+)+([\\w\\-\\.,@?^=%&amp;:/~\\+#]*[\\w\\-\\@?^=%&amp;/~\\+#])?",
        "(v2ex.com)?/member/[a-zA-Z0-9_]+$",
        "(v2ex.com)?/t/[0-9]+",
    ]
    init(url:String) {
        super.init()
        self.type = .Undefined
        for pattern in AnalyzURLResult.patterns {
            let regex = try! NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
            regex.enumerateMatchesInString(url, options: .WithoutAnchoringBounds, range: NSMakeRange(0, url.Lenght), usingBlock: { (result, _, _) -> Void in
                if let result = result {
                    let range = result.range
                    if range.location == NSNotFound || range.length <= 0 {
                        return ;
                    }

                    self.type = AnalyzURLResultType(rawValue: AnalyzURLResult.patterns.indexOf(pattern)!)!
                    
                    switch self.type {
                    case .URL:
                        self.params["value"] = url

                    case .Member :
                        if  let range = url.rangeOfString("/member/") {
                            let username = url.substringFromIndex(range.endIndex)
                            self.params["value"] = username
                        }

                    case .Topic:
                        if  let range = url.rangeOfString("/t/") {
                            var topicID = url.substringFromIndex(range.endIndex)

                            if let range = topicID.rangeOfString("#"){
                               topicID = topicID.substringToIndex(range.startIndex)
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
