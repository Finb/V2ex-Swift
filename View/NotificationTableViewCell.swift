//
//  NotificationTableViewCell.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/29/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {
    
    /// 头像
    var avatarImageView: UIImageView = {
        let imageView =  UIImageView()
        imageView.contentMode=UIViewContentMode.scaleAspectFit
        imageView.layer.cornerRadius = 3
        imageView.layer.masksToBounds = true
        return imageView
    }()
    /// 用户名
    var userNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = V2EXColor.colors.v2_TopicListUserNameColor
        label.font=v2Font(14)
        return label
    }()
    /// 日期
    var dateLabel: UILabel = {
        let label = UILabel()
        label.textColor=V2EXColor.colors.v2_TopicListDateColor
        label.font=v2Font(12)
        return label
    }()
    
    /// 操作描述
    var detailLabel: UILabel = {
        let label = V2SpacingLabel()
        label.textColor=V2EXColor.colors.v2_TopicListTitleColor
        label.font=v2Font(14)
        label.numberOfLines=0
        label.preferredMaxLayoutWidth = SCREEN_WIDTH-24
        return label
    }()

    /// 回复正文
    var commentLabel: UILabel = {
        let label = V2SpacingLabel();
        label.textColor=V2EXColor.colors.v2_TopicListTitleColor
        label.font=v2Font(14)
        label.numberOfLines=0
        label.preferredMaxLayoutWidth=SCREEN_WIDTH-24
        return label
    }()
    
    /// 回复正文的背景容器
    var commentPanel: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 3
        view.layer.masksToBounds = true
        view.backgroundColor = V2EXColor.colors.v2_backgroundColor
        return view
    }()
    
    lazy var dropUpImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.imageUsedTemplateMode("ic_arrow_drop_up")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = self.commentPanel.backgroundColor
        return imageView
    }()
    
    /// 整个cell元素的容器
    var contentPanel:UIView = {
        let view = UIView()
        view.backgroundColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
        view.clipsToBounds = true
        return view
    }()
    
    /// 回复按钮
    var replyButton:UIButton = {
        let button = UIButton.roundedButton()
        button.setTitle("回复", for: UIControlState())
        return button
    }()
    
    weak var itemModel:NotificationsModel?
    
    /// 点击回复按钮，调用的事件
    var replyButtonClickHandler: ((UIButton) -> Void)?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        self.setup();
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup()->Void{
        self.backgroundColor=V2EXColor.colors.v2_backgroundColor;
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = V2EXColor.colors.v2_backgroundColor
        self.selectedBackgroundView = selectedBackgroundView
        
        self.contentView .addSubview(self.contentPanel);
        self.contentPanel.addSubview(self.avatarImageView);
        self.contentPanel.addSubview(self.userNameLabel);
        self.contentPanel.addSubview(self.dateLabel);
        self.contentPanel.addSubview(self.detailLabel);
        self.contentPanel.addSubview(self.commentPanel);
        self.contentPanel.addSubview(self.commentLabel);
        self.contentPanel.addSubview(self.dropUpImageView)
        self.contentPanel.addSubview(self.replyButton)

        self.setupLayout()
        
        //点击用户头像，跳转到用户主页
        self.avatarImageView.isUserInteractionEnabled = true
        self.userNameLabel.isUserInteractionEnabled = true
        var userNameTap = UITapGestureRecognizer(target: self, action: #selector(NotificationTableViewCell.userNameTap(_:)))
        self.avatarImageView.addGestureRecognizer(userNameTap)
        userNameTap = UITapGestureRecognizer(target: self, action: #selector(NotificationTableViewCell.userNameTap(_:)))
        self.userNameLabel.addGestureRecognizer(userNameTap)
        
        //按钮点击事件
        self.replyButton.addTarget(self, action: #selector(replyButtonClick(_:)), for: .touchUpInside)
        
    }
    fileprivate func setupLayout(){
        self.avatarImageView.snp_makeConstraints{ (make) -> Void in
            make.left.top.equalTo(self.contentView).offset(12);
            make.width.height.equalTo(35);
        }
        self.userNameLabel.snp_makeConstraints{ (make) -> Void in
            make.left.equalTo(self.avatarImageView.snp_right).offset(10);
            make.top.equalTo(self.avatarImageView);
        }
        self.dateLabel.snp_makeConstraints{ (make) -> Void in
            make.bottom.equalTo(self.avatarImageView);
            make.left.equalTo(self.userNameLabel);
        }
        self.detailLabel.snp_makeConstraints{ (make) -> Void in
            make.top.equalTo(self.avatarImageView.snp_bottom).offset(12);
            make.left.equalTo(self.avatarImageView);
            make.right.equalTo(self.contentPanel).offset(-12);
        }
        self.commentLabel.snp_makeConstraints{ (make) -> Void in
            make.top.equalTo(self.detailLabel.snp_bottom).offset(20);
            make.left.equalTo(self.contentPanel).offset(22);
            make.right.equalTo(self.contentPanel).offset(-22);
        }
        self.commentPanel.snp_makeConstraints{ (make) -> Void in
            make.top.left.equalTo(self.commentLabel).offset(-10)
            make.right.bottom.equalTo(self.commentLabel).offset(10)
        }
        self.dropUpImageView.snp_makeConstraints{ (make) -> Void in
            make.bottom.equalTo(self.commentPanel.snp_top)
            make.left.equalTo(self.commentPanel).offset(25)
            make.width.equalTo(10)
            make.height.equalTo(5)
        }
        self.replyButton.snp_makeConstraints{ (make) -> Void in
            make.centerY.equalTo(self.avatarImageView)
            make.right.equalTo(self.contentPanel).offset(-12)
            make.width.equalTo(50)
            make.height.equalTo(25)
        }
        self.contentPanel.snp_remakeConstraints{ (make) -> Void in
            make.top.left.right.equalTo(self.contentView);
            make.bottom.equalTo(self.commentPanel.snp_bottom).offset(12);
        }
        self.contentView.snp_makeConstraints{ (make) -> Void in
            make.left.top.right.equalTo(self);
            make.bottom.equalTo(self.contentPanel).offset(0);
        }
    }
    
    func userNameTap(_ sender:UITapGestureRecognizer) {
        if let _ = self.itemModel , let username = itemModel?.userName {
            let memberViewController = MemberViewController()
            memberViewController.username = username
            V2Client.sharedInstance.centerNavigation?.pushViewController(memberViewController, animated: true)
        }
    }
    
    func replyButtonClick(_ sender:UIButton){
        self.replyButtonClickHandler?(sender)
    }
    
    func bind(_ model: NotificationsModel){
        
        self.itemModel = model
        
        self.userNameLabel.text = model.userName
        self.dateLabel.text = model.date
        self.detailLabel.text = model.title
        if let text = model.reply {
            self.commentLabel.text = text
            self.setCommentPanelHidden(false)
        }
        else {
            self.setCommentPanelHidden(true)
        }
        
        if let avata = model.avata {
            self.avatarImageView.kf.setImage(with:  URL(string: "https:" + avata)!)
        }
    }
    
    func setCommentPanelHidden(_ hidden:Bool) {
        if hidden {
            self.commentPanel.isHidden = true
            self.dropUpImageView.isHidden = true
            self.commentLabel.text = ""
            self.contentPanel.snp_remakeConstraints{ (make) -> Void in
                make.top.left.right.equalTo(self.contentView);
                make.bottom.equalTo(self.detailLabel.snp_bottom).offset(12);
            }
        }
        else{
            self.commentPanel.isHidden = false
            self.dropUpImageView.isHidden = false
            self.contentPanel.snp_remakeConstraints{ (make) -> Void in
                make.top.left.right.equalTo(self.contentView);
                make.bottom.equalTo(self.commentPanel.snp_bottom).offset(12);
            }
        }
    }

}
