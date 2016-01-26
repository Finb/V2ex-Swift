//
//  V2EXNavigationController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/13/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit



class V2EXNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true);
        

        self.navigationBar.tintColor = V2EXColor.colors.v2_TopicListUserNameColor
        
        self.navigationBar.titleTextAttributes = [
            NSFontAttributeName : v2Font(18),
            NSForegroundColorAttributeName : V2EXColor.colors.v2_TopicListTitleColor
        ]
        
        self.navigationBar.setBackgroundImage(createImageWithColor(UIColor.clearColor()), forBarMetrics: .Default)
        
        let maskingView = UIView()
        maskingView.userInteractionEnabled = false
        maskingView.backgroundColor = UIColor(white: 0, alpha: 0.0);
        self.navigationBar.insertSubview(maskingView, atIndex: 0);

        maskingView.snp_makeConstraints{ (make) -> Void in
            make.left.bottom.right.equalTo(maskingView.superview!)
            make.top.equalTo(maskingView.superview!).offset(-20);
        }
        
        let frostedView = UIToolbar()
        frostedView.userInteractionEnabled = false
        frostedView.barStyle = .Default
        maskingView.addSubview(frostedView);
        
        frostedView.snp_makeConstraints{ (make) -> Void in
            make.top.bottom.left.right.equalTo(maskingView);
        }
    }
}
