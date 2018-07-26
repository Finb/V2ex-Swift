//
//  UserApi.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2018/6/11.
//  Copyright © 2018 Fin. All rights reserved.
//

import UIKit

enum UserApi {
    case getUserInfo(username:String)
}

extension UserApi: V2EXTargetType {
    var path: String {
        switch self {
        case .getUserInfo:
            return "/api/members/show.json"
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case let .getUserInfo(username):
            return ["username": username]
        }
    }
}
