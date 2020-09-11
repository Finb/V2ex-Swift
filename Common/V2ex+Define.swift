//
//  V2ex+Define.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/11/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import DeviceKit

//屏幕宽度
let SCREEN_WIDTH = UIScreen.main.bounds.size.width;
//屏幕高度
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height;
//NavagationBar高度
let NavigationBarHeight:CGFloat = {
    return kSafeAreaInsets.top + 44
}()
let kSafeAreaInsets:UIEdgeInsets = {
    if #available(iOS 12.0, *){
        return UIWindow().safeAreaInsets
    }
    if UIDevice.current.isIphoneX {
        return UIEdgeInsets(top: 44, left: 0, bottom: 34, right: 0)
    }
    return UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
}()
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


extension UIDevice {
    var isIphoneX: Bool {
        get {
            return Device.current.isOneOf(Device.allXSeriesDevices + Device.allSimulatorXSeriesDevices)
        }
    }
}

extension UITableView {
    func cancelEstimatedHeight(){
        self.estimatedRowHeight = 0
        self.estimatedSectionFooterHeight = 0
        self.estimatedSectionHeaderHeight = 0
    }
}

