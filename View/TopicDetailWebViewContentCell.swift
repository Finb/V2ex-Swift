//
//  TopicDetailWebViewContentCell.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/19/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import KVOController
import SafariServices

public typealias TopicDetailWebViewContentHeightChanged = (CGFloat) -> Void

let HTMLHEADER  = "<html><head><title>test</title><meta content='width=device-width; initial-scale=1.0; maximum-scale=1.0; user-scalable=0' name='viewport'>"
class TopicDetailWebViewContentCell: UITableViewCell ,UIWebViewDelegate, SFSafariViewControllerDelegate {
    
    private var model:TopicDetailModel?
    
    var contentHeight : CGFloat = 0
    var contentWebView:UIWebView?
    var contentHeightChanged : TopicDetailWebViewContentHeightChanged?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        self.setup();
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func setup()->Void{
        self.contentWebView = UIWebView()
        self.contentWebView!.opaque = false
        self.contentWebView!.backgroundColor = UIColor.clearColor()
        self.contentWebView!.scrollView.scrollEnabled = false
        self.contentWebView!.delegate = self
        self.contentView.addSubview(self.contentWebView!);
        self.contentWebView!.snp_makeConstraints{ (make) -> Void in
            make.left.top.right.bottom.equalTo(self.contentView)
        }

        //强制将 UIWebView 设置背景颜色
        //不然不管怎么设置背景颜色，这B一直是白色，非得我治治他
        for view in self.contentWebView!.scrollView.subviews {
            view.backgroundColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
        }
        
        self.KVOController.observe(self.contentWebView!.scrollView, keyPath: "contentSize", options: [.New]) {
            [weak self] (observe, observer, change) -> Void in
            if let weakSelf = self {
                let size = change![NSKeyValueChangeNewKey] as! NSValue
                weakSelf.contentHeight = size.CGSizeValue().height;
                if let event = weakSelf.contentHeightChanged {
                    event(weakSelf.contentHeight)
                }
            }
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func load(model:TopicDetailModel){
        if self.model == model{
            return;
        }
        self.model = model
        
        if var html = model.topicContent {
//            let style = "<link rel='stylesheet' href = 'file://"
//                + LightBundel.pathForResource("style", ofType: "css")!
//                + "' type='text/css'/></head>" ;

            var css = ""
            if let _ = V2EXColor.colors as? V2EXDefaultColor {
                css = LIGHT_CSS
            }
            else {
                css = DARK_CSS
            }
            let style = "<style>" + css + "</style></head>"
            html =  HTMLHEADER + style  + html + "</html>"
            
            self.contentWebView?.loadHTMLString(html, baseURL: NSURL(string: "https://"))

            //这里有一个问题，
            
            //如果baseURL 设置为nil，则可以直接引用本地css文件。
            //但不能加载 地址 //:开头的 的图片。
            
            //如果将baseUrl 设为 http/https ，则可以加载图片。但是却不能直接引用本地css文件，
            //因为WebView 有同源限制，http/https 与 我们本地css文件的 file:// 是不同源的
            //所以就会导致 css 样式不能加载
            
            //所以这里做个了折中方案，baseUrl 使用https ,将css样式写进html。
        }
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if #available(iOS 9.0, *) {
            if navigationType == .LinkClicked {
                if let url = request.URL {
                    let safariVC = SFSafariViewController(URL: url)
                    safariVC.delegate = self
                    UIApplication.topMostViewController()?.presentViewController(safariVC, animated: true, completion: nil)
                    return false
                }
            }
        }
        
        //如果加载的是 自己load 的本地页面 则肯定放过啊
        if request.URL?.absoluteString == "https:/" {
            return true
        }
        if let url = request.URL?.absoluteString{
            return !AnalyzeURLHelper.Analyze(url)
        }
        return true
    }
}
