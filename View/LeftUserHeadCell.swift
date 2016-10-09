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
    var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor(white: 0.9, alpha: 0.3)
        imageView.layer.borderWidth = 1.5
        imageView.layer.borderColor = UIColor(white: 1, alpha: 0.6).cgColor
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 38
        return imageView
    }()
    /// 用户名
    var userNameLabel: UILabel = {
        let label = UILabel()
        label.font = v2Font(16)
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        self.setup();
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func setup()->Void{
        self.backgroundColor = UIColor.clear
        self.selectionStyle = .none

        self.contentView.addSubview(self.avatarImageView)
        self.contentView.addSubview(self.userNameLabel)
        
        self.avatarImageView.snp.makeConstraints{ (make) -> Void in
            make.centerX.equalTo(self.contentView)
            make.centerY.equalTo(self.contentView).offset(-8)
            make.width.height.equalTo(self.avatarImageView.layer.cornerRadius * 2)
        }
        self.userNameLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(self.avatarImageView.snp.bottom).offset(10)
            make.centerX.equalTo(self.avatarImageView)
        }

        self.kvoController.observe(V2User.sharedInstance, keyPath: "username", options: [.initial , .new]){
            [weak self] (observe, observer, change) -> Void in
            if let weakSelf = self {
                if let user = V2User.sharedInstance.user {
                    weakSelf.userNameLabel.text = user.username
                    if let avatar = user.avatar_large {
                        weakSelf.avatarImageView.kf.setImage(with: URL(string: "https:"+avatar)!, placeholder: nil, options: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
                            //如果请求到图片时，客户端已经不是登录状态了，则将图片清除
                            if !V2User.sharedInstance.isLogin {
                                weakSelf.avatarImageView.image = nil
                            }
                        })
                    }
                }
                else { //没有登录
                    weakSelf.userNameLabel.text = "请先登录"
                    weakSelf.avatarImageView.image = nil
                }
            }
        }

        self.thmemChangedHandler = {[weak self] (style) -> Void in
            self?.userNameLabel.textColor = V2EXColor.colors.v2_TopicListUserNameColor
        }
    }

}
