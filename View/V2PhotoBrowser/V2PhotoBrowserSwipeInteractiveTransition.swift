//
//  V2PhotoBrowserSwipeInteractiveTransition.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2/26/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

class V2PhotoBrowserSwipeInteractiveTransition: UIPercentDrivenInteractiveTransition {
    weak var browser:V2PhotoBrowser?
    
    var interacting:Bool = false
    
    var shouldComplete:Bool = false
    
    var firstX:CGFloat = 0
    var firstY:CGFloat = 0
    
    func prepareGestureRecognizerInView(view:UIView){
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "handleGesture:"))
    }
    
    func handleGesture(gestureRecognizer:UIPanGestureRecognizer){
        let translation = gestureRecognizer.translationInView(gestureRecognizer.view!)
        switch gestureRecognizer.state {
        case .Began:
            self.firstX = translation.x
            self.firstX = translation.y
            
            self.interacting = true
            self.browser?.dismissViewControllerAnimated(true, completion: nil)
            
        case .Changed:
            var fraction = Float(translation.y / self.browser!.view.bounds.size.height)
            fraction = fminf(fmaxf(fraction, 0.0), 1.0)
            
            self.shouldComplete = abs(fraction) > 0.3
            
            self.updateInteractiveTransition(CGFloat(abs(fraction)))

        case .Cancelled , .Ended:
            self.interacting = false
            if self.shouldComplete && gestureRecognizer.state != .Cancelled {
                self.finishInteractiveTransition()
            }
            else{
                print(gestureRecognizer.velocityInView(gestureRecognizer.view!).y)
                if abs(gestureRecognizer.velocityInView(gestureRecognizer.view!).y) > 1000 {
                    self.finishInteractiveTransition()
                }
                else{
                    self.cancelInteractiveTransition()
                }
            }
        default:break
        }
    }
}
