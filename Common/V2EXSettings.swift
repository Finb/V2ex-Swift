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
    fileprivate override init(){
        super.init()
    }
    
    subscript<T : Codable>(key:String) -> T? {
        get {
            return UserDefaults.standard.object(forKey: keyPrefix + key) as? T
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: keyPrefix + key )
        }
    }
}

let Settings = V2EXSettings.sharedInstance
