//
//  V2EXColor.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/11/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import KVOController


func colorWith255RGB(_ r:CGFloat , g:CGFloat, b:CGFloat) ->UIColor {
    return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 255)
}
func colorWith255RGBA(_ r:CGFloat , g:CGFloat, b:CGFloat,a:CGFloat) ->UIColor {
    return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a/255)
}

func createImageWithColor(_ color:UIColor) -> UIImage{
    return createImageWithColor(color, size: CGSize(width: 1, height: 1))
}
func createImageWithColor(_ color:UIColor,size:CGSize) -> UIImage {
    let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    UIGraphicsBeginImageContext(rect.size);
    let context = UIGraphicsGetCurrentContext();
    context?.setFillColor(color.cgColor);
    context?.fill(rect);
    
    let theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage!;
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
    var v2_LeftNodeBackgroundHighLightedColor : UIColor { get }
    var v2_LeftNodeTintColor: UIColor { get }
    
    /// 小红点背景颜色
    var v2_NoticePointColor : UIColor { get }
    
    var v2_ButtonBackgroundColor : UIColor { get }
}

class V2EXDefaultColor: NSObject,V2EXColorProtocol {
    static let sharedInstance = V2EXDefaultColor()
    fileprivate override init(){
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
    var v2_LeftNodeBackgroundHighLightedColor : UIColor {
        get {
            return colorWith255RGBA(255, g: 255, b: 255, a: 56)
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
            return colorWith255RGB(85, g: 172, b: 238)
        }
    }
}


/// Dark Colors
class V2EXDarkColor: NSObject,V2EXColorProtocol {
    static let sharedInstance = V2EXDarkColor()
    fileprivate override init(){
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
    var v2_LeftNodeBackgroundHighLightedColor : UIColor {
        get {
            return colorWith255RGBA(255, g: 255, b: 255, a: 56)
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
    fileprivate static let STYLE_KEY = "styleKey"
    fileprivate static let ISFOLLOWSYSTEM_KEY = "isFollowSystemKey"
    
    static let V2EXColorStyleDefault = "Default"
    static let V2EXColorStyleDark = "Dark"
    
    fileprivate static var _colors:V2EXColorProtocol?
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
    
    @objc dynamic private var _style:String
    var style:String {
        get {
            if #available(iOS 13.0, *) {
                if isFollowSystem {
                    let style = V2Client.sharedInstance.window?.traitCollection.userInterfaceStyle ?? UIUserInterfaceStyle.unspecified
                    if style == UIUserInterfaceStyle.light {
                        return V2EXColor.V2EXColorStyleDefault
                    }
                    else if style == UIUserInterfaceStyle.dark {
                        return V2EXColor.V2EXColorStyleDark
                    }
                }
            }
            return _style
        }
        set{
            _style = newValue
        }
    }
    var isFollowSystem: Bool {
        didSet{
            Settings[V2EXColor.ISFOLLOWSYSTEM_KEY] = isFollowSystem
            refreshColorStyle()
        }
    }
    static let sharedInstance = V2EXColor()
    fileprivate override init(){
        if let style:String = Settings[V2EXColor.STYLE_KEY] {
            self._style = style
        }
        else{
            self._style = V2EXColor.V2EXColorStyleDefault
        }
        
        if let value:Bool = Settings[V2EXColor.ISFOLLOWSYSTEM_KEY] {
            self.isFollowSystem = value
        }
        else{
            if #available(iOS 13.0, *) {
                self.isFollowSystem = true
            }
            else{
                self.isFollowSystem = false
            }
        }
        
        super.init()
    }
    func setStyleAndSave(_ style:String){
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
    }
    
    func refreshColorStyle() {
        if self.style == V2EXColor.V2EXColorStyleDefault {
            V2EXColor.colors = V2EXDefaultColor.sharedInstance
        }
        else{
            V2EXColor.colors = V2EXDarkColor.sharedInstance
        }
        
        //原样赋值，触发主题更改事件
        let style = self._style
        self._style = style
    }
}

//MARK: - 主题更改时，自动执行
extension NSObject {
    fileprivate struct AssociatedKeys {
        static var thmemChanged = "thmemChanged"
    }
    
    /// 当前主题更改时、第一次设置时 自动调用的闭包
    public typealias ThemeChangedClosure = @convention(block) (_ style:String) -> Void
    
    /// 自动调用的闭包
    /// 设置时，会设置一个KVO监听，当V2Style.style更改时、第一次赋值时 会自动调用这个闭包
    var themeChangedHandler:ThemeChangedClosure? {
        get {
            let closureObject: AnyObject? = objc_getAssociatedObject(self, &AssociatedKeys.thmemChanged) as AnyObject?
            guard closureObject != nil else{
                return nil
            }
            let closure = unsafeBitCast(closureObject, to: ThemeChangedClosure.self)
            return closure
        }
        set{
            guard let value = newValue else{
                return
            }
            let dealObject: AnyObject = unsafeBitCast(value, to: AnyObject.self)
            objc_setAssociatedObject(self, &AssociatedKeys.thmemChanged,dealObject,objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            //设置KVO监听
            self.kvoController.observe(V2EXColor.sharedInstance, keyPath: "_style", options: [.initial,.new] , block: {[weak self] (nav, color, change) -> Void in
                self?.themeChangedHandler?(V2EXColor.sharedInstance.style)
                }
            )
        }
    }
}
