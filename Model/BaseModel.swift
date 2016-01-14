//
//  BaseModel.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/13/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

import ObjectMapper

let USER_AGENT = "Mozilla/5.0 (iPhone; CPU iPhone OS 8_0 like Mac OS X) AppleWebKit/600.1.3 (KHTML, like Gecko) Version/8.0 Mobile/12A4345d Safari/600.1.4";

class BaseModel: Mappable {
    required init?(_ map: Map) {
        
    }
    func mapping(map: Map) {
        
    }
}


struct V2Response<T> {
    let value:T
    let success:Bool
}