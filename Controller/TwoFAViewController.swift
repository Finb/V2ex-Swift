//
//  TwoFAViewController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2017/2/7.
//  Copyright © 2017年 Fin. All rights reserved.
//

import UIKit

class TwoFAViewController: UIViewController ,UITextFieldDelegate{

    let backgroundImageView = UIImageView()
    let frostedView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    let cancelButton = UIButton()
    let codeTextField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupView()
        self.hideKeyboardWhenTappedAround()
        
        self.cancelButton.addTarget(self, action: #selector(cancelClick), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 2, animations: { () -> Void in
            self.backgroundImageView.alpha=1;
        })
        UIView.animate(withDuration: 20, animations: { () -> Void in
            self.backgroundImageView.frame = CGRect(x: -1*( 1000 - SCREEN_WIDTH )/2, y: 0, width: SCREEN_HEIGHT+500, height: SCREEN_HEIGHT+500);
        })
        automaticFill()
        self.codeTextField.becomeFirstResponder()
    }

    @objc func cancelClick (){
        V2User.sharedInstance.loginOut()
        self.dismiss(animated: true, completion: nil)
    }
    
    func next(){
        if let code = self.codeTextField.text , code.Lenght == 6 {
            V2BeginLoading()
            UserModel.twoFALogin(code: code , completionHandler: { (success) in
                if success {
                    V2EndLoading()
                    self.dismiss(animated: true, completion: nil)
                }
                else{
                    V2Error("验证失败，请重试");
                }
            })
        }
        else{
            V2Inform("请填写正确的6位数验证码")
        }
    }

    @objc func applicationWillEnterForeground(){
        automaticFill()
    }
    
    func automaticFill(){
        if let pasteString = UIPasteboard.general.string {
            if(isCode(code: pasteString)){
                self.codeTextField.text = pasteString;
                next()
            }
        }
    }
    //判断一个字符串 是不是 6位数纯数字 验证码
    func isCode(code:String) -> Bool{
        guard code.Lenght == 6 else {
            return false
        }
        for c in code {
            if c > "9" && c < "0" {
                return false
            }
        }
        return true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension TwoFAViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.next()
        return true
    }
}

//MARK: - 初始化界面
extension TwoFAViewController {
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
        v2exLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 25)!;
        v2exLabel.text = "两步验证"
        vibrancyView.contentView.addSubview(v2exLabel);
        v2exLabel.snp.makeConstraints{ (make) -> Void in
            make.centerX.equalTo(vibrancyView)
            make.top.equalTo(vibrancyView).offset(80)
        }
        
        let v2exSummaryLabel = UILabel()
        v2exSummaryLabel.font = v2Font(11);
        v2exSummaryLabel.text = "你的 V2EX 账号已经开启了两步验证,请输入验证码继续"
        vibrancyView.contentView.addSubview(v2exSummaryLabel);
        v2exSummaryLabel.snp.makeConstraints{ (make) -> Void in
            make.centerX.equalTo(vibrancyView)
            make.top.equalTo(v2exLabel.snp.bottom).offset(10)
        }
        
        self.codeTextField.delegate = self
        self.codeTextField.textColor = UIColor.white
        self.codeTextField.backgroundColor = UIColor(white: 1, alpha: 0.1);
        self.codeTextField.font = v2Font(15)
        self.codeTextField.layer.cornerRadius = 3;
        self.codeTextField.layer.borderWidth = 0.5
        self.codeTextField.keyboardType = .numbersAndPunctuation
        self.codeTextField.layer.borderColor = UIColor(white: 1, alpha: 0.8).cgColor;
        self.codeTextField.placeholder = "验证码"
        self.codeTextField.clearButtonMode = .always
        
        let passwordIconImageView = UIImageView(image: UIImage(named: "ic_lock")!.withRenderingMode(.alwaysTemplate));
        passwordIconImageView.frame = CGRect(x: 0, y: 0, width: 34, height: 22)
        passwordIconImageView.contentMode = .scaleAspectFit
        self.codeTextField.leftView = passwordIconImageView
        self.codeTextField.leftViewMode = .always
        
        vibrancyView.contentView.addSubview(self.codeTextField);
        
        self.codeTextField.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(v2exSummaryLabel.snp.bottom).offset(15)
            make.centerX.equalTo(vibrancyView)
            make.width.equalTo(300)
            make.height.equalTo(38)
        }
        
        let noticeLabel = UILabel()
        noticeLabel.alpha = 0.5
        noticeLabel.font = v2Font(10)
        noticeLabel.text = "提示: 可在 Authenticator 中复制验证码，返回V2EX将自动填写"
        
        vibrancyView.contentView.addSubview(noticeLabel);
        
        noticeLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(self.codeTextField.snp.bottom).offset(10)
            make.left.equalTo(self.codeTextField)
        }

        
        
        let footLabel = UILabel()
        footLabel.alpha = 0.5
        footLabel.font = v2Font(12)
        footLabel.text = "© 2018 Fin"
        
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
