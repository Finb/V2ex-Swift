//
//  TopicListModel.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/13/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

import ObjectMapper
import Alamofire

class TopicListModel: BaseModel {
    var id: String?
    var title: String?
    var url: String?
    var content: String?
    var content_rendered: String?
    var replies: String?
    var member: TopicList_MemberModel?
    var node: TopicList_NodeModel?
    var created: String?
    var last_modified: String?
    var last_touched: String?
    
    override func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        url <- map["url"]
        content <- map["content"]
        content_rendered <- map["content_rendered"]
        replies <- map["replies"]
        member <- map["member"]
        node <- map["node"]
        created <- map["created"]
        last_modified <- map["last_modified"]
        last_touched <- map["last_touched"]
    }
    
    class func getTopicList(completionHandler: Response<[TopicListModel], NSError> -> Void)->Void{
        Alamofire.request(.GET, "https://www.v2ex.com/api/topics/show.json?node_id=10").responseArray(completionHandler);
    }
    
}


class TopicList_MemberModel:BaseModel {
    var id: Int?
    var username: String?
    var tagline: String?
    var avatar_mini: String?
    var avatar_normal: String?
    var avatar_large: String?
    override func mapping(map: Map) {
        id <- map["id"]
        username <- map["username"]
        tagline <- map["tagline"]
        avatar_mini <- map["avatar_mini"]
        avatar_normal <- map["avatar_normal"]
        avatar_large <- map["avatar_large"]
    }
}

class TopicList_NodeModel:BaseModel {
    var id: Int?
    var name: String?
    var title: String?
    var title_alternative: String?
    var url: String?
    var topics: Int?
    var avatar_mini: String?
    var avatar_normal: String?
    var avatar_large: String?
    override func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        title <- map["title"]
        title_alternative <- map["title_alternative"]
        url <- map["url"]
        topics <- map["topics"]
        avatar_mini <- map["avatar_mini"]
        avatar_normal <- map["avatar_normal"]
        avatar_large <- map["avatar_large"]
    }
}