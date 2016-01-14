// Copyright (c) 2014 evolved.io (http://evolved.io)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import QuartzCore
import UIKit

public class AnimatedMenuButton : UIButton {
    
    let top: CAShapeLayer = CAShapeLayer()
    let middle: CAShapeLayer = CAShapeLayer()
    let bottom: CAShapeLayer = CAShapeLayer()
    let strokeColor: UIColor
    
    // MARK: - Constants
    
    let animationDuration: CFTimeInterval = 8.0
    
    let shortStroke: CGPath = {
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, 2, 2)
        CGPathAddLineToPoint(path, nil, 30 - 2 * 2, 2)
        return path
        }()
    
    // MARK: - Initializers
    
    required public init?(coder aDecoder: NSCoder) {
        self.strokeColor = UIColor.grayColor()
        super.init(coder: aDecoder)
    }

    override convenience init(frame: CGRect) {
        self.init(frame: frame, strokeColor: UIColor.grayColor())
    }
    
    init(frame: CGRect, strokeColor: UIColor) {
        self.strokeColor = strokeColor
        super.init(frame: frame)
        
        self.top.path = shortStroke;
        self.middle.path = shortStroke;
        self.bottom.path = shortStroke;
        
        for layer in [ self.top, self.middle, self.bottom ] {
            layer.fillColor = nil
            layer.strokeColor = self.strokeColor.CGColor
            layer.lineWidth = 4
            layer.miterLimit = 2
            layer.lineCap = kCALineCapRound
            layer.masksToBounds = true
            
            let strokingPath = CGPathCreateCopyByStrokingPath(layer.path, nil, 4, .Round, .Miter, 4)
            
            layer.bounds = CGPathGetPathBoundingBox(strokingPath)
            
            layer.actions = [
                "opacity": NSNull(),
                "transform": NSNull()
            ]
            
            self.layer.addSublayer(layer)
        }
        
        self.top.anchorPoint = CGPoint(x: 1, y: 0.5)
        self.top.position = CGPoint(x: 30 - 1, y: 5)
        self.middle.position = CGPoint(x: 15, y: 15)
        
        self.bottom.anchorPoint = CGPoint(x: 1, y: 0.5)
        self.bottom.position = CGPoint(x: 30 - 1, y: 25)
    }
    
    // MARK: - Animations
    
    public func animateWithPercentVisible(percentVisible:CGFloat, drawerSide: DrawerSide) {
        
        if drawerSide == DrawerSide.Left {
            self.top.anchorPoint = CGPoint(x: 1, y: 0.5)
            self.top.position = CGPoint(x: 30 - 1, y: 5)
            self.middle.position = CGPoint(x: 15, y: 15)
            
            self.bottom.anchorPoint = CGPoint(x: 1, y: 0.5)
            self.bottom.position = CGPoint(x: 30 - 1, y: 25)
        } else if drawerSide == DrawerSide.Right {
            self.top.anchorPoint = CGPoint(x: 0, y: 0.5)
            self.top.position = CGPoint(x: 1, y: 5)
            self.middle.position = CGPoint(x: 15, y: 15)
            
            self.bottom.anchorPoint = CGPoint(x: 0, y: 0.5)
            self.bottom.position = CGPoint(x: 1, y: 25)
        }
        
        let middleTransform = CABasicAnimation(keyPath: "opacity")
        middleTransform.duration = animationDuration
        
        let topTransform = CABasicAnimation(keyPath: "transform")
        topTransform.timingFunction = CAMediaTimingFunction(controlPoints: 0.5, -0.8, 0.5, 1.85)
        topTransform.duration = animationDuration
        topTransform.fillMode = kCAFillModeBackwards
        
        let bottomTransform = topTransform.copy() as! CABasicAnimation
        
        middleTransform.toValue = 1 - percentVisible
        
        let translation = CATransform3DMakeTranslation(-4 * percentVisible, 0, 0)
        
        let sideInverter: CGFloat = drawerSide == DrawerSide.Left ? -1 : 1
        topTransform.toValue = NSValue(CATransform3D: CATransform3DRotate(translation, 1.0 * sideInverter * ((CGFloat)(45.0 * M_PI / 180.0) * percentVisible), 0, 0, 1))
        bottomTransform.toValue = NSValue(CATransform3D: CATransform3DRotate(translation, (-1.0 * sideInverter * (CGFloat)(45.0 * M_PI / 180.0) * percentVisible), 0, 0, 1))

        topTransform.beginTime = CACurrentMediaTime()
        bottomTransform.beginTime = CACurrentMediaTime()
        
        self.top.addAnimation(topTransform, forKey: topTransform.keyPath)
        self.middle.addAnimation(middleTransform, forKey: middleTransform.keyPath)
        self.bottom.addAnimation(bottomTransform, forKey: bottomTransform.keyPath)
        
        self.top.setValue(topTransform.toValue, forKey: topTransform.keyPath!)
        self.middle.setValue(middleTransform.toValue, forKey: middleTransform.keyPath!)
        self.bottom.setValue(bottomTransform.toValue, forKey: bottomTransform.keyPath!)
    }
}
