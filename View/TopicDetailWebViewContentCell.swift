//
//  TopicDetailWebViewContentCell.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/19/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

public typealias TopicDetailWebViewContentHeightChanged = (CGFloat) -> Void

class TopicDetailWebViewContentCell: UITableViewCell,UIWebViewDelegate {
    
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
        self.contentWebView!.backgroundColor = UIColor.whiteColor()
        self.contentWebView!.delegate=self;
        self.contentWebView!.scrollView.scrollEnabled = false
        self.contentView.addSubview(self.contentWebView!);
        self.contentWebView!.snp_makeConstraints{ (make) -> Void in
            make.left.top.right.bottom.equalTo(self.contentView)
        }
    }
    
    func load(model:TopicDetailModel){
        if self.model == model{
            return;
        }
        self.model = model
        
        if let html = model.topicContent {
            self.contentWebView?.loadHTMLString(html, baseURL: nil)
        }
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        self.contentHeight = webView.scrollView.contentSize.height;
        if let event = contentHeightChanged {
            event(self.contentHeight)
        }
    }
    func webViewDidFinishLoad(webView: UIWebView) {
        self.contentHeight = webView.scrollView.contentSize.height;
        if let event = contentHeightChanged {
            event(self.contentHeight)
        }
    }
}
