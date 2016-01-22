//
//  V2Client.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/15/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import DrawerController

let USER_AGENT = "Mozilla/5.0 (iPhone; CPU iPhone OS 8_0 like Mac OS X) AppleWebKit/600.1.3 (KHTML, like Gecko) Version/8.0 Mobile/12A4345d Safari/600.1.4";

let MOBILE_CLIENT_HEADERS = ["user-agent":USER_AGENT]

let LIGHT_CSS = try! String(contentsOfFile: LightBundel.pathForResource("style", ofType: "css")!, encoding: NSUTF8StringEncoding)
let DARK_CSS = try! String(contentsOfFile: DarkBundel.pathForResource("style", ofType: "css")!, encoding: NSUTF8StringEncoding)


class V2Client: NSObject {
    static let sharedInstance = V2Client()
    
    var drawerController :DrawerController? = nil
    var centerViewController : HomeViewController? = nil
    
    var isLogin:Bool {
        get {
            return true
        }
    }
    
    /**
     退出登录
     */
    func loginOut() {
        removeAllCookies()
    }
    func removeAllCookies() {
        let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        if let cookies = storage.cookies {
            for cookie in cookies {
                storage.deleteCookie(cookie)
            }
        }
    }
}
