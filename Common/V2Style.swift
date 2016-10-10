//
//  V2Style.swift
//  V2ex-Swift
//
//  Created by huangfeng on 3/10/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
//CSS基本样式
private let BASE_CSS = try! String(contentsOfFile: Bundle.main.path(forResource: "baseStyle", ofType: "css")!, encoding: String.Encoding.utf8)
//文字大小
private let FONT_CSS = try! String(contentsOfFile: Bundle.main.path(forResource: "font", ofType: "css")!, encoding: String.Encoding.utf8)
//暗色主题配色
private let DARK_CSS = (try! String(contentsOfFile: Bundle.main.path(forResource: "darkStyle", ofType: "css")!, encoding: String.Encoding.utf8))
//亮色主题配色
private let LIGHT_CSS = (try! String(contentsOfFile: Bundle.main.path(forResource: "lightStyle", ofType: "css")!, encoding: String.Encoding.utf8))


private let kFONTSCALE = "kFontScale"

/// 自动维护APP的CSS文件 ,外界只需调用 V2Style.sharedInstance.CSS 即可取得APP所需要的CSS
class V2Style: NSObject {
    static let sharedInstance = V2Style()
    
    fileprivate var _fontScale:Float = 1.0
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
    
    fileprivate override init() {
        super.init()
        //加载字体大小设置
        if let fontScaleString = V2EXSettings.sharedInstance[kFONTSCALE] , let scale = Float(fontScaleString){
            self._fontScale = scale
        }
        //监听主题配色，切换相应的配色
        self.thmemChangedHandler = {[weak self] (style) -> Void in
            self?.remakeCSS()
        }
        
    }
    
    //重新拼接CSS字符串
    fileprivate func remakeCSS(){
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
    fileprivate func fontCss() -> String {
        var fontCss = FONT_CSS
        
        //替换FONT_SIZE
        FONT_SIZE_ARRAY.forEach { (fontSize) -> () in
            fontCss = fontCss.replacingOccurrences(of: fontSize.labelName, with:String(fontSize.defaultFontSize * fontScale))
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
    V2FontSize(labelName:"<SUBTLE_FONT_SIZE>",defaultFontSize:12),
    V2FontSize(labelName:"<SUBTLE_FADE_FONT_SIZE>",defaultFontSize:10),
]

struct V2FontSize {
    let labelName:String
    let defaultFontSize:Float
}

