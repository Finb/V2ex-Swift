//
//  V2ex+Define.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/11/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

let EMPTY_STRING = "" ;

let SCREEN_WIDTH = UIScreen.mainScreen().bounds.size.width;
let SCREEN_HEIGHT = UIScreen.mainScreen().bounds.size.height;

let LightBundel = NSBundle(path: NSBundle.mainBundle().pathForResource("Light", ofType: "bundle")!)!
let DarkBundel = NSBundle(path: NSBundle.mainBundle().pathForResource("Dark", ofType: "bundle")!)!
let CurrentBundel = LightBundel

//用户代理，使用这个切换是获取 m站点 还是www站数据
let USER_AGENT = "Mozilla/5.0 (iPhone; CPU iPhone OS 8_0 like Mac OS X) AppleWebKit/600.1.3 (KHTML, like Gecko) Version/8.0 Mobile/12A4345d Safari/600.1.4";
let MOBILE_CLIENT_HEADERS = ["user-agent":USER_AGENT]

//CSS配色
let LIGHT_CSS = try! String(contentsOfFile: LightBundel.pathForResource("style", ofType: "css")!, encoding: NSUTF8StringEncoding)
let DARK_CSS = try! String(contentsOfFile: DarkBundel.pathForResource("style", ofType: "css")!, encoding: NSUTF8StringEncoding)

//站点地址,客户端只有https,禁用http
let V2EXURL = "https://www.v2ex.com/"

let SEPARATOR_HEIGHT = 1.0 / UIScreen.mainScreen().scale

extension UIImage {
    convenience init? (imageNamed: String){
        self.init(named: imageNamed, inBundle: CurrentBundel, compatibleWithTraitCollection: nil)
    }
}

func NSLocalizedString( key:String ) -> String {
    return NSLocalizedString(key, comment: "")
}