//
//  NodeTableViewCell.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2/2/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

class NodeTableViewCell: UICollectionViewCell {
    var textLabel = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
        
        textLabel.font = v2Font(15)
        textLabel.textColor = V2EXColor.colors.v2_TopicListUserNameColor
        textLabel.backgroundColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
        self.contentView.addSubview(textLabel)
        
        textLabel.snp_remakeConstraints(closure: { (make) -> Void in
            make.center.equalTo(self.contentView)
        })

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
