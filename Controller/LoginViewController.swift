//
//  LoginViewController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/22/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import OnePasswordExtension
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


public typealias LoginSuccessHandel = (String) -> Void

class LoginViewController: UIViewController {

    var successHandel:LoginSuccessHandel?

    let backgroundImageView = UIImageView()
    let frostedView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    let userNameTextField = UITextField()
    let passwordTextField = UITextField()
    let loginButton = UIButton()
    let cancelButton = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()

        self.hideKeyboardWhenTappedAround()
        
        //初始化界面
        self.setupView()

        //初始化1Password
        if OnePasswordExtension.shared().isAppExtensionAvailable() {
            let onepasswordButton = UIImageView(image: UIImage(named: "onepassword-button")?.withRenderingMode(.alwaysTemplate))
            onepasswordButton.isUserInteractionEnabled = true
            onepasswordButton.frame = CGRect(x: 0, y: 0, width: 34, height: 22)
            onepasswordButton.contentMode = .scaleAspectFit
            onepasswordButton.tintColor = UIColor.white
            self.passwordTextField.rightView = onepasswordButton
            self.passwordTextField.rightViewMode = .always
            onepasswordButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LoginViewController.findLoginFrom1Password)))
        }

        //绑定事件
        self.loginButton.addTarget(self, action: #selector(LoginViewController.loginClick(_:)), for: .touchUpInside)
        self.cancelButton.addTarget(self, action: #selector(LoginViewController.cancelClick), for: .touchUpInside)
    }
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 2, animations: { () -> Void in
            self.backgroundImageView.alpha=1;
        }) 
        UIView.animate(withDuration: 20, animations: { () -> Void in
            self.backgroundImageView.frame = CGRect(x: -1*( 1000 - SCREEN_WIDTH )/2, y: 0, width: SCREEN_HEIGHT+500, height: SCREEN_HEIGHT+500);
        }) 
    }


    func findLoginFrom1Password(){
        OnePasswordExtension.shared().findLogin(forURLString: "v2ex.com", for: self, sender: nil) { (loginDictionary, errpr) -> Void in
            if loginDictionary?.count > 0 {
                self.userNameTextField.text = loginDictionary![AppExtensionUsernameKey] as? String
                self.passwordTextField.text = loginDictionary![AppExtensionPasswordKey] as? String

                //密码赋值后，点确认按钮
                self.loginClick(self.loginButton)
            }
        }
    }
    func cancelClick (){
        self.dismiss(animated: true, completion: nil)
    }
    func loginClick(_ sneder:UIButton){
        var userName:String?
        var password:String?
        if self.userNameTextField.text?.Lenght > 0{
            userName = self.userNameTextField.text! ;
        }
        else{
            self.userNameTextField.becomeFirstResponder()
            return;
        }

        if self.passwordTextField.text?.Lenght > 0  {
            password = self.passwordTextField.text!
        }
        else{
            self.passwordTextField.becomeFirstResponder()
            return;
        }
        V2BeginLoadingWithStatus("正在登录")
        UserModel.Login(userName!, password: password!){
            (response:V2ValueResponse<String>) -> Void in
            if response.success {
                V2Success("登录成功")
                let username = response.value!
                NSLog("登录成功 %@",username)
                //保存下用户名
                V2EXSettings.sharedInstance[kUserName] = username

                //将用户名密码保存进keychain （安全保存)
                V2UsersKeychain.sharedInstance.addUser(username, password: password!)

                //调用登录成功回调
                if let handel = self.successHandel {
                    handel(username)
                }

                //获取用户信息
                UserModel.getUserInfoByUsername(username,completionHandler: nil)
                self.dismiss(animated: true, completion: nil)
            }
            else{
                V2Error(response.message)
            }
        }
    }
}

//MARK: - 点击文本框外收回键盘
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

