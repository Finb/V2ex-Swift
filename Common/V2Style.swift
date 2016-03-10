//
//  V2Style.swift
//  V2ex-Swift
//
//  Created by huangfeng on 3/10/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit


//CSS样式字符串
private let BASE_CSS = try! String(contentsOfFile: NSBundle.mainBundle().pathForResource("baseStyle", ofType: "css")!, encoding: NSUTF8StringEncoding)
private let DARK_CSS = (try! String(contentsOfFile: NSBundle.mainBundle().pathForResource("darkStyle", ofType: "css")!, encoding: NSUTF8StringEncoding))
private let LIGHT_CSS = (try! String(contentsOfFile: NSBundle.mainBundle().pathForResource("lightStyle", ofType: "css")!, encoding: NSUTF8StringEncoding))

/// 自动维护APP的CSS文件 ,外界只需调用 V2Style.sharedInstance.CSS 即可取得APP所需要的CSS
class V2Style: NSObject {
    static let sharedInstance = V2Style()
    
    private var dark_css = BASE_CSS + DARK_CSS
    private var light_css = BASE_CSS + LIGHT_CSS
    var CSS = ""
    
    private override init() {
        super.init()
    
        //监听主题配色，切换相应的配色
        self.KVOController.observe(V2EXColor.sharedInstance, keyPath: "style", options: [.Initial,.New]) { _ in
            if let _ = V2EXColor.colors as? V2EXDefaultColor {
                self.CSS = self.light_css
            }
            else{
                self.CSS = self.dark_css
            }
        }
        
    }
}