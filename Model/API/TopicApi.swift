//
//  TopicApi.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2019/9/2.
//  Copyright © 2019 Fin. All rights reserved.
//

import UIKit
import Moya

enum TopicApi {
    //感谢回复
    case thankReply(replyId:String, once:String)
    case thankTopic(topicId:String, once:String)
}

extension TopicApi: V2EXTargetType {
    var method: Moya.Method {
        switch self {
        case .thankReply: return .post
        case .thankTopic: return .post
        }
    }
    var parameters: [String : Any]?{
        switch self {
        case let .thankReply( _ , once):
            return ["once": once]
        case let .thankTopic( _ , once):
            return ["once": once]
        }
    }
    var path: String {
        switch self {
        case let .thankReply(replyId, _):
            return "/thank/reply/\(replyId)"
        case let .thankTopic(replyId, _):
            return "/thank/topic/\(replyId)"
        }
    }
}
