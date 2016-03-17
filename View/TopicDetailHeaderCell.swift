//
//  TopicDetailHeaderCell.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/18/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

class TopicDetailHeaderCell: UITableViewCell {
    /// 头像
    var avatarImageView: UIImageView?
    /// 用户名
    var userNameLabel: UILabel?
    /// 日期 和 最后发送人
    var dateAndLastPostUserLabel: UILabel?

    /// 节点
    var nodeNameLabel: UILabel?
    
    /// 帖子标题
    var topicTitleLabel: UILabel?
    
    /// 装上面定义的那些元素的容器
    var contentPanel:UIView?
    
    weak var itemModel:TopicDetailModel?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        self.setup();
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func setup()->Void{
        self.selectionStyle = .None
        self.backgroundColor=V2EXColor.colors.v2_backgroundColor;
        
        self.contentPanel = UIView();
        self.contentPanel!.backgroundColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
        self.contentView .addSubview(self.contentPanel!);
        self.contentPanel!.snp_makeConstraints{ (make) -> Void in
            make.top.left.right.equalTo(self.contentView);
        }
        
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
        
        self.dateAndLastPostUserLabel = UILabel();
        self.dateAndLastPostUserLabel!.textColor=V2EXColor.colors.v2_TopicListDateColor;
        self.dateAndLastPostUserLabel!.font=v2Font(12);
        self.contentPanel?.addSubview(self.dateAndLastPostUserLabel!);
        self.dateAndLastPostUserLabel!.snp_makeConstraints{ (make) -> Void in
            make.bottom.equalTo(self.avatarImageView!);
            make.left.equalTo(self.userNameLabel!);
        }
        self.nodeNameLabel = UILabel();
        self.nodeNameLabel!.textColor = V2EXColor.colors.v2_TopicListDateColor
        self.nodeNameLabel!.font = v2Font(11)
        self.nodeNameLabel!.backgroundColor = V2EXColor.colors.v2_NodeBackgroundColor
        self.nodeNameLabel?.layer.cornerRadius=2;
        self.nodeNameLabel!.clipsToBounds = true
        self.contentPanel?.addSubview(self.nodeNameLabel!)
        self.nodeNameLabel!.snp_makeConstraints{ (make) -> Void in
            make.centerY.equalTo(self.userNameLabel!);
            make.right.equalTo(self.contentPanel!.snp_right).offset(-10)
            make.bottom.equalTo(self.userNameLabel!).offset(1);
            make.top.equalTo(self.userNameLabel!).offset(-1);
        }
        
        self.topicTitleLabel=V2SpacingLabel();
        self.topicTitleLabel!.textColor=V2EXColor.colors.v2_TopicListTitleColor;
        self.topicTitleLabel!.font=v2Font(17);
        self.topicTitleLabel!.numberOfLines=0;
        self.topicTitleLabel!.preferredMaxLayoutWidth=SCREEN_WIDTH-24;
        self.contentPanel?.addSubview(self.topicTitleLabel!);
        self.topicTitleLabel!.snp_makeConstraints{ (make) -> Void in
            make.top.equalTo(self.avatarImageView!.snp_bottom).offset(12);
            make.left.equalTo(self.avatarImageView!);
            make.right.equalTo(self.contentPanel!).offset(-12);
        }
        
        
        self.contentPanel!.snp_makeConstraints{ (make) -> Void in
            make.bottom.equalTo(self.topicTitleLabel!.snp_bottom).offset(12);
        }
        
        self.contentView.snp_makeConstraints{ (make) -> Void in
            make.left.top.right.equalTo(self);
            make.bottom.equalTo(self.contentPanel!).offset(0);
        }
        
        //点击用户头像，跳转到用户主页
        self.avatarImageView!.userInteractionEnabled = true
        self.userNameLabel!.userInteractionEnabled = true
        var userNameTap = UITapGestureRecognizer(target: self, action: "userNameTap:")
        self.avatarImageView!.addGestureRecognizer(userNameTap)
        userNameTap = UITapGestureRecognizer(target: self, action: "userNameTap:")
        self.userNameLabel!.addGestureRecognizer(userNameTap)
    }
    
    func userNameTap(sender:UITapGestureRecognizer) {
        if let _ = self.itemModel , username = itemModel?.userName {
            let memberViewController = MemberViewController()
            memberViewController.username = username
            V2Client.sharedInstance.centerNavigation?.pushViewController(memberViewController, animated: true)
        }
    }
    
    func bind(model:TopicDetailModel){
        
        self.itemModel = model
        
        self.userNameLabel?.text = model.userName;
        self.dateAndLastPostUserLabel?.text = model.date
        self.topicTitleLabel?.text = model.topicTitle;
        
        if let avata = model.avata {
            self.avatarImageView?.fin_setImageWithUrl(NSURL(string: "https:" + avata)!, placeholderImage: nil, imageModificationClosure: fin_defaultImageModification())
        }
        
        if let node = model.nodeName{
            self.nodeNameLabel!.text = "  " + node + "  "
        }
    }
}
