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
    var avatarImageView: UIImageView?
    /// 用户名
    var userNameLabel: UILabel?
    /// 日期
    var dateLabel: UILabel?
    
    /// 操作描述
    var detailLabel: UILabel?

    /// 回复正文
    var commentLabel: UILabel?
    
    /// 回复正文的背景容器
    var commentPanel: UIView?
    var dropUpImageView: UIImageView?
    
    /// 整个cell元素的容器
    var contentPanel:UIView?
    
    /// 回复按钮
    var replyButton:UIButton?
    
    weak var itemModel:NotificationsModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

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
        
        self.contentPanel = UIView();
        self.contentPanel!.backgroundColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
        self.contentPanel!.clipsToBounds = true
        self.contentView .addSubview(self.contentPanel!);
        
        self.avatarImageView = UIImageView();
        self.avatarImageView!.contentMode=UIViewContentMode.ScaleAspectFit;
        self.avatarImageView!.layer.cornerRadius = 3;
        self.avatarImageView!.layer.masksToBounds = true;
        self.contentPanel!.addSubview(self.avatarImageView!);
        self.avatarImageView!.snp_makeConstraints{ (make) -> Void in
            make.left.top.equalTo(self.contentView).offset(12);
            make.width.height.equalTo(35);
        }
        
        self.userNameLabel = UILabel();
        self.userNameLabel!.textColor = V2EXColor.colors.v2_TopicListUserNameColor;
        self.userNameLabel!.font=v2Font(14);
        self.contentPanel! .addSubview(self.userNameLabel!);
        self.userNameLabel!.snp_makeConstraints{ (make) -> Void in
            make.left.equalTo(self.avatarImageView!.snp_right).offset(10);
            make.top.equalTo(self.avatarImageView!);
        }
        
        self.dateLabel = UILabel();
        self.dateLabel!.textColor=V2EXColor.colors.v2_TopicListDateColor;
        self.dateLabel!.font=v2Font(12);
        self.contentPanel?.addSubview(self.dateLabel!);
        self.dateLabel!.snp_makeConstraints{ (make) -> Void in
            make.bottom.equalTo(self.avatarImageView!);
            make.left.equalTo(self.userNameLabel!);
        }
        
        self.detailLabel=V2SpacingLabel();
        self.detailLabel!.textColor=V2EXColor.colors.v2_TopicListTitleColor;
        self.detailLabel!.font=v2Font(14);
        self.detailLabel!.numberOfLines=0;
        self.detailLabel!.preferredMaxLayoutWidth=SCREEN_WIDTH-24;
        self.contentPanel?.addSubview(self.detailLabel!);
        self.detailLabel!.snp_makeConstraints{ (make) -> Void in
            make.top.equalTo(self.avatarImageView!.snp_bottom).offset(12);
            make.left.equalTo(self.avatarImageView!);
            make.right.equalTo(self.contentPanel!).offset(-12);
        }
        

        
        self.commentPanel = UIView()
        self.commentPanel!.layer.cornerRadius = 3
        self.commentPanel!.layer.masksToBounds = true
        self.commentPanel!.backgroundColor = V2EXColor.colors.v2_backgroundColor ;
        self.contentPanel!.addSubview(self.commentPanel!);
        
        self.commentLabel=V2SpacingLabel();
        self.commentLabel!.textColor=V2EXColor.colors.v2_TopicListTitleColor;
        self.commentLabel!.font=v2Font(14);
        self.commentLabel!.numberOfLines=0;
        self.commentLabel!.preferredMaxLayoutWidth=SCREEN_WIDTH-24;
        self.contentPanel?.addSubview(self.commentLabel!);
        self.commentLabel!.snp_makeConstraints{ (make) -> Void in
            make.top.equalTo(self.detailLabel!.snp_bottom).offset(20);
            make.left.equalTo(self.contentPanel!).offset(22);
            make.right.equalTo(self.contentPanel!).offset(-22);
        }
        
        self.commentPanel!.snp_makeConstraints{ (make) -> Void in
            make.top.left.equalTo(self.commentLabel!).offset(-10)
            make.right.bottom.equalTo(self.commentLabel!).offset(10)
        }
        self.dropUpImageView = UIImageView()
        self.dropUpImageView!.image = UIImage.imageUsedTemplateMode("ic_arrow_drop_up")
        self.dropUpImageView!.contentMode = .ScaleAspectFit
        self.dropUpImageView!.tintColor = self.commentPanel!.backgroundColor
        self.contentPanel!.addSubview(self.dropUpImageView!)
        self.dropUpImageView!.snp_makeConstraints{ (make) -> Void in
            make.bottom.equalTo(self.commentPanel!.snp_top)
            make.left.equalTo(self.commentPanel!).offset(25)
            make.width.equalTo(10)
            make.height.equalTo(5)
        }
        
        self.replyButton = UIButton.roundedButton()
        self.contentPanel!.addSubview(self.replyButton!)
        self.replyButton!.snp_makeConstraints{ (make) -> Void in
            make.centerY.equalTo(self.avatarImageView!)
            make.right.equalTo(self.contentPanel!).offset(-12)
            make.width.equalTo(50)
            make.height.equalTo(25)
        }
        self.replyButton!.setTitle("回复", forState: .Normal)
        
        self.contentPanel!.snp_remakeConstraints{ (make) -> Void in
            make.top.left.right.equalTo(self.contentView);
            make.bottom.equalTo(self.commentPanel!.snp_bottom).offset(12);
        }
        
        self.contentView.snp_makeConstraints{ (make) -> Void in
            make.left.top.right.equalTo(self);
            make.bottom.equalTo(self.contentPanel!).offset(0);
        }
        
        self.contentPanel?.backgroundColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
        
        //点击用户头像，跳转到用户主页
        self.avatarImageView!.userInteractionEnabled = true
        self.userNameLabel!.userInteractionEnabled = true
        var userNameTap = UITapGestureRecognizer(target: self, action: #selector(NotificationTableViewCell.userNameTap(_:)))
        self.avatarImageView!.addGestureRecognizer(userNameTap)
        userNameTap = UITapGestureRecognizer(target: self, action: #selector(NotificationTableViewCell.userNameTap(_:)))
        self.userNameLabel!.addGestureRecognizer(userNameTap)
        
    }
    
    func userNameTap(sender:UITapGestureRecognizer) {
        if let _ = self.itemModel , username = itemModel?.userName {
            let memberViewController = MemberViewController()
            memberViewController.username = username
            V2Client.sharedInstance.centerNavigation?.pushViewController(memberViewController, animated: true)
        }
    }
    
    func bind(model: NotificationsModel){
        
        self.itemModel = model
        
        self.userNameLabel?.text = model.userName
        self.dateLabel?.text = model.date
        self.detailLabel?.text = model.title
        if let text = model.reply {
            self.commentLabel!.text = text
            self.setCommentPanelHidden(false)
        }
        else {
            self.setCommentPanelHidden(true)
        }
        
        if let avata = model.avata {
            self.avatarImageView?.kf_setImageWithURL(NSURL(string: "https:" + avata)!)
        }
    }
    
    func setCommentPanelHidden(hidden:Bool) {
        if hidden {
            self.commentPanel!.hidden = true
            self.dropUpImageView!.hidden = true
            self.commentLabel!.text = ""
            self.contentPanel!.snp_remakeConstraints{ (make) -> Void in
                make.top.left.right.equalTo(self.contentView);
                make.bottom.equalTo(self.detailLabel!.snp_bottom).offset(12);
            }
        }
        else{
            self.commentPanel!.hidden = false
            self.dropUpImageView!.hidden = false
            self.contentPanel!.snp_remakeConstraints{ (make) -> Void in
                make.top.left.right.equalTo(self.contentView);
                make.bottom.equalTo(self.commentPanel!.snp_bottom).offset(12);
            }
        }
    }

}
