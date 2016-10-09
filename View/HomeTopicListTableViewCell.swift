//
//  HomeTopicListTableViewCell.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/8/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import Kingfisher
import YYText

class HomeTopicListTableViewCell: UITableViewCell {
    //? 为什么用这个圆角图片，而不用layer.cornerRadius
    // 因为 设置 layer.cornerRadius 太耗系统资源，每次滑动 都需要渲染很多次，所以滑动掉帧
    // iOS中可以缓存渲染，但效果还是不如直接 用圆角图片
    
    /// 节点信息label的圆角背景图
    fileprivate static var nodeBackgroundImage_Default =
        createImageWithColor( V2EXDefaultColor.sharedInstance.v2_NodeBackgroundColor ,size: CGSize(width: 10, height: 20))
            .roundedCornerImageWithCornerRadius(2)
            .stretchableImage(withLeftCapWidth: 3, topCapHeight: 3)
    fileprivate static var nodeBackgroundImage_Dark =
        createImageWithColor( V2EXDarkColor.sharedInstance.v2_NodeBackgroundColor ,size: CGSize(width: 10, height: 20))
            .roundedCornerImageWithCornerRadius(2)
            .stretchableImage(withLeftCapWidth: 3, topCapHeight: 3)
    
    /// 头像
    var avatarImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.contentMode=UIViewContentMode.scaleAspectFit
        return imageview
    }()
    
    /// 用户名
    var userNameLabel: UILabel = {
        let label = UILabel()
        label.font = v2Font(14)
        return label;
    }()
    /// 日期 和 最后发送人
    var dateAndLastPostUserLabel: UILabel = {
        let label = UILabel()
        label.font=v2Font(12)
        return label
    }()
    /// 评论数量
    var replyCountLabel: UILabel = {
        let label = UILabel()
        label.font = v2Font(12)
        return label
    }()
    var replyCountIconImageView: UIImageView = {
        let imageview = UIImageView(image: UIImage(named: "reply_n"))
        imageview.contentMode = .scaleAspectFit
        return imageview
    }()
    
    /// 节点
    var nodeNameLabel: UILabel = {
        let label = UILabel();
        label.font = v2Font(11)
        return label
    }()
    var nodeBackgroundImageView:UIImageView = UIImageView()
    /// 帖子标题
    var topicTitleLabel: YYLabel = {
        let label = YYLabel()
        label.textVerticalAlignment = .top
        label.font=v2Font(18)
        label.displaysAsynchronously = true
        label.numberOfLines=0
        return label
    }()
    
    /// 装上面定义的那些元素的容器
    var contentPanel:UIView = UIView()
    
    var itemModel:TopicListModel?
    
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
        
        self.contentView .addSubview(self.contentPanel);
        self.contentPanel.addSubview(self.avatarImageView);
        self.contentPanel.addSubview(self.userNameLabel);
        self.contentPanel.addSubview(self.dateAndLastPostUserLabel);
        self.contentPanel.addSubview(self.replyCountLabel);
        self.contentPanel.addSubview(self.replyCountIconImageView);
        self.contentPanel.addSubview(self.nodeBackgroundImageView)
        self.contentPanel.addSubview(self.nodeNameLabel)
        self.contentPanel.addSubview(self.topicTitleLabel);
        
        self.setupLayout()

        self.thmemChangedHandler = {[weak self] (style) -> Void in
            if style == V2EXColor.V2EXColorStyleDefault {
                self?.nodeBackgroundImageView.image = HomeTopicListTableViewCell.nodeBackgroundImage_Default
            }
            else{
                self?.nodeBackgroundImageView.image = HomeTopicListTableViewCell.nodeBackgroundImage_Dark
            }
            
            self?.backgroundColor=V2EXColor.colors.v2_backgroundColor;
            self?.selectedBackgroundView!.backgroundColor = V2EXColor.colors.v2_backgroundColor
            self?.contentPanel.backgroundColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
            self?.userNameLabel.textColor = V2EXColor.colors.v2_TopicListUserNameColor;
            self?.dateAndLastPostUserLabel.textColor=V2EXColor.colors.v2_TopicListDateColor;
            self?.replyCountLabel.textColor = V2EXColor.colors.v2_TopicListDateColor
            self?.nodeNameLabel.textColor = V2EXColor.colors.v2_TopicListDateColor
            self?.topicTitleLabel.textColor=V2EXColor.colors.v2_TopicListTitleColor;
            
            self?.avatarImageView.backgroundColor = self?.contentPanel.backgroundColor
            self?.userNameLabel.backgroundColor = self?.contentPanel.backgroundColor
            self?.dateAndLastPostUserLabel.backgroundColor = self?.contentPanel.backgroundColor
            self?.replyCountLabel.backgroundColor = self?.contentPanel.backgroundColor
            self?.replyCountIconImageView.backgroundColor = self?.contentPanel.backgroundColor
            self?.topicTitleLabel.backgroundColor = self?.contentPanel.backgroundColor
        }
        
        //点击用户头像，跳转到用户主页
        self.avatarImageView.isUserInteractionEnabled = true
        self.userNameLabel.isUserInteractionEnabled = true
        var userNameTap = UITapGestureRecognizer(target: self, action: #selector(HomeTopicListTableViewCell.userNameTap(_:)))
        self.avatarImageView.addGestureRecognizer(userNameTap)
        userNameTap = UITapGestureRecognizer(target: self, action: #selector(HomeTopicListTableViewCell.userNameTap(_:)))
        self.userNameLabel.addGestureRecognizer(userNameTap)
        
    }
    
    fileprivate func setupLayout(){
        self.contentPanel.snp.makeConstraints{ (make) -> Void in
            make.top.left.right.equalTo(self.contentView);
        }
        self.avatarImageView.snp.makeConstraints{ (make) -> Void in
            make.left.top.equalTo(self.contentView).offset(12);
            make.width.height.equalTo(35);
        }
        self.userNameLabel.snp.makeConstraints{ (make) -> Void in
            make.left.equalTo(self.avatarImageView.snp.right).offset(10);
            make.top.equalTo(self.avatarImageView);
        }
        self.dateAndLastPostUserLabel.snp.makeConstraints{ (make) -> Void in
            make.bottom.equalTo(self.avatarImageView);
            make.left.equalTo(self.userNameLabel);
        }
        self.replyCountLabel.snp.makeConstraints{ (make) -> Void in
            make.centerY.equalTo(self.userNameLabel);
            make.right.equalTo(self.contentPanel).offset(-12);
        }
        self.replyCountIconImageView.snp.makeConstraints{ (make) -> Void in
            make.centerY.equalTo(self.replyCountLabel);
            make.width.height.equalTo(18);
            make.right.equalTo(self.replyCountLabel.snp.left).offset(-2);
        }
        self.nodeNameLabel.snp.makeConstraints{ (make) -> Void in
            make.centerY.equalTo(self.replyCountLabel);
            make.right.equalTo(self.replyCountIconImageView.snp.left).offset(-9)
            make.bottom.equalTo(self.replyCountLabel).offset(1);
            make.top.equalTo(self.replyCountLabel).offset(-1);
        }
        self.nodeBackgroundImageView.snp.makeConstraints{ (make) -> Void in
            make.top.bottom.equalTo(self.nodeNameLabel)
            make.left.equalTo(self.nodeNameLabel).offset(-5)
            make.right.equalTo(self.nodeNameLabel).offset(5)
        }
        self.topicTitleLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(self.avatarImageView.snp.bottom).offset(12);
            make.left.equalTo(self.avatarImageView);
            make.right.equalTo(self.contentPanel).offset(-12);
            make.bottom.equalTo(self.contentView).offset(-8)
        }
        self.contentPanel.snp.makeConstraints{ (make) -> Void in
            make.bottom.equalTo(self.contentView.snp.bottom).offset(-8);
        }
    }
    
    func userNameTap(_ sender:UITapGestureRecognizer) {
        if let _ = self.itemModel , let username = itemModel?.userName {
            let memberViewController = MemberViewController()
            memberViewController.username = username
            V2Client.sharedInstance.centerNavigation?.pushViewController(memberViewController, animated: true)
        }
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func superBind(_ model:TopicListModel){
        self.userNameLabel.text = model.userName;
        if let layout = model.topicTitleLayout {
            //如果新旧model标题相同,则不需要赋值
            //不然layout需要重新绘制，会造成刷新闪烁
            if layout.text.string == self.itemModel?.topicTitleLayout?.text.string {
                return
            }
            else{
                self.topicTitleLabel.textLayout = layout
            }
        }
        if let avata = model.avata {
            self.avatarImageView.fin_setImageWithUrl(URL(string: "https:" + avata)!, placeholderImage: nil, imageModificationClosure: fin_defaultImageModification() )
        }
        self.replyCountLabel.text = model.replies;
        
        self.itemModel = model
    }
    
    func bind(_ model:TopicListModel){
        self.superBind(model)
        self.dateAndLastPostUserLabel.text = model.date
        self.nodeNameLabel.text = model.nodeName
    }
    
    func bindNodeModel(_ model:TopicListModel){
        self.superBind(model)
        self.dateAndLastPostUserLabel.text = model.hits
        self.nodeBackgroundImageView.isHidden = true
    }
}
