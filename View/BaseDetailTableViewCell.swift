//
//  BaseDetailTableViewCell.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/21/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

class BaseDetailTableViewCell: UITableViewCell {
    var titleLabel:UILabel?
    var detailLabel:UILabel?
    var detailMarkImageView:UIImageView?
    
    var detailMarkHidden:Bool {
        get{
            if let mark = self.detailMarkImageView {
                return mark.hidden
            }
            return false
        }
        
        set{
            if self.detailMarkImageView?.hidden == newValue{
                return ;
            }
            
            self.detailMarkImageView?.hidden = newValue
            if newValue {
                self.detailMarkImageView!.snp_remakeConstraints{ (make) -> Void in
                    make.width.height.equalTo(0)
                    make.centerY.equalTo(self.contentView)
                    make.right.equalTo(self.contentView).offset(-12)
                }
            }
            else{
                self.detailMarkImageView!.snp_remakeConstraints{ (make) -> Void in
                    make.width.height.equalTo(20)
                    make.centerY.equalTo(self.contentView)
                    make.right.equalTo(self.contentView).offset(-12)
                }
            }
        }
        
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        self.setup();
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup()->Void{
        self.titleLabel = UILabel()
        self.titleLabel!.font = v2Font(14)
        self.titleLabel!.textColor = V2EXColor.colors.v2_TopicListTitleColor
        self.contentView .addSubview(self.titleLabel!)
        self.titleLabel!.snp_makeConstraints{ (make) -> Void in
            make.left.equalTo(self.contentView).offset(12)
            make.centerY.equalTo(self.contentView)
        }
        
        self.detailMarkImageView = UIImageView()
        self.detailMarkImageView!.backgroundColor = UIColor.redColor();
        self.contentView.addSubview(self.detailMarkImageView!);
        self.detailMarkImageView!.snp_remakeConstraints{ (make) -> Void in
            make.width.height.equalTo(20)
            make.centerY.equalTo(self.contentView)
            make.right.equalTo(self.contentView).offset(-12)
        }
        
        self.detailLabel = UILabel()
        self.detailLabel!.font = v2Font(14)
        self.detailLabel!.textColor = V2EXColor.colors.v2_TopicListUserNameColor
        self.contentView .addSubview(self.detailLabel!)
        self.detailLabel!.snp_makeConstraints{ (make) -> Void in
            make.right.equalTo(self.detailMarkImageView!.snp_left).offset(-5)
            make.centerY.equalTo(self.contentView)
        }
    }
    
}
