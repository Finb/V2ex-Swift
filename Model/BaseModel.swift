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

class BaseJsonModel: Mappable {
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        
    }
}


protocol BaseHtmlModelProtocol {
    init(rootNode:JiNode)
}

/// 实现这个协议的类，可用于Moya自动解析出这个类的model的对象数组
protocol HtmlModelArrayProtocol {
    static func createModelArray(ji:Ji) -> [Self]
}

/// 实现这个协议的类，可用于Moya自动解析出这个类的model的对象
protocol HtmlModelProtocol {
    static func createModel(ji:Ji) -> Self
}
