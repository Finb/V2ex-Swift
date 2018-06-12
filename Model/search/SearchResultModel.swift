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
    
    var totals: Int?
//    var hits: Array<Hits>?
    
    override func mapping(map: Map) {
        self.totals <- map["totals"]
//        self.hits <- map["hits"]
    }

}

extension SearchResultModel {
    
    class func search(_ keyword: String, from: Int, size: Int, completionHandler:((V2ValueResponse<SearchResultModel>) -> Void)? ){
        _ = ClientApi.provider.requestAPI(.search(keyword: keyword, from: from, size: size))
            .mapResponseToObj(SearchResultModel.self)
            .subscribe(onNext: { (searchResultModel) in
                print(searchResultModel.totals)
                completionHandler?(V2ValueResponse(value: searchResultModel, success: true))
                return ;
            }, onError: { (error) in
                completionHandler?(V2ValueResponse(success: false,message: "搜索话题失败"))
            });
    }
    
}
