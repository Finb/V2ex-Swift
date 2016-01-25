//
//  V2Client.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/15/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import DrawerController

let kUserName = "username"

class V2Client: NSObject {
    static let sharedInstance = V2Client()
    
    var drawerController :DrawerController? = nil
    var centerViewController : HomeViewController? = nil
    
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
    
    override init() {
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
    func printAllCookies(){
        let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        if let cookies = storage.cookies {
            for cookie in cookies {
                NSLog("name:%@ , value:%@ \n", cookie.name,cookie.value)
            }
        }
    }
}
