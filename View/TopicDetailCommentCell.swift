//
//  TopicDetailCommentCell.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/20/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

class TopicDetailCommentCell: UITableViewCell {
    /// 头像
    var avatarImageView: UIImageView?
    /// 用户名
    var userNameLabel: UILabel?
    /// 日期 和 最后发送人
    var dateLabel: UILabel?

    /// 回复正文
    var commentLabel: UILabel?
    
    /// 装上面定义的那些元素的容器
    var contentPanel:UIView?
    
    //评论喜欢数
    var favoriteIconView:UIImageView?
    var favoriteLabel:UILabel?
    
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
        self.contentPanel!.backgroundColor=UIColor.whiteColor();
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
        
        self.favoriteIconView = UIImageView(image: UIImage.imageUsedTemplateMode("ic_favorite_18pt")!)
        self.favoriteIconView?.tintColor = V2EXColor.colors.v2_TopicListDateColor;
        self.favoriteIconView?.contentMode = .ScaleAspectFit
        self.contentPanel?.addSubview(self.favoriteIconView!)
        self.favoriteIconView!.snp_makeConstraints{ (make) -> Void in
            make.centerY.equalTo(self.userNameLabel!);
            make.left.equalTo(self.userNameLabel!.snp_right).offset(10)
            make.width.height.equalTo(10)
        }
        self.favoriteIconView!.hidden = true
        
        self.favoriteLabel = UILabel()
        self.favoriteLabel!.textColor = V2EXColor.colors.v2_TopicListDateColor;
        self.favoriteLabel!.font = v2Font(10)
        self.contentPanel!.addSubview(self.favoriteLabel!)
        self.favoriteLabel!.snp_makeConstraints{ (make) -> Void in
            make.left.equalTo(self.favoriteIconView!.snp_right).offset(3)
            make.centerY.equalTo(self.favoriteIconView!)
        }
        
        self.dateLabel = UILabel();
        self.dateLabel!.textColor=V2EXColor.colors.v2_TopicListDateColor;
        self.dateLabel!.font=v2Font(12);
        self.contentPanel?.addSubview(self.dateLabel!);
        self.dateLabel!.snp_makeConstraints{ (make) -> Void in
            make.bottom.equalTo(self.avatarImageView!);
            make.left.equalTo(self.userNameLabel!);
        }
        
        self.commentLabel=V2SpacingLabel();
        self.commentLabel!.textColor=V2EXColor.colors.v2_TopicListTitleColor;
        self.commentLabel!.font=v2Font(14);
        self.commentLabel!.numberOfLines=0;
        self.commentLabel!.preferredMaxLayoutWidth=SCREEN_WIDTH-24;
        self.contentPanel?.addSubview(self.commentLabel!);
        self.commentLabel!.snp_makeConstraints{ (make) -> Void in
            make.top.equalTo(self.avatarImageView!.snp_bottom).offset(12);
            make.left.equalTo(self.avatarImageView!);
            make.right.equalTo(self.contentPanel!).offset(-12);
        }
        
        
        self.contentPanel!.snp_makeConstraints{ (make) -> Void in
            make.bottom.equalTo(self.commentLabel!.snp_bottom).offset(12);
        }
        
        self.contentView.snp_makeConstraints{ (make) -> Void in
            make.left.top.right.equalTo(self);
            make.bottom.equalTo(self.contentPanel!).offset(0);
        }
        
        self.avatarImageView!.backgroundColor = self.contentPanel!.backgroundColor
        self.userNameLabel!.backgroundColor = self.contentPanel!.backgroundColor
        self.dateLabel!.backgroundColor = self.contentPanel!.backgroundColor
        self.commentLabel!.backgroundColor = self.contentPanel!.backgroundColor
        self.favoriteIconView!.backgroundColor = self.contentPanel!.backgroundColor
        self.favoriteLabel!.backgroundColor = self.contentPanel!.backgroundColor
    }
    func bind(model:TopicCommentModel){
        self.userNameLabel?.text = model.userName;
        self.dateLabel?.text = model.date
        self.commentLabel?.text = model.comment;
        
        if let avata = model.avata {
            self.avatarImageView?.fin_setImageWithUrl(NSURL(string: "https:" + avata)!, placeholderImage: nil, imageModificationClosure: fin_defaultImageModification())
        }
        
        self.favoriteIconView!.hidden = model.favorites <= 0
        self.favoriteLabel!.text = model.favorites <= 0 ? "" : "\(model.favorites)"
    }
}
