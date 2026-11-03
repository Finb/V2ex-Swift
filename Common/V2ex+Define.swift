//
//  V2ex+Define.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/11/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

// 屏幕宽度
var SCREEN_WIDTH: CGFloat { V2Client.sharedInstance.window?.bounds.width ?? UIScreen.main.bounds.size.width }
// 屏幕高度
var SCREEN_HEIGHT: CGFloat { V2Client.sharedInstance.window?.bounds.height ?? UIScreen.main.bounds.size.height }
// NavagationBar高度
var NavigationBarHeight: CGFloat {
    return kSafeAreaInsets.top + 44
}
var kSafeAreaInsets: UIEdgeInsets {
    return V2Client.sharedInstance.window?.safeAreaInsets ?? .zero
}
// 用户代理，使用这个切换是获取 m站点 还是www站数据
let USER_AGENT = "Mozilla/5.0 (iPhone; CPU iPhone OS 14_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.2 Mobile/15E148 Safari/604.1"
let MOBILE_CLIENT_HEADERS: [String: String] = [
    "user-agent": USER_AGENT,
    "Accept-Language": "zh-Hans"
]

// 站点地址,客户端只有https,禁用http
let V2EXURL = "https://www.v2ex.com/"

let SEPARATOR_HEIGHT = 1.0 / UIScreen.main.scale

func NSLocalizedString(_ key: String) -> String {
    return NSLocalizedString(key, comment: "")
}

func dispatch_sync_safely_main_queue(_ block: () -> Void) {
    if Thread.isMainThread {
        block()
    } else {
        DispatchQueue.main.sync {
            block()
        }
    }
}

func v2Font(_ fontSize: CGFloat) -> UIFont {
    return UIFont.systemFont(ofSize: fontSize)
}

func v2ScaleFont(_ fontSize: CGFloat) -> UIFont {
    return v2Font(fontSize * CGFloat(V2Style.sharedInstance.fontScale))
}

extension UIBarButtonItem {
    /// iOS 26 起导航栏按钮默认带有液态玻璃背景，这里统一去掉
    @discardableResult
    func hidingGlassBackground() -> UIBarButtonItem {
        if #available(iOS 26.0, *) {
            hidesSharedBackground = true
        }
        return self
    }
}

extension UITableView {
    func cancelEstimatedHeight() {
        self.estimatedRowHeight = 120
        self.rowHeight = UITableView.automaticDimension // Self-sizing cell
        self.estimatedSectionFooterHeight = 0
        self.estimatedSectionHeaderHeight = 0
    }
}
