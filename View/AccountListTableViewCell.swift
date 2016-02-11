//
//  AccountListTableViewCell.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2/11/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

class AccountListTableViewCell: UITableViewCell {
    var avatarImageView:UIImageView?
    var userNameLabel:UILabel?
    var usedLabel:UILabel?
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        self.setup();
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setup()->Void{
        self.selectionStyle = .None
        
        self.avatarImageView = UIImageView()
        self.avatarImageView!.backgroundColor = UIColor(white: 0.9, alpha: 0.3)
        self.avatarImageView!.layer.masksToBounds = true
        self.avatarImageView!.layer.cornerRadius = 22
        self.contentView.addSubview(self.avatarImageView!)
        self.avatarImageView!.snp_makeConstraints{ (make) -> Void in
            make.left.equalTo(self.contentView).offset(15)
            make.centerY.equalTo(self.contentView)
            make.width.height.equalTo(self.avatarImageView!.layer.cornerRadius * 2)
        }
        
        self.userNameLabel = UILabel()
        self.userNameLabel!.textColor = V2EXColor.colors.v2_TopicListUserNameColor
        self.userNameLabel!.font = v2Font(14)
        self.contentView.addSubview(self.userNameLabel!)
        self.userNameLabel!.snp_makeConstraints{ (make) -> Void in
            make.left.equalTo(self.avatarImageView!.snp_right).offset(15)
            make.centerY.equalTo(self.avatarImageView!)
        }
        
        self.usedLabel = UILabel()
        self.usedLabel!.textColor = colorWith255RGB(207, g: 70, b: 71)
        self.usedLabel!.font = v2Font(11)
        self.usedLabel!.text = "正在使用"
        self.contentView.addSubview(self.usedLabel!)
        self.usedLabel!.snp_makeConstraints{ (make) -> Void in
            make.right.equalTo(self.contentView).offset(-15)
            make.centerY.equalTo(self.avatarImageView!)
        }
        self.usedLabel?.hidden = true;
        
        let separator = UIImageView(image: createImageWithColor(colorWith255RGB(190, g: 190, b: 190)))
        self.contentView.addSubview(separator)
        separator.snp_makeConstraints{ (make) -> Void in
            make.left.equalTo(self.avatarImageView!.snp_right).offset(5)
            make.right.bottom.equalTo(self.contentView)
            make.height.equalTo(SEPARATOR_HEIGHT)
        }
    }
    
    func bind(model:LocalSecurityAccountModel) {
        self.userNameLabel?.text = model.username
        if let avatar = model.avatar , let url = NSURL(string: avatar) {
            self.avatarImageView?.kf_setImageWithURL(url)
        }
        if V2Client.sharedInstance.username == model.username {
            self.usedLabel?.hidden = false
        }
        else {
            self.usedLabel?.hidden = true
        }
    }
}
