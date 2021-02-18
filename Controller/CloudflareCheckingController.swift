//
//  CloudflareCheckingController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2021/2/18.
//  Copyright © 2021 Fin. All rights reserved.
//

import UIKit
import WebKit

class CloudflareCheckingController: UIViewController, WKNavigationDelegate {
    let webView:WKWebView = WKWebView()
    var completion: (() -> ())? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = V2EXColor.colors.v2_backgroundColor
        
        self.webView.customUserAgent = USER_AGENT
        self.webView.backgroundColor = self.view.backgroundColor
        self.webView.navigationDelegate = self
        self.view.addSubview(self.webView)
        self.webView.snp.makeConstraints{ (make) -> Void in
            make.edges.equalTo(self.view)
        }
        self.webView.scrollView.contentInsetAdjustmentBehavior = .never
        
        _ = self.webView.load(URLRequest(url: URL(string: V2EXURL)!))
    }

    
    // Cloudflare 检查后设置 cookies
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
            for cookie in cookies {
                HTTPCookieStorage.shared.setCookie(cookie)
            }
            let LANGCookie = cookies.compactMap{ (cookie) -> HTTPCookie? in
                if cookie.name == "V2EX_LANG" {
                    return cookie
                }
                return nil
            }.first
            
            // 有语言cookie，则证明检查通过
            if LANGCookie != nil {
                self.dismiss(animated: true) {[weak self] in
                    self?.completion?()
                }
            }
            
        }

    }

}
