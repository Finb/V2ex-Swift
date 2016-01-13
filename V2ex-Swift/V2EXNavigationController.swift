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
        
//        self.navigationBar .setBackgroundImage(createImageWithColor(UIColor.clearColor()), forBarMetrics: .Default)
//        let darkBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
//        self.navigationBar .insertSubview(darkBlurView, atIndex: 0);
//        darkBlurView.backgroundColor=UIColor(white: 0.4, alpha: 0.8)
//        darkBlurView.snp_makeConstraints{ (make) -> Void in
//            make.top.equalTo(darkBlurView.superview!).offset(-20);
//            make.right.leading.equalTo(darkBlurView.superview!);
//            make.height.equalTo(64);
//        }
        
        self.navigationBar.titleTextAttributes = [
            NSFontAttributeName : UIFont(name: "HelveticaNeue-Bold", size: 20)!,
            NSForegroundColorAttributeName : V2EXColor.colors.v2_TopicListTitleColor
        ]
    }
}
