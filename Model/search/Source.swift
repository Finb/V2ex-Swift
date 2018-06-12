//
//  Source.swift
//  V2ex-Swift
//
//  Created by H on 6/12/18.
//  Copyright © 2018 Fin. All rights reserved.
//

import UIKit
import ObjectMapper

class Source: BaseJsonModel {

    var replies : Int?
    var created : String?
    var member : String?
    var id : Int?
    var title : String?
    var content : String?
    
    override func mapping(map: Map) {
        self.replies <- map["replies"]
        self.created <- map["created"]
        self.member <- map["member"]
        self.id <- map["id"]
        self.title <- map["title"]
        self.content <- map["content"]
    }
}
