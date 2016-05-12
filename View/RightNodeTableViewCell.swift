//
//  RightNodeTableViewCell.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/23/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

class RightNodeTableViewCell: UITableViewCell {

    var nodeNameLabel: UILabel?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        self.setup();
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func setup()->Void{
        self.selectionStyle = .None
        self.backgroundColor = UIColor.clearColor()
        
        let panel = UIView()
        self.contentView.addSubview(panel)
        panel.snp_makeConstraints{ (make) -> Void in
            make.left.top.right.equalTo(self.contentView)
            make.bottom.equalTo(self.contentView).offset(-1 * SEPARATOR_HEIGHT)
        }
        
        self.nodeNameLabel = UILabel()
        self.nodeNameLabel!.font = v2Font(15)
        panel.addSubview(self.nodeNameLabel!)
        self.nodeNameLabel!.snp_makeConstraints{ (make) -> Void in
            make.right.equalTo(panel).offset(-22)
            make.centerY.equalTo(panel)
        }
        self.thmemChangedHandler = {[weak self] (style) -> Void in
            panel.backgroundColor = V2EXColor.colors.v2_LeftNodeBackgroundColor
            self?.nodeNameLabel!.textColor = V2EXColor.colors.v2_LeftNodeTintColor
        }
    }


}
