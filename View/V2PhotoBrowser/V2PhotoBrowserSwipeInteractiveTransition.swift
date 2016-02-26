//
//  V2PhotoBrowserSwipeInteractiveTransition.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2/26/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit.UIGestureRecognizerSubclass
import CXSwipeGestureRecognizer

class V2PhotoBrowserSwipeInteractiveTransition: UIPercentDrivenInteractiveTransition ,CXSwipeGestureRecognizerDelegate {
    weak var browser:V2PhotoBrowser?
    
    var interacting:Bool = false
    private var dismissing  = false
    
    var shouldComplete:Bool = false
    
    var direction:CXSwipeGestureDirection = .None
    
    func prepareGestureRecognizerInView(view:UIView){
        let gestureRecognizer = CXSwipeGestureRecognizer()
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
    }
    func swipeGestureRecognizerDidStart(gestureRecognizer: CXSwipeGestureRecognizer!){
        self.interacting = true
    }
    func swipeGestureRecognizerDidUpdate(gestureRecognizer: CXSwipeGestureRecognizer!){

        if gestureRecognizer.currentDirection() == .Downwards || gestureRecognizer.currentDirection() == .Upwards {
            
        }
        else{
            gestureRecognizer.state = .Cancelled
            self.dismissing = false
            self.cancelInteractiveTransition()
            return
        }
        
        
        if !self.dismissing {
            self.dismissing = true
            self.browser?.dismissViewControllerAnimated(true, completion: nil)
        }
        

        self.direction = gestureRecognizer.currentDirection()
        
        var fraction = Float(gestureRecognizer.translationInDirection(gestureRecognizer.currentDirection()) / self.browser!.view.bounds.size.height)
        fraction = fminf(fmaxf(fraction, 0.0), 1.0)
        self.shouldComplete = abs(fraction) > 0.3
        self.updateInteractiveTransition(CGFloat(abs(fraction)))
    }
    func swipeGestureRecognizerDidFinish(gestureRecognizer: CXSwipeGestureRecognizer!){
        self.dismissing = false
        self.interacting = false
        if self.shouldComplete || gestureRecognizer.velocityInDirection(gestureRecognizer.currentDirection()) > 1000{
            self.finishInteractiveTransition()
        }
        else{
            self.cancelInteractiveTransition()
            self.direction = .None
        }
        
    }
}
