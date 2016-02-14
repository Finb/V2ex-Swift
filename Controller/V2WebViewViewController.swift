//
//  V2WebViewViewController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2/14/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

class V2WebViewViewController: UIViewController ,V2WebViewProgressDelegate {
    var webViewProgress: V2WebViewProgress?
    var webViewProgressView: V2WebViewProgressView?
    var webView:UIWebView?
    var closeButton:UIButton?
    
    private var url:String = ""
    init(url:String){
        super.init(nibName: nil, bundle: nil)
        self.url = url
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = V2EXColor.colors.v2_backgroundColor
        
        let backbtn = UIButton(type: .Custom)
        backbtn.setTitle("返回", forState: .Normal)
        backbtn.frame = CGRectMake(0, 0, 35, 44)
        backbtn.imageView!.contentMode = .Center;
        backbtn.setImage(UIImage.imageUsedTemplateMode("ic_keyboard_arrow_left_36pt"), forState: .Normal)
        backbtn.imageEdgeInsets = UIEdgeInsetsMake(0, -21, 0, 0)
        backbtn.titleEdgeInsets = UIEdgeInsetsMake(0, -31, 0, 0)
        backbtn.titleLabel?.font = v2Font(14)
        backbtn.setTitleColor(self.navigationController?.navigationBar.tintColor, forState: .Normal)
        backbtn.contentHorizontalAlignment = .Left
        
        backbtn.addTarget(self, action: "back", forControlEvents: .TouchUpInside)
        
        
        self.closeButton = UIButton(type: .Custom)
        self.closeButton!.titleEdgeInsets = UIEdgeInsetsMake(0, -3, 0, 0)
        self.closeButton!.frame = CGRectMake(0, 0, 35, 44)
        self.closeButton!.setTitle("关闭", forState: .Normal)
        self.closeButton!.contentHorizontalAlignment = .Left
        self.closeButton!.setTitleColor(self.navigationController?.navigationBar.tintColor, forState: .Normal)
        self.closeButton!.titleLabel?.font = v2Font(14)
        self.closeButton!.hidden = true
        
        self.closeButton!.addTarget(self, action: "pop", forControlEvents: .TouchUpInside)
        
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: backbtn),UIBarButtonItem(customView: self.closeButton!)]
        
        self.webViewProgress = V2WebViewProgress()
        self.webViewProgress!.delegate = self
        
        self.webView = UIWebView()
        self.webView!.backgroundColor = self.view.backgroundColor
        self.webView!.delegate = self.webViewProgress
        self.view.addSubview(self.webView!)
        self.webView!.snp_makeConstraints{ (make) -> Void in
            make.top.right.bottom.left.equalTo(self.view)
        }
        
        self.webViewProgressView = V2WebViewProgressView(frame: CGRectMake(0, 64, SCREEN_WIDTH, 2))
        self.view.addSubview(self.webViewProgressView!)
        
        if let URL = NSURL(string: self.url) {
            self.webView?.loadRequest(NSURLRequest(URL: URL))
        }
    }
    
    func back(){
        if self.webView!.canGoBack {
            self.webView!.goBack()
        }
        else {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    func pop(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func setCloseButtonHidden(hidden:Bool){
        self.closeButton!.hidden = hidden
        
        var frame = self.closeButton!.frame
        frame.size.width = hidden ? 0 : 35
        self.closeButton!.frame = frame
    }
    
    func webViewProgress(webViewProgress: V2WebViewProgress, progress: Float) {
        self.webViewProgressView?.setProgress(progress, animated: true)
        
        let str = self.webView!.stringByEvaluatingJavaScriptFromString("document.title");
        if str?.Lenght > 0{
            self.title = str
        }
        
        if self.webView!.canGoBack {
            self.setCloseButtonHidden(false)
        } else {
            self.setCloseButtonHidden(true)
        }
    }
    deinit{
        NSLog("webview deinit")
    }
}
