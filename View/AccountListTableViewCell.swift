//
//  AccountListTableViewCell.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2/11/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

class AccountListTableViewCell: UITableViewCell {
    var avatarImageView:UIImageView = {
        let avatarImageView = UIImageView()
        avatarImageView.backgroundColor = UIColor(white: 0.9, alpha: 0.3)
        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.cornerRadius = 22
        return avatarImageView
    }()
    var userNameLabel:UILabel = {
        let userNameLabel = UILabel()
        userNameLabel.font = v2Font(14)
        return userNameLabel
    }()
    var usedLabel:UILabel = {
        let usedLabel = UILabel()
        usedLabel.font = v2Font(11)
        usedLabel.text = NSLocalizedString("current")
        return usedLabel
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        self.setup();
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setup()->Void{
        self.selectionStyle = .none

        self.contentView.addSubview(self.avatarImageView)
        self.contentView.addSubview(self.userNameLabel)
        self.contentView.addSubview(self.usedLabel)
        let separator = UIImageView()
        self.contentView.addSubview(separator)

        self.usedLabel.isHidden = true;

        self.avatarImageView.snp.makeConstraints{ (make) -> Void in
            make.left.equalTo(self.contentView).offset(15)
            make.centerY.equalTo(self.contentView)
            make.width.height.equalTo(self.avatarImageView.layer.cornerRadius * 2)
        }
        self.userNameLabel.snp.makeConstraints{ (make) -> Void in
            make.left.equalTo(self.avatarImageView.snp.right).offset(15)
            make.centerY.equalTo(self.avatarImageView)
        }
        self.usedLabel.snp.makeConstraints{ (make) -> Void in
            make.right.equalTo(self.contentView).offset(-15)
            make.centerY.equalTo(self.avatarImageView)
        }
        separator.snp.makeConstraints{ (make) -> Void in
            make.left.equalTo(self.avatarImageView.snp.right).offset(5)
            make.right.bottom.equalTo(self.contentView)
            make.height.equalTo(SEPARATOR_HEIGHT)
        }
        
        self.themeChangedHandler = {[weak self] _ in
            self?.backgroundColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
            self?.userNameLabel.textColor = V2EXColor.colors.v2_TopicListUserNameColor
            self?.usedLabel.textColor = V2EXColor.colors.v2_NoticePointColor
            
            separator.image = createImageWithColor(V2EXColor.colors.v2_SeparatorColor)
        }
    }
    
    func bind(_ model:LocalSecurityAccountModel) {
        self.userNameLabel.text = model.username
        if let avatar = model.avatar , let url = URL(string: avatar) {
            self.avatarImageView.fin_setImageWithUrl(url)
        }
        if V2User.sharedInstance.username == model.username {
            self.usedLabel.isHidden = false
        }
        else {
            self.usedLabel.isHidden = true
        }
    }
}
