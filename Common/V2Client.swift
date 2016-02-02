//
//  V2Client.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/15/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import DrawerController
import Alamofire
import Ji
let kUserName = "me.fin.username"

class V2Client: NSObject {
    static let sharedInstance = V2Client()
    
    var drawerController :DrawerController? = nil
    var centerViewController : HomeViewController? = nil
    var centerNavigation : V2EXNavigationController? = nil
    
    /// 用户信息
    private var _user:UserModel?
    var user:UserModel? {
        get {
            return self._user
        }
        set {
            //保证给user赋值是在主线程进行的
            //原因是 有很多UI可能会监听这个属性，这个属性发生更改时，那些UI也会相应的修改自己，所以要在主线程操作
            if NSThread.isMainThread() {
                self._user = newValue
                self.username = newValue?.username 
            }
            else {
                dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                    self._user = newValue
                    self.username = newValue?.username
                })
            }
        }
    }
    
    dynamic var username:String?
    

    private var _once:String?
    //全局once字符串，用于用户各种操作，例如回帖 登陆 。这些操作都需要用的once ，而且这个once是全局统一的
    var once:String?  {
        get {
            //取了之后就删掉,
            //因为once 只能使用一次，之后就不可再用了，
            let onceStr = _once
            _once = nil
            return onceStr;
        }
        set{
            _once = newValue
        }
    }
    /// 返回 客户端显示是否有可用的once
    var hasOnce:Bool {
        get {
            return _once?.Lenght > 0
        }
    }
    
    /// 通知数量
    dynamic var notificationCount:Int = 0
    
    
    
    private override init() {
        super.init()
        self.setupInMainThread()
    }
    func setupInMainThread() {
        if NSThread.isMainThread() {
            self.setup()
        }
        else {
            dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                self.setup()
            })
        }
    }
    func setup(){
        self.username = V2EXSettings.sharedInstance[kUserName]
    }
    
    
    /// 是否登陆
    var isLogin:Bool {
        get {
            if self.username?.Lenght > 0 {
                return true
            }
            else {
                return false
            }
        }
    }
    
    /**
     退出登录
     */
    func loginOut() {
        removeAllCookies()
    }
    
    /**
     删除客户端所有cookies
     */
    func removeAllCookies() {
        let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        if let cookies = storage.cookies {
            for cookie in cookies {
                storage.deleteCookie(cookie)
            }
        }
    }
    /**
     打印客户端cookies
     */
    func printAllCookies(){
        let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        if let cookies = storage.cookies {
            for cookie in cookies {
                NSLog("name:%@ , value:%@ \n", cookie.name,cookie.value)
            }
        }
    }
    
    /**
     获取once
     
     - parameter url:               有once存在的url
     */
    func getOnce(url:String, completionHandler: V2Response -> Void) {
        if(self.hasOnce){
            completionHandler(V2Response(success: true))
            return;
        }
        Alamofire.request(.GET, url, parameters: nil, encoding: .URL, headers: MOBILE_CLIENT_HEADERS).responseJiHtml {
            (response) -> Void in
            if let jiHtml = response .result.value{
                if let once = jiHtml.xPath("//*[@name='once'][1]")?.first?["value"]{
                    self.once = once
                    completionHandler(V2Response(success: true))
                    return;
                }
            }
            completionHandler(V2Response(success: false))
        }
    }
    
    /**
     获取并更新通知数量
     
     - parameter rootNode: 有Notifications 的节点
     */
    func getNotificationsCount(rootNode: JiNode) {
        let notification = rootNode.xPath("//head/title").first?.content
        if let notification = notification {
            
            self.notificationCount = 0;
            
            let regex = try! NSRegularExpression(pattern: "V2EX \\([0-9]+\\)", options: [.CaseInsensitive])
            regex.enumerateMatchesInString(notification, options: [.WithoutAnchoringBounds], range: NSMakeRange(0, notification.Lenght), usingBlock: { (result, flags, stop) -> Void in
                if let result = result {
                    let startIndex = notification.startIndex.advancedBy(result.range.location + 6)
                    let endIndex = notification.startIndex.advancedBy(result.range.location + result.range.length - 1)
                    let subRange = Range<String.Index>(start: startIndex, end: endIndex)
                    let count = notification.substringWithRange(subRange)
                    if let acount = Int(count) {
                        self.notificationCount = acount
                    }
                }
            })
        }
    }
}
