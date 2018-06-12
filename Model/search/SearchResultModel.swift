//
//  SearchResultModel.swift
//  V2ex-Swift
//
//  Created by H on 6/12/18.
//  Copyright © 2018 Fin. All rights reserved.
//

import UIKit
import ObjectMapper

class SearchResultModel: BaseJsonModel {
    
    var total: Int?
    var hits: Array<Hits>?
    
    override func mapping(map: Map) {
        self.total <- map["total"]
        self.hits <- map["hits"]
    }

}

extension SearchResultModel {
    
}
