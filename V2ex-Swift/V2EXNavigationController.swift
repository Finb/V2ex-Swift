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
        UIApplication.shared.setStatusBarStyle(.default, animated: true);
        self.navigationBar.setBackgroundImage(createImageWithColor(UIColor.clear), for: .default)

        let maskingView = UIView()
        
        maskingView.isUserInteractionEnabled = false
        maskingView.backgroundColor = UIColor(white: 0, alpha: 0.0);
        self.navigationBar.superview!.insertSubview(maskingView, belowSubview: self.navigationBar)
        maskingView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: NavagationBarHeight)
//        maskingView.snp.makeConstraints{ (make) -> Void in
//            make.left.bottom.right.equalTo(self.navigationBar)
//            make.top.equalTo(self.navigationBar).offset(-44);
//        }

        self.frostedView.isUserInteractionEnabled = false
        self.frostedView.clipsToBounds = true
        maskingView.addSubview(self.frostedView);
        self.frostedView.snp.makeConstraints{ (make) -> Void in
            make.top.bottom.left.right.equalTo(maskingView);
        }

        self.thmemChangedHandler = {[weak self] (style) -> Void in
            self?.navigationBar.tintColor = V2EXColor.colors.v2_navigationBarTintColor
            
            self?.navigationBar.titleTextAttributes = [
                NSAttributedStringKey.font : v2Font(18),
                NSAttributedStringKey.foregroundColor : V2EXColor.colors.v2_TopicListTitleColor
            ]
            
            if V2EXColor.sharedInstance.style == V2EXColor.V2EXColorStyleDefault {
                self?.frostedView.barStyle = .default
                UIApplication.shared.setStatusBarStyle(.default, animated: true);
                
                //全局键盘颜色
                UITextView.appearance().keyboardAppearance = .light
                UITextField.appearance().keyboardAppearance = .light
                YYTextView.appearance().keyboardAppearance = .light
                
            }
            else{
                self?.frostedView.barStyle = .black
                UIApplication.shared.setStatusBarStyle(.lightContent, animated: true);
                
                UITextView.appearance().keyboardAppearance = .dark
                UITextField.appearance().keyboardAppearance = .dark
                YYTextView.appearance().keyboardAppearance = .dark
            }
        }
    }
}
