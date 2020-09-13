//
//  TopicDetailHeaderCell.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/18/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import SVProgressHUD

class TopicDetailHeaderCell: UITableViewCell {
    /// 头像
   var avatarImageView: UIImageView = {
        let imageview = UIImageView();
        imageview.contentMode=UIView.ContentMode.scaleAspectFit;
        imageview.layer.cornerRadius = 3;
        imageview.layer.masksToBounds = true;
        return imageview
    }()
    /// 用户名
    var userNameLabel: UILabel = {
        let label = UILabel();
        label.font=v2Font(14);
        return label
    }()
    /// 日期 和 最后发送人
    var dateAndLastPostUserLabel: UILabel = {
        let label = UILabel();
        label.font=v2Font(12);
        return label
    }()

    /// 节点
    var nodeNameLabel: UILabel = {
        let label = UILabel();
        label.font = v2Font(11)
        label.layer.cornerRadius=2;
        label.clipsToBounds = true
        label.isUserInteractionEnabled = true
        return label
    }()
    
    let reportImageView:UIImageView = {
        
        let imageView = HitTestSlopImageView()
        imageView.hitTestSlop = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -5)
        imageView.image = UIImage(named: "baseline_report_black_24pt")?.withRenderingMode(.alwaysTemplate)
        imageView.alpha = 0.7
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    /// 帖子标题
    var topicTitleLabel: UILabel = {
        let label = V2SpacingLabel();
        label.font = v2Font(17);
        label.numberOfLines = 0;
        label.preferredMaxLayoutWidth = SCREEN_WIDTH-24;
        return label
    }()
    
    /// 装上面定义的那些元素的容器
    var contentPanel:UIView = {
        let view = UIView()
        return view
    }()
    
    weak var itemModel:TopicDetailModel?
    var nodeClickHandler:(() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        self.setup();
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func setup()->Void{
        self.selectionStyle = .none
        
        
        self.contentView.addSubview(self.contentPanel);
        self.contentPanel.addSubview(self.avatarImageView);
        self.contentPanel.addSubview(self.userNameLabel);
        self.contentPanel.addSubview(self.dateAndLastPostUserLabel);
        self.contentPanel.addSubview(self.nodeNameLabel)
        self.contentPanel.addSubview(self.reportImageView)
        self.contentPanel.addSubview(self.topicTitleLabel);

        self.setupLayout()
    
        //点击用户头像，跳转到用户主页
        self.avatarImageView.isUserInteractionEnabled = true
        self.userNameLabel.isUserInteractionEnabled = true
        var userNameTap = UITapGestureRecognizer(target: self, action: #selector(TopicDetailHeaderCell.userNameTap(_:)))
        self.avatarImageView.addGestureRecognizer(userNameTap)
        userNameTap = UITapGestureRecognizer(target: self, action: #selector(TopicDetailHeaderCell.userNameTap(_:)))
        self.userNameLabel.addGestureRecognizer(userNameTap)
        self.nodeNameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(nodeClick)))
        self.reportImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(reportClick)))
        
        self.themeChangedHandler = {[weak self] _ in
            self?.backgroundColor=V2EXColor.colors.v2_backgroundColor;
            self?.userNameLabel.textColor = V2EXColor.colors.v2_TopicListUserNameColor;
            self?.dateAndLastPostUserLabel.textColor=V2EXColor.colors.v2_TopicListDateColor;
            self?.nodeNameLabel.textColor = V2EXColor.colors.v2_TopicListDateColor
            self?.nodeNameLabel.backgroundColor = V2EXColor.colors.v2_NodeBackgroundColor
            self?.reportImageView.tintColor = V2EXColor.colors.v2_TopicListDateColor
            self?.topicTitleLabel.textColor = V2EXColor.colors.v2_TopicListTitleColor;
            self?.contentPanel.backgroundColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
        }
    }
    
    fileprivate func setupLayout(){
        self.avatarImageView.snp.makeConstraints{ (make) -> Void in
            make.left.top.equalTo(self.contentPanel).offset(12);
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
        self.nodeNameLabel.snp.makeConstraints{ (make) -> Void in
            make.centerY.equalTo(self.userNameLabel);
            make.right.equalTo(self.contentPanel.snp.right).offset(-10)
            make.bottom.equalTo(self.userNameLabel).offset(1);
            make.top.equalTo(self.userNameLabel).offset(-1);
        }
        self.reportImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(16)
            make.centerY.equalTo(self.nodeNameLabel)
            make.right.equalTo(self.nodeNameLabel.snp.left).offset(-5)
        }
        self.topicTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.avatarImageView.snp.bottom).offset(12);
            make.left.equalTo(self.avatarImageView);
            make.right.equalTo(self.contentPanel).offset(-12);
        }
        self.contentPanel.snp.makeConstraints{ (make) -> Void in
            make.top.left.right.equalTo(self.contentView);
            make.bottom.equalTo(self.topicTitleLabel.snp.bottom).offset(12);
            make.bottom.equalTo(self.contentView).offset(SEPARATOR_HEIGHT * -1);
        }
    }
    @objc func nodeClick() {
        nodeClickHandler?()
    }
    @objc func userNameTap(_ sender:UITapGestureRecognizer) {
        if let _ = self.itemModel , let username = itemModel?.userName {
            let memberViewController = MemberViewController()
            memberViewController.username = username
            V2Client.sharedInstance.centerNavigation?.pushViewController(memberViewController, animated: true)
        }
    }
    @objc func reportSuccess(){
        SVProgressHUD.showSuccess(withStatus: NSLocalizedString("reportSuccess"))
    }
    @objc func reportClick(){
        
        func report(){
            SVProgressHUD.show()
            self.perform(#selector(reportSuccess), with: nil, afterDelay: 1)
        }
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let reportNudeAction = UIAlertAction(title: NSLocalizedString("reportNude"), style: .default) { _ in
            report()
        }
        let reportHateAction = UIAlertAction(title: NSLocalizedString("reportHate"), style: .default) { _ in
            report()
        }
        let reportViolenceAction = UIAlertAction(title: NSLocalizedString("reportViolence"), style: .default) { _ in
            report()
        }
        let reportScamAction = UIAlertAction(title: NSLocalizedString("reportScam"), style: .default) { _ in
            report()
        }
        let reportOtherAction = UIAlertAction(title: NSLocalizedString("reportOther"), style: .default) { _ in
            report()
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        //将action全加进actionSheet
        [reportNudeAction,reportHateAction,reportViolenceAction,reportScamAction,reportOtherAction,cancelAction].forEach { (action) -> () in
            actionSheet.addAction(action)
        }
        V2Client.sharedInstance.topNavigationController.present(actionSheet, animated: true, completion: nil)
    }
    
    func bind(_ model:TopicDetailModel){
        
        self.itemModel = model
        
        self.userNameLabel.text = model.userName;
        self.dateAndLastPostUserLabel.text = model.date
        self.topicTitleLabel.text = model.topicTitle;
        
        if let avata = model.avata?.avatarString {
            self.avatarImageView.fin_setImageWithUrl(URL(string: avata)!, placeholderImage: nil, imageModificationClosure: fin_defaultImageModification())
        }
        
        if let node = model.nodeName{
            self.nodeNameLabel.text = "  " + node + "  "
        }
    }
}
