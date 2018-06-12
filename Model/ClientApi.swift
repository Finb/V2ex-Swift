//
//  ClientApi.swift
//  V2ex-Swift
//
//  Created by H on 6/12/18.
//  Copyright © 2018 Fin. All rights reserved.
//

import UIKit

enum ClientApi {
    case search(keyword: String, from: Int, size: Int)
}

extension ClientApi: V2EXTargetType {
    
    var baseURL: URL {
        return URL(string: "https://www.sov2ex.com")!
    }
    
    var path: String {
        switch self {
        case .search:
            return "/api/search"
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case let .search(keyword, from, size):
            return ["q": keyword, "from": from, "size": size]
        }
    }

}
