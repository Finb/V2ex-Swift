//
//  V2APIProvider.swift
//  V2ex-Swift
//
//  Created by skyline on 16/3/31.
//  Copyright © 2016年 Fin. All rights reserved.
//

import UIKit

import Ji
import Alamofire

public typealias Completion = (result: Result<Ji, NSError>) -> ()

protocol APIProviderType {
    func request(target:APITargetType, completion:Completion);
}

protocol APITargetType {
    var baseURL: NSURL { get }
    var path: String { get }
    var method: Alamofire.Method { get }
    var parameters: [String: AnyObject]? { get }
}

enum V2API {
    case TopicList(tab:String?, page:Int)
    case NodeTopicList(nodename:String, page:Int)
    case FavoriteList(page:Int)
}

extension V2API: APITargetType {
    var baseURL:NSURL { return NSURL(string:V2EXURL)! }
    var path:String {
        switch self {
        case .TopicList(let tab, _):
            if tab == "all" {
                return "recent"
            }
            return ""
        case .NodeTopicList(let nodename, _):
            return "go/" + nodename
        case .FavoriteList(_):
            return "my/topics"
        }
    }

    var method:Alamofire.Method {
        switch self {
        case .TopicList(_, _), .NodeTopicList(_, _), .FavoriteList(_):
            return Alamofire.Method.GET
        }
    }

    var parameters: [String: AnyObject]? {
        switch self {
        case .TopicList(let tab, let page):
            var params:[String:String] = [:]
            if let tab = tab {
                params["tab"] = tab
            }
            else {
                params["tab"] = "all"
            }
            if page > 0 {
                params["p"] = "\(page)"
            }
            return params
        case .NodeTopicList(_, let page):
            return ["p" : page]
        case .FavoriteList(let page):
            return ["p" : page]
        }
    }
}

class APIProvider<Target: APITargetType> {
    func request(target: Target, completion: Completion) {
        let url = target.baseURL.URLByAppendingPathComponent(target.path).absoluteString
        Alamofire.request(target.method, url, parameters: target.parameters, encoding: .URL, headers: MOBILE_CLIENT_HEADERS).responseJiHtml { response in
            completion(result: response.result)
        }
    }
}

let V2APIProvider = APIProvider<V2API>()
