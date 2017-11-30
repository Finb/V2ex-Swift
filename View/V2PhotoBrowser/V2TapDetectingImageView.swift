//
//  V2TapDetectingImageView.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2/22/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import Kingfisher

@objc protocol V2TapDetectingImageViewDelegate {
    @objc optional func singleTapDetected(_ imageView:UIImageView,touch:UITouch)
    @objc optional func doubleTapDetected(_ imageView:UIImageView,touch:UITouch)
}

class V2TapDetectingImageView: AnimatedImageView {
    weak var tapDelegate:V2TapDetectingImageViewDelegate?
    init() {
        super.init(frame: CGRect.zero)
        self.isUserInteractionEnabled = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
        let touch = touches.first
        let tapCount = touch?.tapCount
        if let tapCount = tapCount {
            switch (tapCount) {
            case 1:
                self.perform(#selector(V2TapDetectingImageView.handleSingleTap(_:)), with: touch! , afterDelay: 0.3)
            case 2:
                self.handleDoubleTap(touch!)
                
            default :break;
            }
        }
//        不继续传递事件了
//        self.nextResponder()?.touchesEnded(touches, withEvent: event)
    }
    
    @objc func handleSingleTap(_ touch:UITouch){
        self.tapDelegate?.singleTapDetected?(self, touch: touch)
    }
    
    func handleDoubleTap(_ touch:UITouch){
        self.tapDelegate?.doubleTapDetected?(self, touch: touch)
    }
}
