//
//  TopicDetailWebViewContentCell.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/19/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import KVOController
import JavaScriptCore
import Kingfisher

/**
 * 由于这里的逻辑比较分散，但又缺一不可，所以在这里说明一下
 * 1. 将V站帖子的HTML和此APP内置的CSS等拼接起来，然后用 UIWebView 加载。以实现富文本功能
 * 2. UIWebView 图片请求会被 WebViewImageProtocol 拦截，然后被 Kingfisher 缓存
 * 3. 点击UIWebView 图片时 ，会被内置的 tapGesture 捕获到（这个手势只在 UIWebView 所在的 UITableView 的pan手势 失效时触发
 *    也就是 在没滚动的时候才能点图片（交互优化）
 * 4. 然后通过 JSTools.js内置的 js方法，取得 图片 src,通过内置图片浏览器打开
 */

public typealias TopicDetailWebViewContentHeightChanged = (CGFloat) -> Void

let HTMLHEADER  = "<html><head><meta name=\"viewport\" content=\"width=device-width, user-scalable=no\">"
let jsCode = try! String(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "JSTools", ofType: "js")!))
class TopicDetailWebViewContentCell: UITableViewCell ,UIWebViewDelegate {
    
    fileprivate var model:TopicDetailModel?
    
    var contentHeight : CGFloat = 0
    var contentWebView:UIWebView = {
        let contentWebView = UIWebView()
        contentWebView.isOpaque = false
        contentWebView.backgroundColor = UIColor.clear
        contentWebView.scrollView.isScrollEnabled = false
        contentWebView.scalesPageToFit = false
        return contentWebView

    }()
    var contentHeightChanged : TopicDetailWebViewContentHeightChanged?
    
    var tapGesture:UITapGestureRecognizer?
    weak var parentScrollView:UIScrollView?{
        didSet{
            //滑动的时候，点击不生效
           tapGesture?.require(toFail: self.parentScrollView!.panGestureRecognizer)
        }
    }
    var tapImageInfo:TapImageInfo?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        self.setup();
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func setup()->Void{
        self.clipsToBounds = true
        
        self.contentWebView.delegate = self
        self.contentView.addSubview(self.contentWebView);
        self.contentWebView.snp.makeConstraints{ (make) -> Void in
            make.left.top.right.bottom.equalTo(self.contentView)
        }
        
        //强制将 UIWebView 设置背景颜色
        //不然不管怎么设置背景颜色，这B一直是白色，非得我治治他
        for view in self.contentWebView.scrollView.subviews {
            view.backgroundColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
        }
        
        self.kvoController.observe(self.contentWebView.scrollView, keyPath: "contentSize", options: [.new]) {
            [weak self] (observe, observer, change) -> Void in
            if let weakSelf = self {
                let size = change["new"] as! NSValue
                weakSelf.contentHeight = size.cgSizeValue.height;
                weakSelf.contentHeightChanged?(weakSelf.contentHeight)
            }
        }
        
        tapGesture = UITapGestureRecognizer(target: self, action:#selector(TopicDetailWebViewContentCell.tapHandler(_:)))
        self.tapGesture!.delegate = self
        self.contentWebView.addGestureRecognizer(self.tapGesture!);
    }
    @objc func tapHandler(_ tap :UITapGestureRecognizer){
        let tapPoint = tap.location(in: tap.view)
    
        let script = String(format: "getHTMLElementAtPoint(%i,%i)", Int(tapPoint.x),Int(tapPoint.y))

        let imgSrc = self.contentWebView.stringByEvaluatingJavaScript(from: script)
        guard let img = imgSrc , img.Lenght > 0 else {
            return
        }
        let arr = img.components(separatedBy: ",")
        guard arr.count == 5 else {
            return;
        }
        let url = fixUrl(url: arr[0])
        let width = Int(arr[1])
        let height = Int(arr[2])
        let left = Int(arr[3])
        let top = Int(arr[4])
        guard let w = width ,let h = height , let l = left , let t = top else {
            return;
        }
        
        self.tapImageInfo = TapImageInfo(url: url, width: w, height: h, left: l, top: t)
        
        let photoBrowser = V2PhotoBrowser(delegate: self)
        photoBrowser.currentPageIndex = 0;
        V2Client.sharedInstance.topNavigationController.present(photoBrowser, animated: true, completion: nil)
        
    }
    private func fixUrl(url:String) -> String {
        if(url.hasPrefix("http") || url.hasPrefix("https")){
            return url
        }
        if (url.hasPrefix("//")){
            return "https:" + url
        }
        else if(url.hasPrefix("/")){
            return "https://www.v2ex.com" + url
        }
        else {
            return url
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
            
            self.contentWebView.loadHTMLString(html, baseURL: URL(string: "https://www.v2ex.com"))

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
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.contentWebView.stringByEvaluatingJavaScript(from: jsCode)
    }
}

//MARK: - 点击图片放大
extension TopicDetailWebViewContentCell : V2PhotoBrowserDelegate {
    //V2PhotoBrowser Delegate
    func numberOfPhotosInPhotoBrowser(_ photoBrowser: V2PhotoBrowser) -> Int {
        return 1
    }
    func photoAtIndexInPhotoBrowser(_ photoBrowser: V2PhotoBrowser, index: Int) -> V2Photo {
        let photo = V2Photo(url: URL(string: self.tapImageInfo!.url)!)
        return photo
    }
    func guideContentModeInPhotoBrowser(_ photoBrowser: V2PhotoBrowser, index: Int) -> UIViewContentMode {
        return .scaleAspectFit
    }
    func guideFrameInPhotoBrowser(_ photoBrowser: V2PhotoBrowser, index: Int) -> CGRect {
        let location = self.contentWebView.convert(self.contentWebView.bounds, to: UIApplication.shared.keyWindow!)
        return CGRect(x: tapImageInfo!.left + Int(location.origin.x), y: tapImageInfo!.top + Int(location.origin.y), width: tapImageInfo!.width, height: tapImageInfo!.height)
    }
    func guideImageInPhotoBrowser(_ photoBrowser: V2PhotoBrowser, index: Int) -> UIImage? {
        var image = KingfisherManager.shared.cache.retrieveImageInMemoryCache(forKey: URL(string:tapImageInfo!.url)!.cacheKey)
        if image == nil {
            image = KingfisherManager.shared.cache.retrieveImageInDiskCache(forKey: URL(string:tapImageInfo!.url)!.cacheKey)
        }
        return image
    }
}

extension TopicDetailWebViewContentCell {
    //让点击图片手势 和webView的手势能共存
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

struct TapImageInfo {
    let url:String
    let width:Int
    let height:Int
    let left:Int
    let top:Int
}
