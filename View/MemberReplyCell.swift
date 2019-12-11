//
//  MemberReplyCell.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2/1/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

class MemberReplyCell: UITableViewCell {

    /// 操作描述
    var detailLabel: UILabel = {
        let detailLabel=V2SpacingLabel();
        detailLabel.font=v2Font(14);
        detailLabel.numberOfLines=0;
        detailLabel.preferredMaxLayoutWidth=SCREEN_WIDTH-24;
        return detailLabel
    }()
    
    /// 回复正文
    var commentLabel: UILabel = {
        let commentLabel=V2SpacingLabel();
        commentLabel.font=v2Font(14);
        commentLabel.numberOfLines=0;
        commentLabel.preferredMaxLayoutWidth=SCREEN_WIDTH-24;
        return commentLabel
    }()
    
    /// 回复正文的背景容器
    var commentPanel: UIView = {
        let commentPanel = UIView()
        commentPanel.layer.cornerRadius = 3
        commentPanel.layer.masksToBounds = true
        return commentPanel
    }()
    
    /// 整个cell元素的容器
    var contentPanel:UIView = {
        let contentPanel = UIView()
        return contentPanel
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
        
        self.contentView.addSubview(self.contentPanel)
        self.contentPanel.addSubview(self.detailLabel);
        self.contentPanel.addSubview(self.commentPanel);
        self.contentPanel.addSubview(self.commentLabel);
        
        self.setupLayout()
        
        let dropUpImageView = UIImageView()
        dropUpImageView.image = UIImage.imageUsedTemplateMode("ic_arrow_drop_up")
        dropUpImageView.contentMode = .scaleAspectFit
        self.contentPanel.addSubview(dropUpImageView)
        dropUpImageView.snp.makeConstraints{ (make) -> Void in
            make.bottom.equalTo(self.commentPanel.snp.top)
            make.left.equalTo(self.commentPanel).offset(25)
            make.width.equalTo(10)
            make.height.equalTo(5)
        }
        
        self.themeChangedHandler = {[weak self] _ in
            self?.backgroundColor = V2EXColor.colors.v2_backgroundColor
            
            self?.detailLabel.textColor=V2EXColor.colors.v2_TopicListTitleColor;
            self?.commentLabel.textColor=V2EXColor.colors.v2_TopicListTitleColor;
            self?.commentPanel.backgroundColor = V2EXColor.colors.v2_backgroundColor
            self?.contentPanel.backgroundColor =  V2EXColor.colors.v2_CellWhiteBackgroundColor
            dropUpImageView.tintColor = self?.commentPanel.backgroundColor
        }
    }
    func setupLayout(){
        self.contentPanel.snp.makeConstraints{ (make) -> Void in
            make.top.left.right.equalTo(self.contentView);
        }
        self.detailLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(self.contentPanel).offset(12);
            make.left.equalTo(self.contentPanel).offset(12);
            make.right.equalTo(self.contentPanel).offset(-12);
        }
        self.commentLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(self.detailLabel.snp.bottom).offset(20);
            make.left.equalTo(self.contentPanel).offset(22);
            make.right.equalTo(self.contentPanel).offset(-22);
        }
        self.contentPanel.snp.makeConstraints{ (make) -> Void in
            make.bottom.equalTo(self.commentPanel.snp.bottom).offset(12);
            make.bottom.equalTo(self.contentView).offset(SEPARATOR_HEIGHT * -1);
        }
        self.commentPanel.snp.makeConstraints{ (make) -> Void in
            make.top.left.equalTo(self.commentLabel).offset(-10)
            make.right.bottom.equalTo(self.commentLabel).offset(10)
        }
    }
    func bind(_ model: MemberRepliesModel){
        if model.date != nil && model.title != nil {
            self.detailLabel.text = model.date! + "回复 " + model.title!
        }
        self.commentLabel.text = model.reply
    }

}
