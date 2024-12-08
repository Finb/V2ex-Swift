//
//  WritingViewController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/25/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import YYText


class WritingViewController: UIViewController ,UITextViewDelegate {

    var textView:UITextView = {
        let textView = UITextView()
        textView.scrollsToTop = false
        textView.backgroundColor = V2EXColor.colors.v2_TextViewBackgroundColor
        textView.font = v2Font(18)
        textView.textColor = V2EXColor.colors.v2_TopicListUserNameColor
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textView.keyboardAppearance = V2EXColor.sharedInstance.style == V2EXColor.V2EXColorStyleDefault ? .default : .dark;
        return textView
    }()
    var topicModel :TopicDetailModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "写东西"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(WritingViewController.leftClick))

        let rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        rightButton.contentMode = .center
        rightButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -20)
        rightButton.setImage(UIImage(named: "ic_send")!.withRenderingMode(.alwaysTemplate), for: .normal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        rightButton.addTarget(self, action: #selector(WritingViewController.rightClick), for: .touchUpInside)
        
        self.view.backgroundColor = V2EXColor.colors.v2_backgroundColor

        self.textView.delegate = self
        self.view.addSubview(self.textView)
        self.textView.snp.makeConstraints{ (make) -> Void in
            make.top.right.bottom.left.equalTo(self.view)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    @objc func keyboardWillChangeFrame(notification: Notification) {
        guard let bound = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        self.textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bound.size.height, right: 0)
    }
    @objc func leftClick (){
        self.dismiss(animated: true, completion: nil)
    }
    @objc func rightClick (){
        
    }

    func textViewDidChange(_ textView: UITextView) {
        if textView.text.Lenght == 0{
            textView.textColor = V2EXColor.colors.v2_TopicListUserNameColor
        }
    }
}

class ReplyingViewController:WritingViewController {
    var atSomeone:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("reply")
        if let atSomeone = self.atSomeone {
            let str = NSMutableAttributedString(string: atSomeone + " ")
            str.yy_font = self.textView.font
            str.yy_color = self.textView.textColor
            str.yy_setColor(colorWith255RGB(0, g: 132, b: 255), range: NSMakeRange(0, str.length - 1))
            str.yy_setAttribute("someoneEnd", value: 1, range:NSMakeRange(str.length - 1, 1))
            
            self.textView.attributedText = str
            
            self.textView.selectedRange = NSMakeRange(str.length, 0);
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.textView.becomeFirstResponder()
    }
    
    override func rightClick (){
        guard let text = self.textView.text, text.Lenght > 0 else {
            return
        }
        V2ProgressHUD.showWithClearMask()
        TopicCommentModel.replyWithTopicId(self.topicModel!, content: text ) {
            (response) in
            if response.success {
                V2Success("回复成功!")
                self.dismiss(animated: true, completion: nil)
            }
            else{
                V2Error(response.message)
            }
        }
    }
}
