//
//  LeftNodeTableViewCell.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/23/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

class LeftNodeTableViewCell: UITableViewCell {
    
    var nodeImageView: UIImageView?
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
        panel.backgroundColor = UIColor(white: 1, alpha: 0.3)
        self.contentView.addSubview(panel)
        panel.snp_makeConstraints{ (make) -> Void in
            make.left.top.right.equalTo(self.contentView)
            make.height.equalTo(55)
        }
        
        self.nodeImageView = UIImageView()
        self.nodeImageView!.backgroundColor = UIColor(white: 0, alpha: 0.1)
        panel.addSubview(self.nodeImageView!)
        self.nodeImageView!.snp_makeConstraints{ (make) -> Void in
            make.centerY.equalTo(panel)
            make.left.equalTo(panel).offset(25)
            make.width.height.equalTo(25)
        }
        
        self.nodeNameLabel = UILabel()
        self.nodeNameLabel!.font = v2Font(16)
        self.nodeNameLabel!.textColor = V2EXColor.colors.v2_TopicListUserNameColor
        panel.addSubview(self.nodeNameLabel!)
        self.nodeNameLabel!.snp_makeConstraints{ (make) -> Void in
            make.left.equalTo(self.nodeImageView!.snp_right).offset(25)
            make.centerY.equalTo(self.nodeImageView!)
        }
    }
}
