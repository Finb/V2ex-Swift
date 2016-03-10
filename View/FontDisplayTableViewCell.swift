//
//  FontDisplayTableViewCell.swift
//  V2ex-Swift
//
//  Created by huangfeng on 3/10/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

class FontDisplayTableViewCell: BaseDetailTableViewCell {

    override func setup()->Void{
        super.setup()
        self.detailMarkHidden = true
        self.clipsToBounds = true
        self.titleLabel?.text = "一天，一匹小马驮着麦子去磨坊。当它驮着口袋向前跑去时，突然发现一条小河挡住了去路。小马为难了，这可怎么办呢？它向四周望了望，看见一头奶牛在河边吃草。\n\n One day, a colt took a bag of wheat to the mill. As he was running with the bag on his back, he came to a small river. The colt could not decide whether he could cross it. Looking around, he saw a cow grazing nearby."
        self.titleLabel?.numberOfLines = 0
        self.titleLabel?.preferredMaxLayoutWidth = SCREEN_WIDTH - 24
        self.titleLabel?.baselineAdjustment = .None
        
        self.titleLabel!.snp_remakeConstraints{ (make) -> Void in
            make.left.top.equalTo(self.contentView).offset(12)
            make.right.equalTo(self.contentView).offset(-12)
            make.height.lessThanOrEqualTo(self.contentView).offset(-12)
        }
        
        self.KVOController.observe(V2Style.sharedInstance, keyPath: "fontScale", options: [.Initial,.New]) {_ in
            self.titleLabel?.font = v2ScaleFont(14)
        }
    }
}
