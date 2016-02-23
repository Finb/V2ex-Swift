//
//  HomeTopicListTableViewCell.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/8/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import Kingfisher

class HomeTopicListTableViewCell: UITableViewCell {
    //? 为什么用这个圆角图片，而不用layer.cornerRadius
    // 因为 设置 layer.cornerRadius 太耗系统资源，每次滑动 都需要渲染很多次，所以滑动掉帧
    // iOS中可以缓存渲染，但效果还是不如直接 用圆角图片
    
    /// 节点信息label的圆角背景图
    static var nodeBackgroundImage_Default =
    createImageWithColor( V2EXDefaultColor.sharedInstance.v2_NodeBackgroundColor ,size: CGSizeMake(10, 20))
        .roundedCornerImageWithCornerRadius(2)
        .stretchableImageWithLeftCapWidth(3, topCapHeight: 3)
    static var nodeBackgroundImage_Dark =
    createImageWithColor( V2EXDarkColor.sharedInstance.v2_NodeBackgroundColor ,size: CGSizeMake(10, 20))
        .roundedCornerImageWithCornerRadius(2)
        .stretchableImageWithLeftCapWidth(3, topCapHeight: 3)
    
    /// 头像
    var avatarImageView: UIImageView?
    /// 用户名
    var userNameLabel: UILabel?
    /// 日期 和 最后发送人
    var dateAndLastPostUserLabel: UILabel?
    /// 评论数量
    var replyCountLabel: UILabel?
    var replyCountIconImageView: UIImageView?
    
    /// 节点
    var nodeNameLabel: UILabel?
    var nodeBackgroundImageView:UIImageView?
    /// 帖子标题
    var topicTitleLabel: UILabel?
    
    /// 装上面定义的那些元素的容器
    var contentPanel:UIView?
    
