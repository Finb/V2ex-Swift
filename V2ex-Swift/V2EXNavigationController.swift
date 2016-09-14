//
//  V2EXNavigationController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/13/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

import YYText

class V2EXNavigationController: UINavigationController {
    
    /// 毛玻璃效果的 navigationBar 背景
    var frostedView:UIToolbar = UIToolbar()
    /// navigationBar 阴影
    var shadowImage:UIImage?
    /// navigationBar 背景透明度
    var navigationBarAlpha:CGFloat {
        get{
            return  self.frostedView.alpha
        }
        set {
            var value = newValue
            if newValue > 1 {
                value = 1
            }
            else if value < 0 {
                value = 0
            }
            self.frostedView.alpha = newValue
            if(value == 1){
                if self.navigationBar.shadowImage != nil{
                    self.navigationBar.shadowImage = nil
                }
            }
            else {
                if self.navigationBar.shadowImage == nil{
                    self.navigationBar.shadowImage = UIImage()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true);
        self.navigationBar.setBackgroundImage(createImageWithColor(UIColor.clearColor()), forBarMetrics: .Default)

        let maskingView = UIView()
        maskingView.userInteractionEnabled = false
        maskingView.backgroundColor = UIColor(white: 0, alpha: 0.0);
        self.navigationBar.superview!.insertSubview(maskingView, belowSubview: self.navigationBar)
        maskingView.snp_makeConstraints{ (make) -> Void in
            make.left.bottom.right.equalTo(self.navigationBar)
            make.top.equalTo(self.navigationBar).offset(-20);
        }

        self.frostedView.userInteractionEnabled = false
        self.frostedView.clipsToBounds = true
        maskingView.addSubview(self.frostedView);
        self.frostedView.snp_makeConstraints{ (make) -> Void in
            make.top.bottom.left.right.equalTo(maskingView);
        }

        self.thmemChangedHandler = {[weak self] (style) -> Void in
            self?.navigationBar.tintColor = V2EXColor.colors.v2_navigationBarTintColor
            
            self?.navigationBar.titleTextAttributes = [
                NSFontAttributeName : v2Font(18),
                NSForegroundColorAttributeName : V2EXColor.colors.v2_TopicListTitleColor
            ]
            
            if V2EXColor.sharedInstance.style == V2EXColor.V2EXColorStyleDefault {
                self?.frostedView.barStyle = .Default
                UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true);
                
                //全局键盘颜色
                UITextView.appearance().keyboardAppearance = .Light
                UITextField.appearance().keyboardAppearance = .Light
                YYTextView.appearance().keyboardAppearance = .Light
                
            }
            else{
                self?.frostedView.barStyle = .Black
                UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true);
                
                UITextView.appearance().keyboardAppearance = .Dark
                UITextField.appearance().keyboardAppearance = .Dark
                YYTextView.appearance().keyboardAppearance = .Dark
            }
        }
    }
}
