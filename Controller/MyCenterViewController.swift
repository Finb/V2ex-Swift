//
//  MyCenterViewController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2/7/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

class MyCenterViewController: MemberViewController {
    var settingsButton:UIButton?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.settingsButton = UIButton(frame: CGRectMake(0, 0, 40, 40))
        self.settingsButton!.contentMode = .Center
        self.settingsButton!.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -20)
        self.settingsButton!.setImage(UIImage.imageUsedTemplateMode("ic_supervisor_account")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.settingsButton!)
        self.settingsButton!.addTarget(self, action: Selector("accountManagerClick"), forControlEvents: .TouchUpInside)
        self.settingsButton!.hidden = true
    }
    
    override func getDataSuccessfully(aModel: MemberModel) {
        super.getDataSuccessfully(aModel)
        self.settingsButton!.hidden = false
    }
    
    func accountManagerClick(){
        self.navigationController?.pushViewController(AccountsManagerViewController(), animated: true)
    }
}
