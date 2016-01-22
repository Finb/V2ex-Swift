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
        self.contentWebView!.scrollView.scrollEnabled = false
        self.contentView.addSubview(self.contentWebView!);
        self.contentWebView!.snp_makeConstraints{ (make) -> Void in
            make.left.top.right.bottom.equalTo(self.contentView)
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
    
    func load(model:TopicDetailModel){
        if self.model == model{
            return;
        }
        self.model = model
        
        if var html = model.topicContent {
//            let style = "<link rel='stylesheet' href = 'file://"
//                + LightBundel.pathForResource("style", ofType: "css")!
//                + "' type='text/css'/></head>" ;

            let style = "<style>" + LIGHT_CSS + "</style></head>"
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
}
