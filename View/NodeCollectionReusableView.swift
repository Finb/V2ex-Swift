//
//  NodeCollectionReusableView.swift
//  V2ex-Swift
//
//  Created by huangfeng on 16/4/5.
//  Copyright © 2016年 Fin. All rights reserved.
//

import UIKit

class NodeCollectionReusableView: UICollectionReusableView {
    var label : UILabel = {
        let _label = UILabel()
        _label.font = v2Font(16)
        return _label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(label);
        
        label.snp.makeConstraints{ (make) -> Void in
            make.centerY.equalTo(self)
            make.left.equalTo(self).offset(15)
        }
        
        self.themeChangedHandler = {[weak self] _ in
            self?.backgroundColor = V2EXColor.colors.v2_backgroundColor
            self?.label.textColor = V2EXColor.colors.v2_TopicListTitleColor
            self?.label.backgroundColor = V2EXColor.colors.v2_backgroundColor
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
