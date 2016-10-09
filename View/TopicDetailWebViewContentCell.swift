//
//  TopicDetailWebViewContentCell.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/19/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import KVOController

public typealias TopicDetailWebViewContentHeightChanged = (CGFloat) -> Void

let HTMLHEADER  = "<html><head><title>test</title><meta content='width=device-width; initial-scale=1.0; maximum-scale=1.0; user-scalable=0' name='viewport'>"
class TopicDetailWebViewContentCell: UITableViewCell ,UIWebViewDelegate {
    
    fileprivate var model:TopicDetailModel?
    
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
        self.clipsToBounds = true
        
        self.contentWebView = UIWebView()
        self.contentWebView!.isOpaque = false
        self.contentWebView!.backgroundColor = UIColor.clear
        self.contentWebView!.scrollView.isScrollEnabled = false
        self.contentWebView!.delegate = self
        self.contentView.addSubview(self.contentWebView!);
        self.contentWebView!.snp.makeConstraints{ (make) -> Void in
            make.left.top.right.bottom.equalTo(self.contentView)
        }

        //强制将 UIWebView 设置背景颜色
        //不然不管怎么设置背景颜色，这B一直是白色，非得我治治他
        for view in self.contentWebView!.scrollView.subviews {
            view.backgroundColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
        }
        
        self.kvoController.observe(self.contentWebView!.scrollView, keyPath: "contentSize", options: [.new]) {
            [weak self] (observe, observer, change) -> Void in
            if let weakSelf = self {
                let size = change!["new"] as! NSValue
                weakSelf.contentHeight = size.cgSizeValue.height;
                weakSelf.contentHeightChanged?(weakSelf.contentHeight)
            }
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func load(_ model:TopicDetailModel){
        if self.model == model{
            return;
        }
        self.model = model
        
        if var html = model.topicContent {

            let style = "<style>" + V2Style.sharedInstance.CSS + "</style></head>"
            html =  HTMLHEADER + style  + html + "</html>"
            
            self.contentWebView?.loadHTMLString(html, baseURL: URL(string: "https://"))

            //这里有一个问题，
            
            //如果baseURL 设置为nil，则可以直接引用本地css文件。
            //但不能加载 地址 //:开头的 的图片。
            
            //如果将baseUrl 设为 http/https ，则可以加载图片。但是却不能直接引用本地css文件，
            //因为WebView 有同源限制，http/https 与 我们本地css文件的 file:// 是不同源的
            //所以就会导致 css 样式不能加载
            
            //所以这里做个了折中方案，baseUrl 使用https ,将css样式写进html。
        }
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        //如果加载的是 自己load 的本地页面 则肯定放过啊
        if navigationType == .other {
            return true
        }
        else if navigationType == .linkClicked {
            if let url = request.url?.absoluteString{
                return !AnalyzeURLHelper.Analyze(url)
            }
        }
        return true
    }
}
