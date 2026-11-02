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
    /// iOS 27 下 UIToolbar 会强制使用液态玻璃效果，这里改用 UIVisualEffectView
    var frostedView:UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
    /// navigationBar 阴影
    var shadowImage:UIImage?
    /// navigationBar 背景透明度
    var navigationBarAlpha:CGFloat {
        get{
            return  self.frostedView.superview?.alpha ?? 0
        }
        set {
            var value = newValue
            if newValue > 1 {
                value = 1
            }
            else if value < 0 {
                value = 0
            }
            self.frostedView.superview?.alpha = newValue
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
    override var preferredStatusBarStyle: UIStatusBarStyle{
        get {
            if V2EXColor.sharedInstance.style == V2EXColor.V2EXColorStyleDefault {
                if #available(iOS 13.0, *) {
                    return .darkContent
                } else {
                    return .default
                }
            }
            else{
                return .lightContent
            }
        }
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .fullScreen
    }
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        self.modalPresentationStyle = .fullScreen
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        // iOS 26 起系统返回按钮默认带有液态玻璃背景，用自定义返回按钮替代
        if let topViewController = self.topViewController {
            viewController.navigationItem.leftBarButtonItem = makeBackButtonItem(title: topViewController.title)
        }
        super.pushViewController(viewController, animated: animated)
    }

    private func makeBackButtonItem(title: String?) -> UIBarButtonItem {
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.backward")?.withRenderingMode(.alwaysTemplate), for: .normal)
        backButton.setTitle(title, for: .normal)
        backButton.titleLabel?.font = v2Font(17)
        backButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: 2)
        backButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: -2)
        backButton.addTarget(self, action: #selector(customBackButtonTapped), for: .touchUpInside)
        backButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        backButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        return UIBarButtonItem(customView: backButton).hidingGlassBackground()
    }

    @objc private func customBackButtonTapped() {
        self.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .light
        }
        self.navigationBar.setBackgroundImage(createImageWithColor(UIColor.clear), for: .default)

        let maskingView = UIView()
        
        maskingView.isUserInteractionEnabled = false
        self.navigationBar.superview!.insertSubview(maskingView, belowSubview: self.navigationBar)
        maskingView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: NavigationBarHeight)
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

        self.themeChangedHandler = {[weak self] (style) -> Void in
            self?.navigationBar.tintColor = V2EXColor.colors.v2_navigationBarTintColor
            
            self?.navigationBar.titleTextAttributes = [
                NSAttributedString.Key.font : v2Font(18),
                NSAttributedString.Key.foregroundColor : V2EXColor.colors.v2_TopicListTitleColor
            ]
            
            if V2EXColor.sharedInstance.style == V2EXColor.V2EXColorStyleDefault {
                maskingView.backgroundColor = UIColor(white: 0, alpha: 0.0);
                self?.frostedView.overrideUserInterfaceStyle = .light
                
                //全局键盘颜色
                UITextField.appearance().keyboardAppearance = .light
                
            }
            else{
                maskingView.backgroundColor = UIColor(white: 0, alpha: 0.6);
                self?.frostedView.overrideUserInterfaceStyle = .dark
                
                UITextField.appearance().keyboardAppearance = .dark
            }
            
            self?.setNeedsStatusBarAppearanceUpdate()
        }
    }
}
