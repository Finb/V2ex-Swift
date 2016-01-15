//
//  V2FPSLabel.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/15/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
//重写自 YYFPSLabel 
//https://github.com/ibireme/YYText/blob/master/Demo/YYTextDemo/YYFPSLabel.m


class V2FPSLabel: UILabel {
    private var _link :CADisplayLink?
    private var _count:Int = 0
    private var _lastTime:NSTimeInterval = 0

    private let _defaultSize = CGSizeMake(55, 20);
    
    override init(var frame: CGRect) {
        if frame.size.width == 0 && frame.size.height == 0{
            frame.size = _defaultSize
        }
        super.init(frame: frame)
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
        self.textAlignment = .Center
        self.userInteractionEnabled = false
        self.textColor = UIColor.whiteColor()
        self.backgroundColor = UIColor(white: 0, alpha: 0.7)
        self.font = UIFont(name: "Menlo", size: 14)
        weak var weakSelf = self
        _link = CADisplayLink(target: weakSelf!, selector:"tick:" );
        _link!.addToRunLoop(NSRunLoop .mainRunLoop(), forMode:NSRunLoopCommonModes)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func tick(link:CADisplayLink) {
        if _lastTime == 0  {
            _lastTime = link.timestamp
            return
        }
        
        _count++
        let delta = link.timestamp - _lastTime
        if delta < 1 {
            return
        }
        _lastTime = link.timestamp
        let fps = Double(_count) / delta
        _count = 0
        
        
        
        let progress = fps / 60.0;
        self.textColor = UIColor(hue: CGFloat(0.27 * ( progress - 0.2 )) , saturation: 1, brightness: 0.9, alpha: 1)
        self.text = "\(Int(fps+0.5))FPS"
        
    }
}
