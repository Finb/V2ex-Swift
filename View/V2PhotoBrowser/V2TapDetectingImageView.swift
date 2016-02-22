//
//  V2TapDetectingImageView.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2/22/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

@objc protocol V2TapDetectingImageViewDelegate {
    optional func singleTapDetected(imageView:UIImageView,touch:UITouch)
    optional func doubleTapDetected(imageView:UIImageView,touch:UITouch)
}

class V2TapDetectingImageView: UIImageView {
    weak var tapDelegate:V2TapDetectingImageViewDelegate?
    init() {
        super.init(frame: CGRectZero)
        self.userInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        let tapCount = touch?.tapCount
        if let tapCount = tapCount {
            switch (tapCount) {
            case 1:
                self.tapDelegate?.singleTapDetected?(self, touch: touch!)
            case 2:
                self.tapDelegate?.doubleTapDetected?(self, touch: touch!)
            default :break;
            }
        }
        self.nextResponder()?.touchesEnded(touches, withEvent: event)
    }
}
