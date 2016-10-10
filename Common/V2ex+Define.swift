//
//  V2ex+Define.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/11/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit


let SCREEN_WIDTH = UIScreen.main.bounds.size.width;
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height;

//用户代理，使用这个切换是获取 m站点 还是www站数据
let USER_AGENT = "Mozilla/5.0 (iPhone; CPU iPhone OS 8_0 like Mac OS X) AppleWebKit/600.1.3 (KHTML, like Gecko) Version/8.0 Mobile/12A4345d Safari/600.1.4";
let MOBILE_CLIENT_HEADERS = ["user-agent":USER_AGENT]


//站点地址,客户端只有https,禁用http
let V2EXURL = "https://www.v2ex.com/"

let SEPARATOR_HEIGHT = 1.0 / UIScreen.main.scale


func NSLocalizedString( _ key:String ) -> String {
    return NSLocalizedString(key, comment: "")
}


func dispatch_sync_safely_main_queue(_ block: ()->()) {
    if Thread.isMainThread {
        block()
    } else {
        DispatchQueue.main.sync {
            block()
        }
    }
}

func v2Font(_ fontSize: CGFloat) -> UIFont {
    return UIFont.systemFont(ofSize: fontSize);
}

func v2ScaleFont(_ fontSize: CGFloat) -> UIFont{
    return v2Font(fontSize * CGFloat(V2Style.sharedInstance.fontScale))
}
