//
//  V2Response.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/23/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

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
    var value:T
    
    init(value:T,success:Bool) {
        self.value = value
        super.init(success: success, message: nil)
    }
    convenience init(value:T,success:Bool,message:String?) {
        self.init(value:value,success:success)
        if let message = message {
            self.message = message
        }
    }
}