//
//  WritingViewController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/25/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

import YYText

import SVProgressHUD

class WritingViewController: UIViewController ,YYTextViewDelegate {

    var textView:YYTextView?
    var topicModel :TopicDetailModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "写东西"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .Plain, target: self, action: Selector("leftClick"))

        let rightButton = UIButton(frame: CGRectMake(0, 0, 40, 40))
        rightButton.contentMode = .Center
        rightButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -20)
        rightButton.setImage(UIImage(named: "ic_send")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        rightButton.addTarget(self, action: Selector("rightClick"), forControlEvents: .TouchUpInside)
        
        self.view.backgroundColor = V2EXColor.colors.v2_backgroundColor
        self.textView = YYTextView()
        self.textView!.scrollsToTop = false
        self.textView!.backgroundColor = V2EXColor.colors.v2_TextViewBackgroundColor
        self.textView!.font = v2Font(18)
        self.textView!.delegate = self
        self.textView!.textColor = V2EXColor.colors.v2_TopicListUserNameColor
        self.textView!.textParser = V2EXMentionedBindingParser()
        textView!.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10)
        textView?.keyboardDismissMode = .Interactive
        self.view.addSubview(self.textView!)
        self.textView!.snp_makeConstraints{ (make) -> Void in
            make.top.right.bottom.left.equalTo(self.view)
        }
        
    }
    
    func leftClick (){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func rightClick (){
        
    }
    
    func textViewDidChange(textView: YYTextView!) {
        if textView.text.Lenght == 0{
            textView.textColor = V2EXColor.colors.v2_TopicListUserNameColor
        }
    }
}

class ReplyingViewController:WritingViewController {
    var atSomeone:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "回复"
        if let atSomeone = self.atSomeone {
            let str = NSMutableAttributedString(string: atSomeone)
            str.yy_font = self.textView!.font
            str.yy_color = self.textView!.textColor
            
            self.textView!.attributedText = str
            
            self.textView!.selectedRange = NSMakeRange(atSomeone.Lenght, 0);
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        self.textView?.becomeFirstResponder()
    }
    
    override func rightClick (){
        if self.textView?.text == nil || self.textView?.text.Lenght <= 0 {
            return;
        }
        
        SVProgressHUD.showWithMaskType(.Clear)
        TopicCommentModel.replyWithTopicId(self.topicModel!, content: self.textView!.text ) {
            (response) in
            if response.success {
                [SVProgressHUD .showSuccessWithStatus("回复成功!")]
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            else{
                SVProgressHUD.showErrorWithStatus(response.message)
            }
        }
    }
}