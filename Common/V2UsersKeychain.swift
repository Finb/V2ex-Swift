//
//  V2Keychain.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2/11/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import KeychainSwift

class V2UsersKeychain {
    static let sharedInstance = V2UsersKeychain()
    private let keychain = KeychainSwift()
    
    private(set) var users:[String:LocalSecurityAccountModel] = [:]
    
    private init() {
        getUsersDict()
    }
    
    func addUser(user:LocalSecurityAccountModel){
        if let username = user.username , let _ = user.password {
            self.users[username] = user
            self.saveUsersDict()
        }
        else {
            assert(false, "username & password must not be 'nil'")
        }
    }
    func addUser(username:String,password:String,avata:String? = nil) {
        let user = LocalSecurityAccountModel()
        user.username = username
        user.password = password
        user.avatar = avata
        self.addUser(user)
    }
    
    static let usersKey = "me.fin.testDict"
    func saveUsersDict(){
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject(self.users)
        archiver.finishEncoding()
        keychain.set(data, forKey: V2UsersKeychain.usersKey)
    }
    func getUsersDict() -> [String:LocalSecurityAccountModel]{
        if users.count <= 0 {
            let data = keychain.getData(V2UsersKeychain.usersKey)
            if let data = data{
                let archiver = NSKeyedUnarchiver(forReadingWithData: data)
                let usersDict = archiver.decodeObject()
                archiver.finishDecoding()
                if let usersDict = usersDict as? [String : LocalSecurityAccountModel] {
                    self.users = usersDict
                }
            }
        }
        return self.users
    }
    
    func removeUser(username:String){
        self.users.removeValueForKey(username)
        self.saveUsersDict()
    }
    func removeAll(){
        self.users = [:]
        self.saveUsersDict()
    }
    
    func update(username:String,password:String? = nil,avatar:String? = nil){
        if let user = self.users[username] {
            if let password = password {
                user.password = password
            }
            if let avatar = avatar {
                user.avatar = avatar
            }
            self.saveUsersDict()
        }
    }
    
}


/// 将会序列化后保存进keychain中的 账户model
class LocalSecurityAccountModel :NSObject, NSCoding {
    var username:String?
    var password:String?
    var avatar:String?
    override init(){
        
    }
    required init?(coder aDecoder: NSCoder){
        self.username = aDecoder.decodeObjectForKey("username") as? String
        self.password = aDecoder.decodeObjectForKey("password") as? String
        self.avatar = aDecoder.decodeObjectForKey("avatar") as? String
    }
    func encodeWithCoder(aCoder: NSCoder){
        aCoder.encodeObject(self.username, forKey: "username")
        aCoder.encodeObject(self.password, forKey: "password")
        aCoder.encodeObject(self.avatar, forKey: "avatar")
    }
}
