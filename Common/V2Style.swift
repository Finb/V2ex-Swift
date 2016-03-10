//
//  V2Style.swift
//  V2ex-Swift
//
//  Created by huangfeng on 3/10/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
//CSS基本样式
private let BASE_CSS = try! String(contentsOfFile: NSBundle.mainBundle().pathForResource("baseStyle", ofType: "css")!, encoding: NSUTF8StringEncoding)
//文字大小
private let FONT_CSS = try! String(contentsOfFile: NSBundle.mainBundle().pathForResource("font", ofType: "css")!, encoding: NSUTF8StringEncoding)
//暗色主题配色
private let DARK_CSS = (try! String(contentsOfFile: NSBundle.mainBundle().pathForResource("darkStyle", ofType: "css")!, encoding: NSUTF8StringEncoding))
//亮色主题配色
private let LIGHT_CSS = (try! String(contentsOfFile: NSBundle.mainBundle().pathForResource("lightStyle", ofType: "css")!, encoding: NSUTF8StringEncoding))


private let kFONTSCALE = "kFontScale"

/// 自动维护APP的CSS文件 ,外界只需调用 V2Style.sharedInstance.CSS 即可取得APP所需要的CSS
class V2Style: NSObject {
    static let sharedInstance = V2Style()
    
    private var _fontScale:Float = 1.0
    dynamic var fontScale:Float {
        get{
            return _fontScale
        }
        set{
            if _fontScale != newValue {
                _fontScale = newValue
                self.remakeCSS()
                V2EXSettings.sharedInstance[kFONTSCALE] = "\(_fontScale)"
            }
        }
    }
    var CSS = ""
    
    private override init() {
        super.init()
        //加载字体大小设置
        if let fontScaleString = V2EXSettings.sharedInstance[kFONTSCALE] , scale = Float(fontScaleString){
            self._fontScale = scale
        }
        //监听主题配色，切换相应的配色
        self.KVOController.observe(V2EXColor.sharedInstance, keyPath: "style", options: [.Initial,.New]) { _ in
            self.remakeCSS()
        }
        
    }
    
    //重新拼接CSS字符串
    private func remakeCSS(){
        if let _ = V2EXColor.colors as? V2EXDefaultColor {
            self.CSS = BASE_CSS + self.fontCss() + LIGHT_CSS
        }
        else{
            self.CSS = BASE_CSS + self.fontCss() + DARK_CSS
        }
    }
    
    /**
     获取 FONT_CSS
     */
    private func fontCss() -> String {
        var fontCss = FONT_CSS
        
        //替换FONT_SIZE
        FONT_SIZE_ARRAY.forEach { (fontSize) -> () in
            fontCss = fontCss.stringByReplacingOccurrencesOfString(fontSize.labelName, withString:String(Int(fontSize.defaultFontSize * fontScale)))
        }
        
        return fontCss
    }
}




let FONT_SIZE_ARRAY = [
    V2FontSize(labelName:"<H1_FONT_SIZE>",defaultFontSize:18),
    V2FontSize(labelName:"<H2_FONT_SIZE>",defaultFontSize:18),
    V2FontSize(labelName:"<H3_FONT_SIZE>",defaultFontSize:16),
    V2FontSize(labelName:"<PRE_FONT_SIZE>",defaultFontSize:13),
    V2FontSize(labelName:"<BODY_FONT_SIZE>",defaultFontSize:14),
]

struct V2FontSize {
    let labelName:String
    let defaultFontSize:Float
}