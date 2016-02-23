//
//  PodCellTableViewCell.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2/23/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

class PodCellTableViewCell: BaseDetailTableViewCell {
    
    var descriptionLabel:UILabel?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = V2EXColor.colors.v2_backgroundColor
        
        
        self.titleLabel!.snp_remakeConstraints{ (make) -> Void in
            make.left.top.equalTo(self.contentView).offset(12)
        }
        self.descriptionLabel = V2SpacingLabel()
        self.descriptionLabel!.font = v2Font(13)
        self.descriptionLabel!.numberOfLines = 0
        self.descriptionLabel!.preferredMaxLayoutWidth = SCREEN_WIDTH - 42
        self.descriptionLabel!.textColor = V2EXColor.colors.v2_TopicListUserNameColor
        self.contentView .addSubview(self.descriptionLabel!)
        self.descriptionLabel!.snp_makeConstraints{ (make) -> Void in
            make.left.equalTo(self.titleLabel!)
            make.right.equalTo(self.contentView).offset(-30)
            make.top.equalTo(self.titleLabel!.snp_bottom)
        }
        self.contentView.snp_makeConstraints{ (make) -> Void in
            make.left.top.right.equalTo(self);
            make.bottom.equalTo(self.descriptionLabel!).offset(8);
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
