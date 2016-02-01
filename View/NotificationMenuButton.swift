//
//  NotificationButton.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2/1/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

class NotificationMenuButton: UIButton {
    var aPointImageView:UIImageView?
    required init(){
        super.init(frame: CGRectZero)
        self.contentMode = .Center
        self.imageEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0)
        self.setImage(UIImage.imageUsedTemplateMode("ic_menu_36pt")!, forState: .Normal)
        
        self.aPointImageView = UIImageView()
        self.aPointImageView!.backgroundColor = colorWith255RGB(207, g: 70, b: 71)
        self.aPointImageView!.layer.cornerRadius = 4
        self.aPointImageView!.layer.masksToBounds = true
        self.addSubview(self.aPointImageView!)
        self.aPointImageView!.snp_makeConstraints{ (make) -> Void in
            make.width.height.equalTo(8)
            make.top.equalTo(self).offset(3)
            make.right.equalTo(self).offset(-6)
        }
        
        self.KVOController.observe(V2Client.sharedInstance, keyPath: "notificationCount", options: [.Initial,.New]) {  [weak self](cell, clien, change) -> Void in
            if V2Client.sharedInstance.notificationCount > 0 {
                self?.aPointImageView!.hidden = false
            }
            else{
                self?.aPointImageView!.hidden = true
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
