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
    var panel = UIView()
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
        
        self.contentView.addSubview(panel)
        panel.snp_makeConstraints{ (make) -> Void in
            make.left.top.right.equalTo(self.contentView)
            make.height.equalTo(55)
        }
        
        self.nodeImageView = UIImageView()
        panel.addSubview(self.nodeImageView!)
        self.nodeImageView!.snp_makeConstraints{ (make) -> Void in
            make.centerY.equalTo(panel)
            make.left.equalTo(panel).offset(20)
            make.width.height.equalTo(25)
        }
        
        self.nodeNameLabel = UILabel()
        self.nodeNameLabel!.font = v2Font(16)
        panel.addSubview(self.nodeNameLabel!)
        self.nodeNameLabel!.snp_makeConstraints{ (make) -> Void in
            make.left.equalTo(self.nodeImageView!.snp_right).offset(20)
            make.centerY.equalTo(self.nodeImageView!)
        }
        
        self.KVOController.observe(V2EXColor.sharedInstance, keyPath: "style", options: [.Initial,.New]) {[weak self] (obj, color, change) -> Void in
            self?.configureColor()
        }
        
    }
    func configureColor(){
        self.panel.backgroundColor = V2EXColor.colors.v2_LeftNodeBackgroundColor
        self.nodeImageView!.tintColor =  V2EXColor.colors.v2_LeftNodeTintColor
        self.nodeNameLabel!.textColor = V2EXColor.colors.v2_LeftNodeTintColor
    }
}


class LeftNotifictionCell : LeftNodeTableViewCell{
    var notifictionCountLabel:UILabel = UILabel()
    override func setup() {
        super.setup()
        self.nodeNameLabel!.text = "消息提醒"
        self.notifictionCountLabel.font = v2Font(10)
        self.notifictionCountLabel.textColor = UIColor.whiteColor()
        self.notifictionCountLabel.layer.cornerRadius = 7
        self.notifictionCountLabel.layer.masksToBounds = true
        self.notifictionCountLabel.backgroundColor = V2EXColor.colors.v2_NoticePointColor
        self.contentView.addSubview(self.notifictionCountLabel)
        self.notifictionCountLabel.snp_makeConstraints{ (make) -> Void in
            make.centerY.equalTo(self.nodeNameLabel!)
            make.left.equalTo(self.nodeNameLabel!.snp_right).offset(5)
            make.height.equalTo(14)
        }
        
        self.KVOController.observe(V2Client.sharedInstance, keyPath: "notificationCount", options: [.Initial,.New]) {  [weak self](cell, clien, change) -> Void in
            if V2Client.sharedInstance.notificationCount > 0 {
                self?.notifictionCountLabel.text = "   \(V2Client.sharedInstance.notificationCount)   "
            }
            else{
                self?.notifictionCountLabel.text = ""
            }
        }
    }
    
}