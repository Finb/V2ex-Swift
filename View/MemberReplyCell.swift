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
    var detailLabel: UILabel?
    
    /// 回复正文
    var commentLabel: UILabel?
    
    /// 回复正文的背景容器
    var commentPanel: UIView?
    
    /// 整个cell元素的容器
    var contentPanel:UIView?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        self.setup();
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setup()->Void{
        self.selectionStyle = .None
        self.backgroundColor = V2EXColor.colors.v2_backgroundColor
        
        self.contentPanel = UIView();
        self.contentPanel!.backgroundColor =  V2EXColor.colors.v2_CellWhiteBackgroundColor
        self.contentView .addSubview(self.contentPanel!);
        self.contentPanel!.snp_makeConstraints{ (make) -> Void in
            make.top.left.right.equalTo(self.contentView);
        }
        
        self.detailLabel=V2SpacingLabel();
        self.detailLabel!.textColor=V2EXColor.colors.v2_TopicListTitleColor;
        self.detailLabel!.font=v2Font(14);
        self.detailLabel!.numberOfLines=0;
        self.detailLabel!.preferredMaxLayoutWidth=SCREEN_WIDTH-24;
        self.contentPanel?.addSubview(self.detailLabel!);
        self.detailLabel!.snp_makeConstraints{ (make) -> Void in
            make.top.equalTo(self.contentPanel!).offset(12);
            make.left.equalTo(self.contentPanel!).offset(12);
            make.right.equalTo(self.contentPanel!).offset(-12);
        }
        
        self.commentPanel = UIView()
        self.commentPanel!.layer.cornerRadius = 3
        self.commentPanel!.layer.masksToBounds = true
        self.commentPanel!.backgroundColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
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
        let dropUpImageView = UIImageView()
        dropUpImageView.image = UIImage.imageUsedTemplateMode("ic_arrow_drop_up")
        dropUpImageView.contentMode = .ScaleAspectFit
        dropUpImageView.tintColor = self.commentPanel!.backgroundColor
        self.contentPanel!.addSubview(dropUpImageView)
        dropUpImageView.snp_makeConstraints{ (make) -> Void in
            make.bottom.equalTo(self.commentPanel!.snp_top)
            make.left.equalTo(self.commentPanel!).offset(25)
            make.width.equalTo(10)
            make.height.equalTo(5)
        }
        
        self.contentPanel!.snp_makeConstraints{ (make) -> Void in
            make.bottom.equalTo(self.commentPanel!.snp_bottom).offset(12);
        }
        
        self.contentView.snp_makeConstraints{ (make) -> Void in
            make.left.top.right.equalTo(self);
            make.bottom.equalTo(self.contentPanel!).offset(0);
        }

    }
    func bind(model: MemberRepliesModel){
        if model.date != nil && model.title != nil {
            self.detailLabel?.text = model.date! + "回复 " + model.title!
        }
        self.commentLabel!.text = model.reply
    }

}
