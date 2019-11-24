//
//  V2HitTestSlopButton.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2018/12/6.
//  Copyright © 2018 Fin. All rights reserved.
//

import UIKit

class V2HitTestSlopButton: UIButton {
    var hitTestSlop:UIEdgeInsets = UIEdgeInsets.zero
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if hitTestSlop == .zero {
            return super.point(inside: point, with:event)
        }
        else{
            return bounds.inset(by: hitTestSlop).contains(point)
        }
    }
}
