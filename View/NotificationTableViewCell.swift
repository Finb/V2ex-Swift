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
        imageView.contentMode=UIView.ContentMode.scaleAspectFit
        imageView.layer.cornerRadius = 3
        imageView.layer.masksToBounds = true
        return imageView
    }()
    /// 用户名
    var userNameLabel: UILabel = {
        let label = UILabel()
        label.font=v2Font(14)
        return label
    }()
    /// 日期
    var dateLabel: UILabel = {
        let label = UILabel()
        label.font=v2Font(12)
        return label
    }()
    
    /// 操作描述
    var detailLabel: UILabel = {
        let label = V2SpacingLabel()
        label.font=v2Font(14)
        label.numberOfLines=0
        label.preferredMaxLayoutWidth = SCREEN_WIDTH-24
        return label
    }()

    /// 回复正文
    var commentLabel: UILabel = {
        let label = V2SpacingLabel();
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
        return view
    }()
    
    lazy var dropUpImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.imageUsedTemplateMode("ic_arrow_drop_up")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    /// 整个cell元素的容器
    var contentPanel:UIView = {
        let view = UIView()
        view.clipsToBounds = true
        return view
    }()
    
    /// 回复按钮
    var replyButton:UIButton = {
        let button = UIButton.roundedButton()
        button.setTitle(NSLocalizedString("reply"), for: .normal)
        return button
    }()
    
    weak var itemModel:NotificationsModel?
    
    /// 点击回复按钮，调用的事件
    var replyButtonClickHandler: ((UIButton) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        self.setup();
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup()->Void{
        
        let selectedBackgroundView = UIView()
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
        
        self.themeChangedHandler = {[weak self] _ in
            self?.backgroundColor=V2EXColor.colors.v2_backgroundColor;
            self?.selectedBackgroundView?.backgroundColor = V2EXColor.colors.v2_backgroundColor
            self?.userNameLabel.textColor = V2EXColor.colors.v2_TopicListUserNameColor
            self?.dateLabel.textColor=V2EXColor.colors.v2_TopicListDateColor
            self?.detailLabel.textColor=V2EXColor.colors.v2_TopicListTitleColor
            self?.commentLabel.textColor=V2EXColor.colors.v2_TopicListTitleColor
            self?.commentPanel.backgroundColor = V2EXColor.colors.v2_backgroundColor
            self?.dropUpImageView.tintColor = self?.commentPanel.backgroundColor
            self?.contentPanel.backgroundColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
            self?.replyButton.backgroundColor  = V2EXColor.colors.v2_ButtonBackgroundColor
        }
        
    }
    fileprivate func setupLayout(){
        self.avatarImageView.snp.makeConstraints{ (make) -> Void in
            make.left.top.equalTo(self.contentView).offset(12);
            make.width.height.equalTo(35);
        }
        self.userNameLabel.snp.makeConstraints{ (make) -> Void in
            make.left.equalTo(self.avatarImageView.snp.right).offset(10);
            make.top.equalTo(self.avatarImageView);
        }
        self.dateLabel.snp.makeConstraints{ (make) -> Void in
            make.bottom.equalTo(self.avatarImageView);
            make.left.equalTo(self.userNameLabel);
        }
        self.detailLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(self.avatarImageView.snp.bottom).offset(12);
            make.left.equalTo(self.avatarImageView);
            make.right.equalTo(self.contentPanel).offset(-12);
        }
        self.commentLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(self.detailLabel.snp.bottom).offset(20);
            make.left.equalTo(self.contentPanel).offset(22);
            make.right.equalTo(self.contentPanel).offset(-22);
        }
        self.commentPanel.snp.makeConstraints{ (make) -> Void in
            make.top.left.equalTo(self.commentLabel).offset(-10)
            make.right.bottom.equalTo(self.commentLabel).offset(10)
        }
        self.dropUpImageView.snp.makeConstraints{ (make) -> Void in
            make.bottom.equalTo(self.commentPanel.snp.top)
            make.left.equalTo(self.commentPanel).offset(25)
            make.width.equalTo(10)
            make.height.equalTo(5)
        }
        self.replyButton.snp.makeConstraints{ (make) -> Void in
            make.centerY.equalTo(self.avatarImageView)
            make.right.equalTo(self.contentPanel).offset(-12)
            make.width.equalTo(50)
            make.height.equalTo(25)
        }
    }
    
    @objc func userNameTap(_ sender:UITapGestureRecognizer) {
        if let _ = self.itemModel , let username = itemModel?.userName {
            let memberViewController = MemberViewController()
            memberViewController.username = username
            V2Client.sharedInstance.centerNavigation?.pushViewController(memberViewController, animated: true)
        }
    }
    
    @objc func replyButtonClick(_ sender:UIButton){
        self.replyButtonClickHandler?(sender)
    }
    
    func bind(_ model: NotificationsModel){
        
        self.itemModel = model
        
        self.userNameLabel.text = model.userName
        self.dateLabel.text = model.date
        self.detailLabel.text = model.title
        if let text = model.reply {
            self.commentLabel.text = text.trimmingCharacters(in: .whitespacesAndNewlines)
            self.setCommentPanelHidden(false)
        }
        else {
            self.setCommentPanelHidden(true)
        }
        
        if let avata = model.avata?.avatarString {
            self.avatarImageView.kf.setImage(with:  URL(string: avata)!)
        }
    }
    
    func setCommentPanelHidden(_ hidden:Bool) {
        if hidden {
            self.commentPanel.isHidden = true
            self.dropUpImageView.isHidden = true
            self.commentLabel.text = ""
            self.contentPanel.snp.remakeConstraints{ (make) -> Void in
                make.bottom.equalTo(self.detailLabel.snp.bottom).offset(12);
                make.top.left.right.equalTo(self.contentView);
                make.bottom.equalTo(self.contentView).offset(SEPARATOR_HEIGHT * -1)
            }
        }
        else{
            self.commentPanel.isHidden = false
            self.dropUpImageView.isHidden = false
            self.contentPanel.snp.remakeConstraints{ (make) -> Void in
                make.bottom.equalTo(self.commentPanel.snp.bottom).offset(12);
                make.top.left.right.equalTo(self.contentView);
                make.bottom.equalTo(self.contentView).offset(SEPARATOR_HEIGHT * -1)
            }
        }
    }

}
