//
//  V2Response.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/23/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

enum ErrorCode:Int {
    case none = 0
    case twoFA ;
}

class V2Response: NSObject {
    var success:Bool = false
    var message:String = "No message"
    init(success:Bool,message:String?) {
        super.init()
        self.success = success
        if let message = message{
            self.message = message
        }
    }
    init(success:Bool) {
        super.init()
        self.success = success
    }
}

class V2ValueResponse<T>: V2Response {
    var value:T?
    var code:ErrorCode = .none
    
    override init(success: Bool) {
        super.init(success: success)
    }
    
    override init(success:Bool,message:String?) {
        super.init(success:success)
        if let message = message {
            self.message = message
        }
    }
    convenience init(value:T,success:Bool) {
        self.init(success: success)
        self.value = value
    }
    convenience init(value:T,success:Bool,message:String? = nil, code:ErrorCode = .none) {
        self.init(value:value,success:success)
        if let message = message {
            self.message = message
        }
        self.code = code
    }
}
