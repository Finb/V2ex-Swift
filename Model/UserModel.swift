//
//  UserModel.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/23/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import Alamofire
import Ji

class UserModel: NSObject {

    class func Login(username:String,password:String ,
        completionHandler: V2Response -> Void
        ) -> Void{
            V2Client.sharedInstance.removeAllCookies()
        Alamofire.request(.GET, V2EXURL+"signin", parameters: nil, encoding: .URL, headers: MOBILE_CLIENT_HEADERS).responseString{
             (response: Response<String,NSError>) -> Void in
            
            if let html = response .result.value{
                let jiHtml = Ji(htmlString: html);
                //获取帖子内容
                //取出 once 登录时要用
                
                var onceStr:String?
                if let once = jiHtml?.xPath("//*[@name='once'][1]")?.first?["value"]{
                    onceStr = once
                }
                
                if let onceStr = onceStr {
                    UserModel.Login(username, password: password, once: onceStr, completionHandler: completionHandler)
                    return;
                }
            }
            completionHandler(V2Response(success: false,message: "获取 once 失败"))
        }
    }
    
    class func Login(username:String,password:String ,once:String,
        completionHandler: V2Response -> Void){
            let prames = [
                "once":once,
                "next":"/",
                "p":password,
                "u":username
            ]
            
            var dict = MOBILE_CLIENT_HEADERS
            dict["Referer"] = "http://v2ex.com/signin"
            //登陆
            Alamofire.request(.POST, V2EXURL+"signin", parameters: prames, encoding: .URL, headers: dict).responseString{
                (response: Response<String,NSError>) -> Void in
                if let html = response .result.value{
                    let jiHtml = Ji(htmlString: html);
                    //判断有没有用户头像，如果有，则证明登陆成功了
                    if jiHtml?.xPath("//*[@id='Top']/div/div/table/tr/td[3]/a[1]/img[1]")?.first != nil{
                        completionHandler(V2Response(success: true))
                        return;
                    }
                    
                }
                completionHandler(V2Response(success: false,message: "登陆失败"))
            }
    }

}