    weak var itemModel:TopicListModel?
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        self.setup();
    }
    func setup()->Void{
        
        
        let selectedBackgroundView = UIView()
        self.selectedBackgroundView = selectedBackgroundView
        
        self.contentPanel = UIView();
        self.contentView .addSubview(self.contentPanel!);
        self.contentPanel!.snp_makeConstraints{ (make) -> Void in
            make.top.left.right.equalTo(self.contentView);
        }
        
        self.avatarImageView = UIImageView();
        self.avatarImageView!.contentMode=UIViewContentMode.ScaleAspectFit;
        self.contentPanel!.addSubview(self.avatarImageView!);
        self.avatarImageView!.snp_makeConstraints{ (make) -> Void in
            make.left.top.equalTo(self.contentView).offset(12);
            make.width.height.equalTo(35);
        }
        
        self.userNameLabel = UILabel();
        self.userNameLabel!.font=v2Font(14);
        self.contentPanel! .addSubview(self.userNameLabel!);
        self.userNameLabel!.snp_makeConstraints{ (make) -> Void in
            make.left.equalTo(self.avatarImageView!.snp_right).offset(10);
            make.top.equalTo(self.avatarImageView!);
        }
        
        self.dateAndLastPostUserLabel = UILabel();

        self.dateAndLastPostUserLabel!.font=v2Font(12);
        self.contentPanel?.addSubview(self.dateAndLastPostUserLabel!);
        self.dateAndLastPostUserLabel!.snp_makeConstraints{ (make) -> Void in
            make.bottom.equalTo(self.avatarImageView!);
            make.left.equalTo(self.userNameLabel!);
        }
        
        self.replyCountLabel = UILabel();

        self.replyCountLabel!.font = v2Font(12)
        self.contentPanel!.addSubview(self.replyCountLabel!);
        self.replyCountLabel!.snp_makeConstraints{ (make) -> Void in
            make.centerY.equalTo(self.userNameLabel!);
            make.right.equalTo(self.contentPanel!).offset(-12);
        }
        self.replyCountIconImageView = UIImageView(image: UIImage(imageNamed: "reply_n"))
        self.replyCountIconImageView?.contentMode = .ScaleAspectFit
        self.contentPanel?.addSubview(self.replyCountIconImageView!);
        self.replyCountIconImageView!.snp_makeConstraints{ (make) -> Void in
            make.centerY.equalTo(self.replyCountLabel!);
            make.width.height.equalTo(18);
            make.right.equalTo(self.replyCountLabel!.snp_left).offset(-2);
        }
        
        self.nodeBackgroundImageView = UIImageView()
        self.contentPanel?.addSubview(self.nodeBackgroundImageView!)
        
        self.nodeNameLabel = UILabel();

        self.nodeNameLabel!.font = v2Font(11)
        self.contentPanel?.addSubview(self.nodeNameLabel!)
        self.nodeNameLabel!.snp_makeConstraints{ (make) -> Void in
            make.centerY.equalTo(self.replyCountLabel!);
            make.right.equalTo(self.replyCountIconImageView!.snp_left).offset(-9)
            make.bottom.equalTo(self.replyCountLabel!).offset(1);
            make.top.equalTo(self.replyCountLabel!).offset(-1);
        }
        

        self.nodeBackgroundImageView!.snp_makeConstraints{ (make) -> Void in
            make.top.bottom.equalTo(self.nodeNameLabel!)
            make.left.equalTo(self.nodeNameLabel!).offset(-5)
            make.right.equalTo(self.nodeNameLabel!).offset(5)
        }
        
        self.topicTitleLabel=V2SpacingLabel();
        self.topicTitleLabel!.font=v2Font(18);
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
            make.bottom.equalTo(self.contentPanel!).offset(8);
        }
        
        
        self.KVOController.observe(V2EXColor.sharedInstance, keyPath: "style", options: [.Initial,.New]) {[weak self] (nav, color, change) -> Void in
            if V2EXColor.sharedInstance.style == V2EXColor.V2EXColorStyleDefault {
                self?.nodeBackgroundImageView?.image = HomeTopicListTableViewCell.nodeBackgroundImage_Default
            }
            else{
                self?.nodeBackgroundImageView?.image = HomeTopicListTableViewCell.nodeBackgroundImage_Dark
            }
            
            self?.backgroundColor=V2EXColor.colors.v2_backgroundColor;
            self?.selectedBackgroundView!.backgroundColor = V2EXColor.colors.v2_backgroundColor
            self?.contentPanel!.backgroundColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
            self?.userNameLabel!.textColor = V2EXColor.colors.v2_TopicListUserNameColor;
            self?.dateAndLastPostUserLabel!.textColor=V2EXColor.colors.v2_TopicListDateColor;
            self?.replyCountLabel!.textColor = V2EXColor.colors.v2_TopicListDateColor
            self?.nodeNameLabel!.textColor = V2EXColor.colors.v2_TopicListDateColor
            self?.topicTitleLabel!.textColor=V2EXColor.colors.v2_TopicListTitleColor;
            
            self?.avatarImageView!.backgroundColor = self?.contentPanel!.backgroundColor
            self?.userNameLabel!.backgroundColor = self?.contentPanel!.backgroundColor
            self?.dateAndLastPostUserLabel!.backgroundColor = self?.contentPanel!.backgroundColor
            self?.replyCountLabel!.backgroundColor = self?.contentPanel!.backgroundColor
            self?.replyCountIconImageView!.backgroundColor = self?.contentPanel!.backgroundColor
            self?.topicTitleLabel!.backgroundColor = self?.contentPanel!.backgroundColor
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
    

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func bind(model:TopicListModel){
        
        self.itemModel = model
        
        self.userNameLabel?.text = model.userName;
        self.dateAndLastPostUserLabel?.text = model.date
        self.topicTitleLabel?.text = model.topicTitle;
        
        if let avata = model.avata {
            self.avatarImageView?.fin_setImageWithUrl(NSURL(string: "https:" + avata)!, placeholderImage: nil, imageModificationClosure: fin_defaultImageModification() )
        }
        
        self.replyCountLabel?.text = model.replies;
        self.nodeNameLabel!.text = model.nodeName

    }
    
    func bindNodeModel(model:TopicListModel){
        
        self.itemModel = model
        
        self.userNameLabel?.text = model.userName;
        self.dateAndLastPostUserLabel?.text = model.hits
        self.topicTitleLabel?.text = model.topicTitle;
        self.nodeBackgroundImageView!.hidden = true
        if let avata = model.avata {
            self.avatarImageView?.fin_setImageWithUrl(NSURL(string: "https:" + avata)!, placeholderImage: nil, imageModificationClosure: fin_defaultImageModification() )
        }
        
        self.replyCountLabel?.text = model.replies;
        
    }
}
