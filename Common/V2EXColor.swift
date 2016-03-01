//
//  V2EXColor.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/11/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit


func colorWith255RGB(r:CGFloat , g:CGFloat, b:CGFloat) ->UIColor {
    return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 255)
}
func colorWith255RGBA(r:CGFloat , g:CGFloat, b:CGFloat,a:CGFloat) ->UIColor {
    return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a/255)
}

func createImageWithColor(color:UIColor) -> UIImage{
    return createImageWithColor(color, size: CGSizeMake(1, 1))
}
func createImageWithColor(color:UIColor,size:CGSize) -> UIImage {
    let rect = CGRectMake(0, 0, size.width, size.height)
    UIGraphicsBeginImageContext(rect.size);
    let context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    
    let theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}


//使用协议 方便以后切换颜色配置文件、或者做主题配色之类乱七八糟产品经理最爱的功能

protocol V2EXColorProtocol{
    var v2_backgroundColor: UIColor { get }
    var v2_navigationBarTintColor: UIColor { get }
    var v2_TopicListTitleColor : UIColor { get }
    var v2_TopicListUserNameColor : UIColor { get }
    var v2_TopicListDateColor : UIColor { get }
    
    var v2_LinkColor : UIColor { get }
    
    var v2_TextViewBackgroundColor: UIColor { get }
    
    var v2_CellWhiteBackgroundColor : UIColor { get }
    
    var v2_NodeBackgroundColor : UIColor { get }
    
    var v2_SeparatorColor : UIColor { get }
    
    var v2_LeftNodeBackgroundColor : UIColor { get }
    var v2_LeftNodeTintColor: UIColor { get }
    
    /// 小红点背景颜色
    var v2_NoticePointColor : UIColor { get }
    
    var v2_ButtonBackgroundColor : UIColor { get }
}

class V2EXDefaultColor: NSObject,V2EXColorProtocol {
    static let sharedInstance = V2EXDefaultColor()
    private override init(){
        super.init()
    }
    
    var v2_backgroundColor : UIColor{
        get{
            return colorWith255RGB(242, g: 243, b: 245);
        }
    }
    var v2_navigationBarTintColor : UIColor{
        get{
            return colorWith255RGB(102, g: 102, b: 102);
        }
    }
    
    
    var v2_TopicListTitleColor : UIColor{
        get{
            return colorWith255RGB(15, g: 15, b: 15);
        }
    }
    
    var v2_TopicListUserNameColor : UIColor{
        get{
            return colorWith255RGB(53, g: 53, b: 53);
        }
    }
    
    var v2_TopicListDateColor : UIColor{
        get{
            return colorWith255RGB(173, g: 173, b: 173);
        }
    }
    
    var v2_LinkColor : UIColor {
        get {
            return colorWith255RGB(119, g: 128, b: 135)
        }
    }
    
    var v2_TextViewBackgroundColor :UIColor {
        get {
            return colorWith255RGB(255, g: 255, b: 255)
        }
    }
    
    var v2_CellWhiteBackgroundColor :UIColor {
        get {
            return colorWith255RGB(255, g: 255, b: 255)
        }
    }
    
    var v2_NodeBackgroundColor : UIColor {
        get {
            return colorWith255RGB(242, g: 242, b: 242)
        }
    }
    var v2_SeparatorColor : UIColor {
        get {
            return colorWith255RGB(190, g: 190, b: 190)
        }
    }
    
    var v2_LeftNodeBackgroundColor : UIColor {
        get {
            return colorWith255RGBA(255, g: 255, b: 255, a: 76)
        }
    }
    var v2_LeftNodeTintColor : UIColor {
        get {
            return colorWith255RGBA(0, g: 0, b: 0, a: 140)
        }
    }
    
    var v2_NoticePointColor : UIColor {
        get {
            return colorWith255RGB(207, g: 70, b: 71)
        }
    }
    var v2_ButtonBackgroundColor : UIColor {
        get {
            return colorWith255RGB(80, g: 97, b: 109)
        }
    }
}


/// Dark Colors
class V2EXDarkColor: NSObject,V2EXColorProtocol {
    static let sharedInstance = V2EXDarkColor()
    private override init(){
        super.init()
    }
    
    var v2_backgroundColor : UIColor{
        get{
            return colorWith255RGB(32, g: 31, b: 35);
        }
    }
    var v2_navigationBarTintColor : UIColor{
        get{
            return colorWith255RGB(165, g: 165, b: 165);
        }
    }
    
    
    var v2_TopicListTitleColor : UIColor{
        get{
            return colorWith255RGB(145, g: 145, b: 145);
        }
    }
    
    var v2_TopicListUserNameColor : UIColor{
        get{
            return colorWith255RGB(125, g: 125, b: 125);
        }
    }
    
    var v2_TopicListDateColor : UIColor{
        get{
            return colorWith255RGB(100, g: 100, b: 100);
        }
    }
    
    var v2_LinkColor : UIColor {
        get {
            return colorWith255RGB(119, g: 128, b: 135)
        }
    }
    
    var v2_TextViewBackgroundColor :UIColor {
        get {
            return colorWith255RGB(35, g: 34, b: 38)
        }
    }
    
    var v2_CellWhiteBackgroundColor :UIColor {
        get {
            return colorWith255RGB(35, g: 34, b: 38)
        }
    }
    
    var v2_NodeBackgroundColor : UIColor {
        get {
            return colorWith255RGB(40, g: 40, b: 40)
        }
    }
    var v2_SeparatorColor : UIColor {
        get {
            return colorWith255RGB(46, g: 45, b: 49)
        }
    }
    
    var v2_LeftNodeBackgroundColor : UIColor {
        get {
            return colorWith255RGBA(255, g: 255, b: 255, a: 76)
        }
    }
    var v2_LeftNodeTintColor : UIColor {
        get {
            return colorWith255RGBA(0, g: 0, b: 0, a: 140)
        }
    }
    
    var v2_NoticePointColor : UIColor {
        get {
            return colorWith255RGB(207, g: 70, b: 71)
        }
    }
    var v2_ButtonBackgroundColor : UIColor {
        get {
            return colorWith255RGB(207, g: 70, b: 71)
        }
    }
}


class V2EXColor :NSObject  {
    private static let STYLE_KEY = "styleKey"
    
    static let V2EXColorStyleDefault = "Default"
    static let V2EXColorStyleDark = "Dark"
    
    private static var _colors:V2EXColorProtocol?
    static var colors :V2EXColorProtocol {
        get{
            
            if let c = V2EXColor._colors {
                return c
            }
            else{
                if V2EXColor.sharedInstance.style == V2EXColor.V2EXColorStyleDefault{
                    return V2EXDefaultColor.sharedInstance
                }
                else{
                    return V2EXDarkColor.sharedInstance
                }
            }
            
        }
        set{
            V2EXColor._colors = newValue
        }
    }
    
    dynamic var style:String
    static let sharedInstance = V2EXColor()
    private override init(){
        if let style = V2EXSettings.sharedInstance[V2EXColor.STYLE_KEY] {
            self.style = style
        }
        else{
            self.style = V2EXColor.V2EXColorStyleDefault
        }
        super.init()
    }
    func setStyleAndSave(style:String){
        if self.style == style {
            return
        }
        
        if style == V2EXColor.V2EXColorStyleDefault {
            V2EXColor.colors = V2EXDefaultColor.sharedInstance
        }
        else{
            V2EXColor.colors = V2EXDarkColor.sharedInstance
        }
        
        self.style = style
        V2EXSettings.sharedInstance[V2EXColor.STYLE_KEY] = style
        V2EXSettings.sharedInstance.save()
    }
    
}