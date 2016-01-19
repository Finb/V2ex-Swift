//
//  V2ex+Define.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/11/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

let EMPTY_STRING = "" ;

let SCREEN_WIDTH = UIScreen.mainScreen().bounds.size.width;
let SCREEN_HEIGHT = UIScreen.mainScreen().bounds.size.height;

let LightBundel = NSBundle(path: NSBundle.mainBundle().pathForResource("Light", ofType: "bundle")!)!
let DarkBundel = NSBundle(path: NSBundle.mainBundle().pathForResource("Dark", ofType: "bundle")!)!
let CurrentBundel = LightBundel


extension UIImage {
    convenience init? (imageNamed: String){
        self.init(named: imageNamed, inBundle: CurrentBundel, compatibleWithTraitCollection: nil)
    }
}

func NSLocalizedString( key:String ) -> String {
    return NSLocalizedString(key, comment: "")
}