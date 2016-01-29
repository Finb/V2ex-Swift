//
//  V2EXSettings.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/24/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

let keyPrefix =  "me.fin.V2EXSettings."

class V2EXSettings: NSObject {
    static let sharedInstance = V2EXSettings()
    private override init(){
        super.init()
    }
    
    subscript(key:String) -> String? {
        get {
            return NSUserDefaults.standardUserDefaults().objectForKey(keyPrefix + key) as? String
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: keyPrefix + key )
        }
    }
    
    func save(){
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}
