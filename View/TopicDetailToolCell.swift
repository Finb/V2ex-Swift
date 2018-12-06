//
//  TopicDetailToolCell.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2018/12/6.
//  Copyright © 2018 Fin. All rights reserved.
//

import UIKit

class TopicDetailToolCell: BaseDetailTableViewCell {
    let sortButton:V2HitTestSlopButton = {
        let btn = V2HitTestSlopButton()
        btn.titleLabel?.font = v2Font(12)
        btn.setTitleColor(V2EXColor.colors.v2_TopicListTitleColor, for: .normal)
        btn.hitTestSlop = UIEdgeInsetsMake(-10, -10, -10, -10)
        return btn
    }()
    var sortButtonClick:((_ sender:UIButton) -> Void)?
    override func setup() {
        super.setup()
        
        self.detailMarkHidden = true
        self.titleLabel.font = v2Font(12)
        self.backgroundColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
        self.separator.image = createImageWithColor(V2EXColor.colors.v2_backgroundColor)
        
        self.contentView.addSubview(sortButton)
        sortButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
        }
        
        self.sortButton.addTarget(self, action: #selector(sortClick(sender:)), for: .touchUpInside)
    }
    
    @objc func sortClick(sender:UIButton){
        sortButtonClick?(sender)
    }
}
