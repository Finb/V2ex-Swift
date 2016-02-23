//
//  MemberHeaderCell.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2/1/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

class MemberHeaderCell: UITableViewCell {
    /// 头像
    var avatarImageView: UIImageView?
    /// 用户名
    var userNameLabel: UILabel?
    /// 签名
    var introduceLabel: UILabel?
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
            make.centerY.equalTo(self.contentView).offset(-15)
            make.width.height.equalTo(self.avatarImageView!.layer.cornerRadius * 2)
        }
        
        self.userNameLabel = UILabel()
        self.userNameLabel!.textColor = UIColor(white: 0.85, alpha: 1)
        self.userNameLabel!.font = v2Font(16)
        self.contentView.addSubview(self.userNameLabel!)
        self.userNameLabel!.snp_makeConstraints{ (make) -> Void in
            make.top.equalTo(self.avatarImageView!.snp_bottom).offset(10)
            make.centerX.equalTo(self.avatarImageView!)
        }
        
        self.introduceLabel = UILabel()
        self.introduceLabel!.textColor = UIColor(white: 0.75, alpha: 1)
        self.introduceLabel!.font = v2Font(16)
        self.introduceLabel!.numberOfLines = 2
        self.introduceLabel!.textAlignment = .Center
        self.contentView.addSubview(self.introduceLabel!)
        self.introduceLabel!.snp_makeConstraints{ (make) -> Void in
            make.top.equalTo(self.userNameLabel!.snp_bottom).offset(5)
            make.centerX.equalTo(self.avatarImageView!)
            make.left.equalTo(self.contentView).offset(15)
            make.right.equalTo(self.contentView).offset(-15)
        }
        self.userNameLabel!.text = "Hello"
    }
    
    func bind(model:MemberModel?){
        if let model = model {
            if let avata = model.avata {
                self.avatarImageView?.kf_setImageWithURL(NSURL(string: "https:" + avata)!)
            }
            self.userNameLabel?.text = model.userName;
            self.introduceLabel?.text = model.introduce;
        }
    }
}
