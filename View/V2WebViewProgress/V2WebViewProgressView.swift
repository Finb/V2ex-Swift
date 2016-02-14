//
//  V2WebViewProgressView.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2/14/16.
//  Copyright © 2016 Fin. All rights reserved.
//

// 此部分代码实现参考了
// https://github.com/sealedace/WebViewProgressView/blob/master/WebViewProgressDemo/WebProgressView/YHWebViewProgress.m

import UIKit

@objc protocol V2WebViewProgressDelegate : UIWebViewDelegate {
    optional func webViewProgress(webViewProgress: V2WebViewProgress,progress:Float)
}

class V2WebViewProgress: NSObject,UIWebViewDelegate {
    
    
    /// 刚加载时的进度
    private var InitialProgressValue:Float = 0.35
    /// 正在加载时的进度
    private var InteractiveProgressValue:Float = 0.75
    /// 快加载完时的进度
    private var FinalProgressValue:Float = 0.9
    /// 加载完时的进度
    private var CompleteProgressValue:Float = 1
    
    /// 加载完的数量
    private var loadingCount = 0
    /// 总共需要加载的数量
    private var maxLoadCount = 0
    
    /// 完成加载时 会自动跳转到这个url,监控这个URL 就知道是不是完成加载了
    private var CompleteRPCURLPath = "/me/fin/v2ex/V2WebViewProgress/complete"
    

    private var _progress:Float = 0
    /// 加载进度
    var progress:Float {
        get {
            return _progress
        }
        set {
            if newValue > _progress || newValue == 0 {
                _progress = newValue
                delegate?.webViewProgress?(self, progress: newValue)
            }
        }
    }
    
    /// 当前URL
    private var currentUrl:NSURL?
    
    private var interactive:Bool = false
    
    
    weak var delegate:V2WebViewProgressDelegate?
    
    func reset(){
        self.loadingCount = 0
        self.maxLoadCount = 0
        self.interactive = false
        self.progress = 0
    }
    func incrementProgress(){
        var currentProgress = self.progress
        let maxProgress = self.interactive ? FinalProgressValue : InteractiveProgressValue
        let remainPercent = Float(self.loadingCount) / Float(self.maxLoadCount)
        let increment = (maxProgress - currentProgress) * remainPercent
        currentProgress += increment
        
        self.progress = min(currentProgress,maxProgress)
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if request.URL?.path == CompleteRPCURLPath {
            self.progress = CompleteProgressValue
            return false
        }
        
        
        var ret = true
        //执行WebView代理
        if let aRet = delegate?.webView?(webView, shouldStartLoadWithRequest: request, navigationType: navigationType) {
            ret = aRet
        }
        
        //看URL是不是点击锚点的URL
        var isFragmentJump = false
        if let fragment = request.URL?.fragment {
            let nonFragmentURL = request.URL?.absoluteString.stringByReplacingOccurrencesOfString("#" + fragment, withString: "")
            isFragmentJump = nonFragmentURL == request.URL?.absoluteString
        }
        
        let isTopLevelNavigation = request.mainDocumentURL == request.URL
        
        var isHTTP = false
        if let scheme = request.URL?.scheme {
            isHTTP = ["http","https"].contains(scheme)
        }
        
        if (ret && !isFragmentJump && isHTTP && isTopLevelNavigation) {
            self.currentUrl = request.URL
            self.reset()
        }
        
        
        return ret
    }
    func webViewDidStartLoad(webView: UIWebView) {
        delegate?.webViewDidStartLoad?(webView)
        
        self.loadingCount++
        self.maxLoadCount = max(self.maxLoadCount, self.loadingCount)
        self.progress = InitialProgressValue
    }
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        delegate?.webView?(webView, didFailLoadWithError: error)
        
        self.handleCompleteProgress(webView)
    }
    func webViewDidFinishLoad(webView: UIWebView) {
        delegate?.webViewDidFinishLoad?(webView)
        
        self.handleCompleteProgress(webView)
    }
    
    func handleCompleteProgress(webView:UIWebView){
        self.loadingCount--
        self.incrementProgress()
        
        let readyState = webView.stringByEvaluatingJavaScriptFromString("document.readyState")
        
        let interactive = readyState == "interactive"
        
        if interactive {
            self.interactive = true
            
            let waitForCompleteJS = NSString(format: "window.addEventListener('load',function() { var iframe = document.createElement('iframe'); iframe.style.display = 'none'; iframe.src = '%@://%@%@'; document.body.appendChild(iframe);  }, false);", webView.request!.mainDocumentURL!.scheme, webView.request!.mainDocumentURL!.host!, CompleteRPCURLPath)
            webView.stringByEvaluatingJavaScriptFromString(waitForCompleteJS as String)
        }
        
        let isNotRedirect = self.currentUrl != nil && self.currentUrl == webView.request?.mainDocumentURL
        let complete = readyState == "complete"
        if complete && isNotRedirect{
            self.progress = CompleteProgressValue
        }
    }
    
    deinit{
        NSLog("progress deinit")
    }
    
}

class V2WebViewProgressView: UIView {
    var progressBarView:UIView?
    init(){
        super.init(frame: CGRectZero)
        self.setup()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup(){
        self.userInteractionEnabled = false
        self.progressBarView = UIView()
        self.progressBarView!.autoresizingMask = [.FlexibleWidth,.FlexibleHeight]
        self.progressBarView!.backgroundColor = colorWith255RGB(207, g: 70, b: 71)
        self.addSubview(self.progressBarView!)
        
        var frame = self.bounds
        frame.size.width = 0
        self.progressBarView?.frame = frame
    }
    
    func setProgress(progress:Float,animated:Bool) {
        UIView.animateWithDuration( animated ? 0.3 : 0, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 5, options: .CurveEaseIn, animations: { () -> Void in
            var frame = self.progressBarView!.frame
            frame.size.width = CGFloat(progress) * self.bounds.size.width
            self.progressBarView!.frame = frame
            },
            completion: nil)
        
        if progress >= 1 {
            UIView.animateWithDuration(animated ? 0.3 : 0, animations: { () -> Void in
                self.progressBarView!.alpha = 0
                }, completion: { (completed) -> Void in
                    var frame = self.bounds
                    frame.size.width = 0
                    self.progressBarView?.frame = frame
            })
        }
        else{
            UIView.animateWithDuration(animated ? 0.3 : 0) { () -> Void in
                self.progressBarView!.alpha = 1
            }
        }
    }
    
    deinit{
        NSLog("progressView deinit")
    }
}
