//
//  String+Avatar.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2020/4/9.
//  Copyright © 2020 Fin. All rights reserved.
//

import UIKit

extension String {
    var avatarString:String {
        if self.hasPrefix("http") {
            return self
        }
        else{
            //某些时期 V2ex 使用 //: 自适应scheme ，需要加上https
            return "https:" + self
        }
    }
}
