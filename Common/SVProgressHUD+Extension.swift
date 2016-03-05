//
//  SVProgressHUD+Extension.swift
//  V2ex-Swift
//
//  Created by huangfeng on 3/5/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import SVProgressHUD
extension SVProgressHUD {
    /**
     替换 SVProgressHUD 控件中弹框停留时间的计算方法，让汉字比字符停留更久的时间
     不然 abcde 和 我是大帅哥 停留的时间一样,  就感觉隐藏的太快了
     */
    func displayDurationForString(string:String) -> NSTimeInterval {
        return min(Double(string.utf8.count) * 0.06 + 0.5, 5.0)
    }
}
