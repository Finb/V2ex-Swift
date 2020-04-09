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
     - parameter once:              once
     - parameter completionHandler: 登录回调
     */
    class func Login(_ username:String,password:String ,once:String,
                     usernameFieldName:String ,passwordFieldName:String,
                     codeFieldName:String, code:String,
                     completionHandler: @escaping (V2ValueResponse<String>, Bool) -> Void){
        let prames = [
            "once":once,
            "next":"/",
            passwordFieldName:password,
            usernameFieldName:username,
            codeFieldName: code
        ]
        
        var dict = MOBILE_CLIENT_HEADERS
        //为安全，此处使用https
        dict["Referer"] = "https://v2ex.com/signin"
        //登录
        Alamofire.request(V2EXURL+"signin",method:.post, parameters: prames, headers: dict).responseJiHtml{
            (response) -> Void in
            if let jiHtml = response .result.value{
                //判断有没有用户头像，如果有，则证明登录成功了
                if let avatarImg = jiHtml.xPath("//*[@id='menu-entry']/img")?.first {
                    if let altUsername = avatarImg.attributes["alt"]{
                        if altUsername == username {
                            //用户开启了两步验证
                            if let url = response.response?.url?.absoluteString, url.contains("2fa") {
                                completionHandler(V2ValueResponse(value: username, success: true),true)
                            }
                                //登陆完成
                            else{
                                completionHandler(V2ValueResponse(value: username, success: true),false)
                            }
                            return;
                        }
                    }
                }
                else if let errMessage = jiHtml.xPath("//*[contains(@class, 'problem')]/ul/li")?.first?.value , errMessage.count > 0 {
                    completionHandler(V2ValueResponse(success: false,message: errMessage),false)
                    return
                }
                
            }
            completionHandler(V2ValueResponse(success: false,message: "登录失败"),false)
        }
    }
    
    class func twoFALogin(code:String,
                          completionHandler: @escaping (Bool) -> Void) {
        V2User.sharedInstance.getOnce { (response) in
            if(response.success){
                let prames = [
                    "code":code,
                    "once":V2User.sharedInstance.once!
                    ] as [String:Any]
                let url = V2EXURL + "2fa"
                Alamofire.request(url, method: .post, parameters: prames, headers: MOBILE_CLIENT_HEADERS).responseJiHtml { (response) -> Void in
                    if(response.result.isSuccess){
                        if let url = response.response?.url?.absoluteString, url.contains("2fa") {
                            completionHandler(false);
                        }
                        else{
                            completionHandler(true);
                        }
                    }
                    else{
                        completionHandler(false);
                    }
                }
            }
            else{
                completionHandler(false);
            }
        }
    }
    
    class func getUserInfoByUsername(_ username:String ,completionHandler:((V2ValueResponse<UserModel>) -> Void)? ){
        
        _ = UserApi.provider.requestAPI(.getUserInfo(username: username))
            .mapResponseToObj(UserModel.self)
            .subscribe(onNext: { (userModel) in
                V2User.sharedInstance.user = userModel
                //将头像更新进 keychain保存的users中
                if let avatar = userModel.avatar_large?.avatarString {
                    V2UsersKeychain.sharedInstance.update(username, password: nil, avatar: avatar )
                }
                completionHandler?(V2ValueResponse(value: userModel, success: true))
                return ;
            }, onError: { (error) in
                completionHandler?(V2ValueResponse(success: false,message: "获取用户信息失败"))
            });
    }
    
    
    class func dailyRedeem() {
        V2User.sharedInstance.getOnce { (response) -> Void in
            if response.success {
                Alamofire.request(V2EXURL + "mission/daily/redeem?once=" + V2User.sharedInstance.once! , headers: MOBILE_CLIENT_HEADERS).responseJiHtml{ (response) in
                    if let jiHtml = response .result.value{
                        if let aRootNode = jiHtml.xPath("//*[@id='Wrapper']/div/div/div[@class='message']")?.last {
                            if aRootNode.content?.trimmingCharacters(in: .whitespaces) == "已成功领取每日登录奖励" {
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
