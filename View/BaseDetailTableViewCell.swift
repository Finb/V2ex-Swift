//
//  BaseDetailTableViewCell.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/21/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

class BaseDetailTableViewCell: UITableViewCell {
    var titleLabel:UILabel = {
        let label = UILabel()
        label.font = v2Font(16)
        return label
    }()
    
    var detailLabel:UILabel = {
        let label = UILabel()
        label.font = v2Font(13)
        return label
    }()
    
    var detailMarkImageView:UIImageView = {
        let imageview = UIImageView(image: UIImage.imageUsedTemplateMode("ic_keyboard_arrow_right"))
        imageview.contentMode = .center
        return imageview
    }()
    
    var separator:UIImageView = UIImageView()
    
    var detailMarkHidden:Bool {
        get{
            return self.detailMarkImageView.isHidden
        }
        
        set{
            if self.detailMarkImageView.isHidden == newValue{
                return ;
            }
            
            self.detailMarkImageView.isHidden = newValue
            if newValue {
                self.detailMarkImageView.snp.remakeConstraints{ (make) -> Void in
                    make.width.height.equalTo(0)
                    make.centerY.equalTo(self.contentView)
                    make.right.equalTo(self.contentView).offset(-12)
                }
            }
            else{
                self.detailMarkImageView.snp.remakeConstraints{ (make) -> Void in
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
        let selectedBackgroundView = UIView()
        self.selectedBackgroundView = selectedBackgroundView

        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.detailMarkImageView);
        self.contentView.addSubview(self.detailLabel)
        self.contentView.addSubview(self.separator)
        
        
        self.titleLabel.snp.makeConstraints{ (make) -> Void in
            make.left.equalTo(self.contentView).offset(12)
            make.centerY.equalTo(self.contentView)
        }
        self.detailMarkImageView.snp.remakeConstraints{ (make) -> Void in
            make.height.equalTo(24)
            make.width.equalTo(14)
            make.centerY.equalTo(self.contentView)
            make.right.equalTo(self.contentView).offset(-12)
        }
        self.detailLabel.snp.makeConstraints{ (make) -> Void in
            make.right.equalTo(self.detailMarkImageView.snp.left).offset(-5)
            make.centerY.equalTo(self.contentView)
        }
        self.separator.snp.makeConstraints{ (make) -> Void in
            make.left.right.bottom.equalTo(self.contentView)
            make.height.equalTo(SEPARATOR_HEIGHT)
        }
        
        
        self.themeChangedHandler = {[weak self] (style) -> Void in
            self?.backgroundColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
            self?.selectedBackgroundView!.backgroundColor = V2EXColor.colors.v2_backgroundColor
            self?.titleLabel.textColor = V2EXColor.colors.v2_TopicListTitleColor
            self?.detailMarkImageView.tintColor = self?.titleLabel.textColor
            self?.detailLabel.textColor = V2EXColor.colors.v2_TopicListUserNameColor
            self?.separator.image = createImageWithColor( V2EXColor.colors.v2_SeparatorColor )
        }
    }
    
}
