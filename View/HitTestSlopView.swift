//
//  HitTestSlopView.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2020/9/13.
//  Copyright © 2020 Fin. All rights reserved.
//

import UIKit

class HitTestSlopImageView: UIImageView {
    
    var hitTestSlop:UIEdgeInsets = UIEdgeInsets.zero
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if hitTestSlop == UIEdgeInsets.zero {
            return super.point(inside: point, with:event)
        }
        else{
            return self.bounds.inset(by: hitTestSlop).contains(point)
        }
    }
    
}
