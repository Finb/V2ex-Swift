//
//  BaseModel.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/13/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

import ObjectMapper
import Ji

let USER_AGENT = "Mozilla/5.0 (iPhone; CPU iPhone OS 8_0 like Mac OS X) AppleWebKit/600.1.3 (KHTML, like Gecko) Version/8.0 Mobile/12A4345d Safari/600.1.4";

let MOBILE_CLIENT_HEADERS = ["user-agent":USER_AGENT]

let LIGHT_CSS = try! String(contentsOfFile: LightBundel.pathForResource("style", ofType: "css")!, encoding: NSUTF8StringEncoding)
let Dark_CSS = try! String(contentsOfFile: DarkBundel.pathForResource("style", ofType: "css")!, encoding: NSUTF8StringEncoding)

class BaseJsonModel: Mappable {
    required init?(_ map: Map) {
        
    }
    func mapping(map: Map) {
        
    }
}


protocol BaseHtmlModelProtocol {
    init(rootNode:JiNode)
}


struct V2Response<T> {
    let value:T
    let success:Bool
}