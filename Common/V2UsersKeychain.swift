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
    fileprivate let keychain = KeychainSwift()
    
    fileprivate(set) var users:[String:LocalSecurityAccountModel] = [:]
    
    fileprivate init() {
        let _ = loadUsersDict()
    }
    
    func addUser(_ user:LocalSecurityAccountModel){
        if let username = user.username{
            self.users[username] = user
            self.saveUsersDict()
        }
        else {
            assert(false, "username must not be 'nil'")
        }
    }
    func addUser(_ username:String,password:String,avata:String? = nil) {
        let user = LocalSecurityAccountModel()
        user.username = username
        user.avatar = avata
        self.addUser(user)
    }
    
    static let usersKey = "me.fin.testDict"
    func saveUsersDict(){
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.encode(self.users)
        archiver.finishEncoding()
        keychain.set(data as Data, forKey: V2UsersKeychain.usersKey);
    }
    func loadUsersDict() -> [String:LocalSecurityAccountModel]{
        if users.count <= 0 {
            let data = keychain.getData(V2UsersKeychain.usersKey)
            if let data = data{
                let archiver = NSKeyedUnarchiver(forReadingWith: data)
                let usersDict = archiver.decodeObject()
                archiver.finishDecoding()
                if let usersDict = usersDict as? [String : LocalSecurityAccountModel] {
                    self.users = usersDict
                }
            }
        }
        return self.users
    }
    
    func removeUser(_ username:String){
        self.users.removeValue(forKey: username)
        self.saveUsersDict()
    }
    func removeAll(){
        self.users = [:]
        self.saveUsersDict()
    }
    
    func update(_ username:String,password:String? = nil,avatar:String? = nil){
        if let user = self.users[username] {
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
    var avatar:String?
    override init(){
        
    }
    required init?(coder aDecoder: NSCoder){
        self.username = aDecoder.decodeObject(forKey: "username") as? String
        self.avatar = aDecoder.decodeObject(forKey: "avatar") as? String
    }
    func encode(with aCoder: NSCoder){
        aCoder.encode(self.username, forKey: "username")
        aCoder.encode(self.avatar, forKey: "avatar")
    }
}
