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

func createImageWithColor(color:UIColor) -> UIImage{
    let rect=CGRectMake(0.0, 0.0, 1.0, 1.0);
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
    //background Color 
    var v2_backgroundColor: UIColor { get }
    
    // gray
    var v2_TopicListTitleColor : UIColor { get }
    var v2_TopicListUserNameColor : UIColor { get }
    var v2_TopicListDateColor : UIColor { get }
    //red
}

class V2EXDefaultColor: NSObject,V2EXColorProtocol {
    static let sharedInstance = V2EXDefaultColor()
    
    var v2_backgroundColor : UIColor{
        get{
            return colorWith255RGB(242, g: 243, b: 245);
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
}


class V2EXColor :NSObject  {
    static var colors :V2EXColorProtocol = V2EXDefaultColor.sharedInstance;
}