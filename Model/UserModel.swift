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
import ObjectMapper

class UserModel: BaseJsonModel {
    var status:String?
    var id:String?
    var url:String?
    var username:String?
    var website:String?
    var twitter:String?
    var psn:String?
    var btc:String?
    var location:String?
    var tagline:String?
    var bio:String?
    var avatar_mini:String?
    var avatar_normal:String?
    var avatar_large:String?
    var created:String?

    override func mapping(map: Map) {
        status <- map["status"]
        id <- map["id"]
        url <- map["url"]
        username <- map["username"]
        website <- map["website"]
        twitter <- map["twitter"]
        psn <- map["psn"]
        btc <- map["btc"]
        location <- map["location"]
        tagline <- map["tagline"]
        bio <- map["bio"]
        avatar_mini <- map["avatar_mini"]
        avatar_normal <- map["avatar_normal"]
        avatar_large <- map["avatar_large"]
        created <- map["created"]
    }
}

//MARK: - Request
extension UserModel{
    /**
     登录

     - parameter username:          用户名
     - parameter password:          密码
     - parameter completionHandler: 登录回调
     */
    class func Login(_ username:String,password:String ,
                     completionHandler: @escaping (V2ValueResponse<String>) -> Void
        ) -> Void{
        V2User.sharedInstance.removeAllCookies()
        
        Alamofire.request(V2EXURL+"signin", method: .get,  parameters: [:], encoding: URLEncoding.default, headers: MOBILE_CLIENT_HEADERS).responseJiHtml{
            (response) -> Void in

            if let jiHtml = response .result.value{
                //获取帖子内容
                //取出 once 登录时要用

                let onceStr:String? = jiHtml.xPath("//*[@name='once'][1]")?.first?["value"]
                let usernameStr:String? = jiHtml.xPath("//*[@id='Wrapper']/div/div[1]/div[2]/form/table/tr[1]/td[2]/input[@class='sl']")?.first?["name"]
                let passwordStr:String? = jiHtml.xPath("//*[@id='Wrapper']/div/div[1]/div[2]/form/table/tr[2]/td[2]/input[@class='sl']")?.first?["name"]

                if let onceStr = onceStr , let usernameStr = usernameStr, let passwordStr = passwordStr {
                    UserModel.Login(username, password: password, once: onceStr, usernameFieldName: usernameStr, passwordFieldName: passwordStr , completionHandler: completionHandler)
                    return;
                }
            }
            completionHandler(V2ValueResponse(success: false,message: "获取 必要字段 失败"))
        }
    }

    /**
     登录

     - parameter username:          用户名
     - parameter password:          密码
     - parameter once:              once
     - parameter completionHandler: 登录回调
     */
    class func Login(_ username:String,password:String ,once:String,
                     usernameFieldName:String ,passwordFieldName:String,
                     completionHandler: @escaping (V2ValueResponse<String>) -> Void){
        let prames = [
            "once":once,
            "next":"/",
            passwordFieldName:password,
            usernameFieldName:username
        ]

        var dict = MOBILE_CLIENT_HEADERS
        //为安全，此处使用https
        dict["Referer"] = "https://v2ex.com/signin"
        //登录
        Alamofire.request(V2EXURL+"signin",method:.post, parameters: prames, encoding: URLEncoding.default, headers: dict).responseJiHtml{
            (response) -> Void in
            if let jiHtml = response .result.value{
                //判断有没有用户头像，如果有，则证明登录成功了
                if let avatarImg = jiHtml.xPath("//*[@id='Top']/div/div/table/tr/td[3]/a[1]/img[1]")?.first {
                    if let username = avatarImg.parent?["href"]{
                        if username.hasPrefix("/member/") {
                            let username = username.replacingOccurrences(of: "/member/", with: "")

                            completionHandler(V2ValueResponse(value: username, success: true))
                            return;
                        }
                    }
                }

            }
            completionHandler(V2ValueResponse(success: false,message: "登录失败"))
        }
    }

    class func getUserInfoByUsername(_ username:String ,completionHandler:((V2ValueResponse<UserModel>) -> Void)? ){
        let prame = [
            "username":username
        ]
        Alamofire.request(V2EXURL+"api/members/show.json", method: .get, parameters: prame, encoding: URLEncoding.default, headers: MOBILE_CLIENT_HEADERS).responseObject { (response : DataResponse<UserModel>) in
            if let model = response.result.value {
                V2User.sharedInstance.user = model
                
                //将头像更新进 keychain保存的users中
                if let avatar = model.avatar_large {
                    V2UsersKeychain.sharedInstance.update(username, password: nil, avatar: "https:" + avatar )
                }
                
                completionHandler?(V2ValueResponse(value: model, success: true))
                return ;
            }
            completionHandler?(V2ValueResponse(success: false,message: "获取用户信息失败"))
        }
    }


    class func dailyRedeem() {
        V2User.sharedInstance.getOnce { (response) -> Void in
            if response.success {
                Alamofire.request(V2EXURL + "mission/daily/redeem?once=" + V2User.sharedInstance.once! , method: .get, parameters: [:], encoding: URLEncoding.default, headers: MOBILE_CLIENT_HEADERS).responseJiHtml{ (response) in
                    if let jiHtml = response .result.value{
                        if let aRootNode = jiHtml.xPath("//*[@id='Wrapper']/div/div/div[@class='message']")?.first {
                            if aRootNode.content == "已成功领取每日登录奖励" {
                                print("每日登录奖励 领取成功")
                                dispatch_sync_safely_main_queue({ () -> () in
                                    V2Inform("已成功领取每日登录奖励")
                                })
                            }
                        }

                    }
                }

            }
        }
    }

}
