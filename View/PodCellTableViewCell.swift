//
//  PodCellTableViewCell.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2/23/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

class PodCellTableViewCell: BaseDetailTableViewCell {
    
    var descriptionLabel:UILabel = {
        let label =  V2SpacingLabel()
        label.font = v2Font(13)
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = SCREEN_WIDTH - 42
        label.textColor = V2EXColor.colors.v2_TopicListUserNameColor
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = V2EXColor.colors.v2_backgroundColor
        self.contentView.addSubview(self.descriptionLabel)
        self.setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupLayout() {
        self.titleLabel.snp_remakeConstraints{ (make) -> Void in
            make.left.top.equalTo(self.contentView).offset(12)
        }
        self.descriptionLabel.snp_makeConstraints{ (make) -> Void in
            make.left.equalTo(self.titleLabel)
            make.right.equalTo(self.contentView).offset(-30)
            make.top.equalTo(self.titleLabel.snp_bottom)
        }
        self.contentView.snp_makeConstraints{ (make) -> Void in
            make.left.top.right.equalTo(self);
            make.bottom.equalTo(self.descriptionLabel).offset(8);
        }
    }
}
