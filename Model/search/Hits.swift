//
//  Hits.swift
//  V2ex-Swift
//
//  Created by H on 6/12/18.
//  Copyright © 2018 Fin. All rights reserved.
//

import UIKit
import ObjectMapper

class Hits: BaseJsonModel {

    var _source : Source?
    
    override func mapping(map: Map) {
        self._source <- map["_source"]
    }
    
}
