//
//  SearchTableViewCell.swift
//  V2ex-Swift
//
//  Created by H on 6/11/18.
//  Copyright © 2018 Fin. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    
    /// 帖子标题
    var topicTitleLabel: UILabel = {
        let topicTitleLabel=V2SpacingLabel();
        topicTitleLabel.textColor=V2EXColor.colors.v2_TopicListTitleColor;
        topicTitleLabel.font=v2Font(15);
        topicTitleLabel.numberOfLines=0;
        topicTitleLabel.preferredMaxLayoutWidth=SCREEN_WIDTH-24;
        return topicTitleLabel
    }()
    /// 日期 和 最后发送人
    var dateAndLastPostUserLabel: UILabel = {
        let dateAndLastPostUserLabel = UILabel();
        dateAndLastPostUserLabel.textColor=V2EXColor.colors.v2_TopicListDateColor;
        dateAndLastPostUserLabel.font=v2Font(12);
        return dateAndLastPostUserLabel
    }()
    //评论图标
    var replyCountIconImageView: UIImageView = {
        let replyCountIconImageView = UIImageView(image: UIImage(named: "reply_n"))
        replyCountIconImageView.contentMode = .scaleAspectFit
        return replyCountIconImageView
    }()
    /// 评论数量
    var replyCountLabel: UILabel = {
        let replyCountLabel = UILabel()
        replyCountLabel.textColor = V2EXColor.colors.v2_TopicListDateColor
        replyCountLabel.font = v2Font(12)
        return replyCountLabel
    }()
    /// 装上面定义的那些元素的容器
    var contentPanel:UIView = {
        let contentPanel = UIView();
        contentPanel.backgroundColor =  V2EXColor.colors.v2_CellWhiteBackgroundColor
        return contentPanel
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        self.setup();
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup()->Void{
        self.selectionStyle = .none
        self.backgroundColor = V2EXColor.colors.v2_backgroundColor
        
        self.contentView .addSubview(self.contentPanel);
        self.contentPanel.addSubview(self.dateAndLastPostUserLabel);
        self.contentPanel.addSubview(self.replyCountLabel);
        self.contentPanel.addSubview(self.replyCountIconImageView);
        self.contentPanel.addSubview(self.topicTitleLabel);
        
        self.setupLayout()
        
        self.dateAndLastPostUserLabel.backgroundColor = self.contentPanel.backgroundColor
        self.replyCountLabel.backgroundColor = self.contentPanel.backgroundColor
        self.replyCountIconImageView.backgroundColor = self.contentPanel.backgroundColor
        self.topicTitleLabel.backgroundColor = self.contentPanel.backgroundColor
    }
    
    func setupLayout(){
        self.contentPanel.snp.makeConstraints{ (make) -> Void in
            make.top.left.right.equalTo(self.contentView);
        }
        self.dateAndLastPostUserLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(self.contentPanel).offset(12);
            make.left.equalTo(self.contentPanel).offset(12);
        }
        self.replyCountLabel.snp.makeConstraints{ (make) -> Void in
            make.centerY.equalTo(self.dateAndLastPostUserLabel);
            make.right.equalTo(self.contentPanel).offset(-12);
        }
        self.replyCountIconImageView.snp.makeConstraints{ (make) -> Void in
            make.centerY.equalTo(self.replyCountLabel);
            make.width.height.equalTo(18);
            make.right.equalTo(self.replyCountLabel.snp.left).offset(-2);
        }
        self.topicTitleLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(self.dateAndLastPostUserLabel.snp.bottom).offset(12);
            make.left.equalTo(self.dateAndLastPostUserLabel);
            make.right.equalTo(self.contentPanel).offset(-12);
        }
        self.contentPanel.snp.makeConstraints{ (make) -> Void in
            make.bottom.equalTo(self.topicTitleLabel.snp.bottom).offset(12);
            make.bottom.equalTo(self.contentView).offset(SEPARATOR_HEIGHT * -1);
        }
    }
    
    func bind(_ model:SearchModel){
        self.dateAndLastPostUserLabel.text = model.author! + " • " + model.date!
        self.topicTitleLabel.text = model.title
        self.replyCountLabel.text = model.replies?.description
    }


}
