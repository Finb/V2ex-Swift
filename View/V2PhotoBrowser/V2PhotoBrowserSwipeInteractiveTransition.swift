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
    fileprivate var dismissing  = false
    
    var shouldComplete:Bool = false
    
    var direction:CXSwipeGestureDirection = CXSwipeGestureDirection()
    
    var gestureRecognizer = CXSwipeGestureRecognizer()
    
    func prepareGestureRecognizerInView(_ view:UIView){
        
        gestureRecognizer.view?.removeGestureRecognizer(gestureRecognizer)
        
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
    }
    func swipeGestureRecognizerDidStart(_ gestureRecognizer: CXSwipeGestureRecognizer!){
        self.interacting = true
    }
    func swipeGestureRecognizerDidUpdate(_ gestureRecognizer: CXSwipeGestureRecognizer!){

        if (gestureRecognizer.currentDirection() != .downwards && gestureRecognizer.currentDirection() != .upwards) || !self.interacting{
            gestureRecognizer.state = .cancelled
            self.cancel()
            return
        }
        
        
        if !self.dismissing {
            self.dismissing = true
            self.browser?.dismiss(animated: true, completion: nil)
        }
        

        self.direction = gestureRecognizer.currentDirection()
        
        var fraction = Float(gestureRecognizer.translation(in: gestureRecognizer.currentDirection()) / self.browser!.view.bounds.size.height)
        fraction = fminf(fmaxf(fraction, 0.0), 1.0)
        self.shouldComplete = abs(fraction) > 0.3
        self.update(CGFloat(abs(fraction)))
    }
    func swipeGestureRecognizerDidFinish(_ gestureRecognizer: CXSwipeGestureRecognizer!){
        self.dismissing = false
        self.interacting = false
        if self.shouldComplete || gestureRecognizer.velocity(in: gestureRecognizer.currentDirection()) > 600{
            self.finish()
        }
        else{
            self.cancel()
        }
        
    }
    
    override func cancel(){
        self.dismissing = false
        self.interacting = false
        self.direction = CXSwipeGestureDirection()
        self.cancel()
    }
}
