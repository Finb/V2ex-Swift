//
//  RightNodeTableViewCell.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/23/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

class RightNodeTableViewCell: UITableViewCell {

    var nodeNameLabel: UILabel = {
        let label = UILabel()
        label.font = v2Font(15)
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        self.setup();
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func setup()->Void{
        self.selectionStyle = .none
        self.backgroundColor = UIColor.clear
        
        let panel = UIView()
        self.contentView.addSubview(panel)
        panel.snp_makeConstraints{ (make) -> Void in
            make.left.top.right.equalTo(self.contentView)
            make.bottom.equalTo(self.contentView).offset(-1 * SEPARATOR_HEIGHT)
        }
        
        panel.addSubview(self.nodeNameLabel)
        self.nodeNameLabel.snp_makeConstraints{ (make) -> Void in
            make.right.equalTo(panel).offset(-22)
            make.centerY.equalTo(panel)
        }
        
        self.thmemChangedHandler = {[weak self] (style) -> Void in
            panel.backgroundColor = V2EXColor.colors.v2_LeftNodeBackgroundColor
            self?.nodeNameLabel.textColor = V2EXColor.colors.v2_LeftNodeTintColor
        }
    }


}
