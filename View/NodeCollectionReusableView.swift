//
//  NodeCollectionReusableView.swift
//  V2ex-Swift
//
//  Created by huangfeng on 16/4/5.
//  Copyright © 2016年 Fin. All rights reserved.
//

import UIKit

class NodeCollectionReusableView: UICollectionReusableView {
    var label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = V2EXColor.colors.v2_backgroundColor
        
        label.font = v2Font(16)
        label.textColor = V2EXColor.colors.v2_TopicListTitleColor
        label.backgroundColor = V2EXColor.colors.v2_backgroundColor
        self.addSubview(label);
        
        label.snp_makeConstraints{ (make) -> Void in
            make.centerY.equalTo(self)
            make.left.equalTo(self).offset(15)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