//MARK: - 初始化界面
extension LoginViewController {
    func setupView(){
        self.view.backgroundColor = UIColor.black

        self.backgroundImageView.image = UIImage(named: "32.jpg")
        self.backgroundImageView.frame = self.view.frame
        self.backgroundImageView.contentMode = .scaleToFill
        self.view.addSubview(self.backgroundImageView)
        backgroundImageView.alpha = 0

        self.frostedView.frame = self.view.frame
        self.view.addSubview(self.frostedView)

        let vibrancy = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .dark))
        let vibrancyView = UIVisualEffectView(effect: vibrancy)
        vibrancyView.isUserInteractionEnabled = true
        vibrancyView.frame = self.frostedView.frame
        self.frostedView.contentView.addSubview(vibrancyView)

        let v2exLabel = UILabel()
        v2exLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 32)!;
        v2exLabel.text = "V2EX"
        vibrancyView.contentView.addSubview(v2exLabel);
        v2exLabel.snp.makeConstraints{ (make) -> Void in
            make.centerX.equalTo(vibrancyView)
            make.top.equalTo(vibrancyView).offset(40)
        }

        let v2exSummaryLabel = UILabel()
        v2exSummaryLabel.font = v2Font(13);
        v2exSummaryLabel.text = "创意者的工作社区"
        vibrancyView.contentView.addSubview(v2exSummaryLabel);
        v2exSummaryLabel.snp.makeConstraints{ (make) -> Void in
            make.centerX.equalTo(vibrancyView)
            make.top.equalTo(v2exLabel.snp.bottom).offset(2)
        }

        self.userNameTextField.autocorrectionType = UITextAutocorrectionType.no
        self.userNameTextField.autocapitalizationType = UITextAutocapitalizationType.none
        
        self.userNameTextField.textColor = UIColor.white
        self.userNameTextField.backgroundColor = UIColor(white: 1, alpha: 0.1);
        self.userNameTextField.font = v2Font(15)
        self.userNameTextField.layer.cornerRadius = 3;
        self.userNameTextField.layer.borderWidth = 0.5
        self.userNameTextField.keyboardType = .asciiCapable
        self.userNameTextField.layer.borderColor = UIColor(white: 1, alpha: 0.8).cgColor;
        self.userNameTextField.placeholder = "用户名"
        self.userNameTextField.clearButtonMode = .always

        let userNameIconImageView = UIImageView(image: UIImage(named: "ic_account_circle")!.withRenderingMode(.alwaysTemplate));
        userNameIconImageView.frame = CGRect(x: 0, y: 0, width: 34, height: 22)
        userNameIconImageView.tintColor = UIColor.white
        userNameIconImageView.contentMode = .scaleAspectFit
        self.userNameTextField.leftView = userNameIconImageView
        self.userNameTextField.leftViewMode = .always

        vibrancyView.contentView.addSubview(self.userNameTextField);

        self.userNameTextField.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(v2exSummaryLabel.snp.bottom).offset(25)
            make.centerX.equalTo(vibrancyView)
            make.width.equalTo(300)
            make.height.equalTo(38)
        }

        self.passwordTextField.textColor = UIColor.white
        self.passwordTextField.backgroundColor = UIColor(white: 1, alpha: 0.1);
        self.passwordTextField.font = v2Font(15)
        self.passwordTextField.layer.cornerRadius = 3;
        self.passwordTextField.layer.borderWidth = 0.5
        self.passwordTextField.keyboardType = .asciiCapable
        self.passwordTextField.isSecureTextEntry = true
        self.passwordTextField.layer.borderColor = UIColor(white: 1, alpha: 0.8).cgColor;
        self.passwordTextField.placeholder = "密码"
        self.passwordTextField.clearButtonMode = .always

        let passwordIconImageView = UIImageView(image: UIImage(named: "ic_lock")!.withRenderingMode(.alwaysTemplate));
        passwordIconImageView.frame = CGRect(x: 0, y: 0, width: 34, height: 22)
        passwordIconImageView.contentMode = .scaleAspectFit
        userNameIconImageView.tintColor = UIColor.white
        self.passwordTextField.leftView = passwordIconImageView
        self.passwordTextField.leftViewMode = .always

        vibrancyView.contentView.addSubview(self.passwordTextField);

        self.passwordTextField.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(self.userNameTextField.snp.bottom).offset(15)
            make.centerX.equalTo(vibrancyView)
            make.width.equalTo(300)
            make.height.equalTo(38)
        }

        self.loginButton.setTitle("登  录", for: UIControlState())
        self.loginButton.titleLabel!.font = v2Font(20)
        self.loginButton.layer.cornerRadius = 3;
        self.loginButton.layer.borderWidth = 0.5
        self.loginButton.layer.borderColor = UIColor(white: 1, alpha: 0.8).cgColor;
        vibrancyView.contentView.addSubview(self.loginButton);

        self.loginButton.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(self.passwordTextField.snp.bottom).offset(20)
            make.centerX.equalTo(vibrancyView)
            make.width.equalTo(300)
            make.height.equalTo(38)
        }
        let forgetPasswordLabel = UILabel()
        forgetPasswordLabel.alpha = 0.5
        forgetPasswordLabel.font = v2Font(12)
        forgetPasswordLabel.text = "忘记密码了?"

        vibrancyView.contentView.addSubview(forgetPasswordLabel);

        forgetPasswordLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(self.loginButton.snp.bottom).offset(14)
            make.right.equalTo(self.loginButton)
        }

        let footLabel = UILabel()
        footLabel.alpha = 0.5
        footLabel.font = v2Font(12)
        footLabel.text = "© 2016 Fin"

        vibrancyView.contentView.addSubview(footLabel);

        footLabel.snp.makeConstraints{ (make) -> Void in
            make.bottom.equalTo(vibrancyView).offset(-20)
            make.centerX.equalTo(vibrancyView)
        }

        self.cancelButton.contentMode = .center
        cancelButton .setImage(UIImage(named: "ic_cancel")!.withRenderingMode(.alwaysTemplate), for: UIControlState())
        vibrancyView.contentView.addSubview(cancelButton)
        cancelButton.snp.makeConstraints{ (make) -> Void in
            make.centerY.equalTo(footLabel)
            make.right.equalTo(vibrancyView).offset(-5)
            make.width.height.equalTo(40)
        }
    }
}
