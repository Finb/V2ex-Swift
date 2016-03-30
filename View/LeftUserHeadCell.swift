//
//  LeftUserHeadCell.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/23/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import KVOController
import Kingfisher

class LeftUserHeadCell: UITableViewCell {
    /// 头像
    var avatarImageView: UIImageView?
    /// 用户名
    var userNameLabel: UILabel?
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        self.setup();
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func setup()->Void{
        self.backgroundColor = UIColor.clearColor()
        self.selectionStyle = .None

        self.avatarImageView = UIImageView()
        self.avatarImageView!.backgroundColor = UIColor(white: 0.9, alpha: 0.3)
        self.avatarImageView!.layer.borderWidth = 1.5
        self.avatarImageView!.layer.borderColor = UIColor(white: 1, alpha: 0.6).CGColor
        self.avatarImageView!.layer.masksToBounds = true
        self.avatarImageView!.layer.cornerRadius = 38
        self.contentView.addSubview(self.avatarImageView!)
        self.avatarImageView!.snp_makeConstraints{ (make) -> Void in
            make.centerX.equalTo(self.contentView)
            make.centerY.equalTo(self.contentView).offset(-8)
            make.width.height.equalTo(self.avatarImageView!.layer.cornerRadius * 2)
        }

        self.userNameLabel = UILabel()

        self.userNameLabel!.font = v2Font(16)
        self.contentView.addSubview(self.userNameLabel!)
        self.userNameLabel!.snp_makeConstraints{ (make) -> Void in
            make.top.equalTo(self.avatarImageView!.snp_bottom).offset(10)
            make.centerX.equalTo(self.avatarImageView!)
        }

        self.KVOController.observe(V2User.sharedInstance, keyPath: "username", options: [.Initial , .New]){
            [weak self] (observe, observer, change) -> Void in
            if let weakSelf = self {
                if let user = V2User.sharedInstance.user {
                    weakSelf.userNameLabel?.text = user.username
                    if let avatar = user.avatar_large {
                        weakSelf.avatarImageView?.kf_setImageWithURL(NSURL(string: "https:"+avatar)!, placeholderImage: nil, optionsInfo: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
                            //如果请求到图片时，客户端已经不是登录状态了，则将图片清除
                            if !V2User.sharedInstance.isLogin {
                                weakSelf.avatarImageView?.image = nil
                            }
                        })
                    }
                }
                else { //没有登录
                    weakSelf.userNameLabel?.text = "请先登录"
                    weakSelf.avatarImageView?.image = nil
                }
            }
        }

        self.KVOController.observe(V2EXColor.sharedInstance, keyPath: "style", options: [.Initial,.New]) {[weak self] (nav, color, change) -> Void in
            self?.userNameLabel?.textColor = V2EXColor.colors.v2_TopicListUserNameColor
        }
    }

}
