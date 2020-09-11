//
//  V2WebViewViewController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2/14/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import WebKit

class V2WebViewViewController: UIViewController ,V2WebViewProgressDelegate ,V2ActivityViewDataSource {
    var webViewProgress: V2WebViewProgress?
    var webViewProgressView: V2WebViewProgressView?
    var webView:WKWebView?
    var closeButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("关闭", for: .normal)
        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = v2Font(14)
        button.isHidden = true
        return button
    }()
    
    let leftBarButtonsPanelView = UIView(frame: CGRect(x: 0, y: 0, width: 75, height: 44))
    
    fileprivate var url:String = ""
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
        
        let backbtn = UIButton(type: .custom)
        backbtn.setTitle("返回", for: .normal)
        backbtn.frame = CGRect(x: 0, y: 0, width: 35, height: 44)
        backbtn.imageView!.contentMode = .center;
        backbtn.setImage(UIImage.imageUsedTemplateMode("ic_keyboard_arrow_left_36pt"), for: .normal)
        backbtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -21, bottom: 0, right: 0)
        backbtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -31, bottom: 0, right: 0)
        backbtn.titleLabel?.font = v2Font(14)
        backbtn.setTitleColor(self.navigationController?.navigationBar.tintColor, for: .normal)
        backbtn.contentHorizontalAlignment = .left
        
        backbtn.addTarget(self, action: #selector(V2WebViewViewController.back), for: .touchUpInside)

        self.closeButton.frame = CGRect(x: 40, y: 0, width: 35, height: 44)
        self.closeButton.setTitleColor(self.navigationController?.navigationBar.tintColor, for: .normal)
        self.closeButton.addTarget(self, action: #selector(V2WebViewViewController.pop), for: .touchUpInside)
        
        leftBarButtonsPanelView.addSubview(backbtn)
        leftBarButtonsPanelView.addSubview(self.closeButton)
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: leftBarButtonsPanelView)]
        
        let rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        rightButton.contentMode = .center
        rightButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -15)
        rightButton.setImage(UIImage(named: "ic_more_horiz_36pt")!.withRenderingMode(.alwaysTemplate), for: .normal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        rightButton.addTarget(self, action: #selector(V2WebViewViewController.rightClick), for: .touchUpInside)
        
        
        self.webViewProgress = V2WebViewProgress()
        self.webViewProgress!.delegate = self
        
        self.webView = WKWebView()
        self.webView!.backgroundColor = self.view.backgroundColor
        self.view.addSubview(self.webView!)
        self.webView!.snp.makeConstraints{ (make) -> Void in
            make.right.bottom.left.equalTo(self.view)
            make.top.equalTo(NavigationBarHeight)
        }
        self.webView!.scrollView.contentInsetAdjustmentBehavior = .never
        
        self.webViewProgressView = V2WebViewProgressView(frame: CGRect(x: 0, y: NavigationBarHeight, width: SCREEN_WIDTH, height: 2))
        self.view.addSubview(self.webViewProgressView!)
        
        if let URL = URL(string: self.url) {
            _ = self.webView?.load(URLRequest(url: URL))
        }
        
        self.kvoController.observe(self.webView, keyPaths: ["title","estimatedProgress"], options: [.new,.initial], block: {[weak self] (_,_,_) in
            self?.refreshState()
        })
    }
    
    private func refreshState(){
        
        self.webViewProgressView?.setProgress(Float(self.webView!.estimatedProgress), animated: true)
        
        if self.webView!.canGoBack {
            self.setCloseButtonHidden(false)
        } else {
            self.setCloseButtonHidden(true)
        }
        
        self.title = self.webView?.title
    }
    
    @objc func back(){
        if self.webView!.canGoBack {
            self.webView!.goBack()
        }
        else {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    @objc func pop(){
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func setCloseButtonHidden(_ hidden:Bool){
        self.closeButton.isHidden = hidden
        
        var frame = self.leftBarButtonsPanelView.frame
        frame.size.width = hidden ? 35 : 75
        self.leftBarButtonsPanelView.frame = frame
    }
    

    deinit{
        NSLog("webview deinit")
    }
    
    //MARK: - V2ActivityView
    @objc func rightClick(){
        let activityView = V2ActivityViewController()
        activityView.dataSource = self
        self.navigationController!.present(activityView, animated: true, completion: nil)
    }
    func V2ActivityView(_ activityView: V2ActivityViewController, numberOfCellsInSection section: Int) -> Int {
        return 1
    }
    func V2ActivityView(_ activityView: V2ActivityViewController, ActivityAtIndexPath indexPath: IndexPath) -> V2Activity {
        return V2Activity(title: ["Safari"][indexPath.row], image: UIImage(named: ["ic_explore_48pt"][indexPath.row])!)
    }
    func V2ActivityView(_ activityView: V2ActivityViewController, didSelectRowAtIndexPath indexPath: IndexPath) {
        activityView.dismiss()
        if  let url = self.webView?.url {
            if url.absoluteString.Lenght > 0 {
                UIApplication.shared.openURL(url)
                return;
            }
        }
        if let url = URL(string: self.url) {
            UIApplication.shared.openURL(url)
        }
        
    }
}
