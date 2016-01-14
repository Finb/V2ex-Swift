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

import UIKit
import QuartzCore

public struct DrawerVisualState {
    
    /**
    Creates a slide and scale visual state block that gives an experience similar to Mailbox.app. It scales from 90% to 100%, and translates 50 pixels in the x direction. In addition, it also sets alpha from 0.0 to 1.0.
    
    - returns: The visual state block.
    */
    public static var slideAndScaleVisualStateBlock: DrawerControllerDrawerVisualStateBlock {
        let visualStateBlock: DrawerControllerDrawerVisualStateBlock = { (drawerController, drawerSide, percentVisible) -> Void in
            let minScale: CGFloat = 0.9
            let scale: CGFloat = minScale + (percentVisible * (1.0-minScale))
            let scaleTransform = CATransform3DMakeScale(scale, scale, scale)
            
            let maxDistance: CGFloat = 50
            let distance: CGFloat = maxDistance * percentVisible
            var translateTransform = CATransform3DIdentity
            var sideDrawerViewController: UIViewController?
            
            if drawerSide == DrawerSide.Left {
                sideDrawerViewController = drawerController.leftDrawerViewController
                translateTransform = CATransform3DMakeTranslation((maxDistance - distance), 0, 0)
            } else if drawerSide == DrawerSide.Right {
                sideDrawerViewController = drawerController.rightDrawerViewController
                translateTransform = CATransform3DMakeTranslation(-(maxDistance-distance), 0.0, 0.0)
            }
            
            sideDrawerViewController?.view.layer.transform = CATransform3DConcat(scaleTransform, translateTransform)
            sideDrawerViewController?.view.alpha = percentVisible
        }

        return visualStateBlock
    }
    
    /**
    Creates a slide visual state block that gives the user an experience that slides at the same speed of the center view controller during animation. This is equal to calling `parallaxVisualStateBlockWithParallaxFactor:` with a parallax factor of 1.0.
    
    - returns: The visual state block.
    */
    public static var slideVisualStateBlock: DrawerControllerDrawerVisualStateBlock {
        return self.parallaxVisualStateBlock(1.0)
    }
    
    /**
    Creates a swinging door visual state block that gives the user an experience that animates the drawer in along the hinge.
    
    - returns: The visual state block.
    */
    public static var swingingDoorVisualStateBlock: DrawerControllerDrawerVisualStateBlock {
        let visualStateBlock: DrawerControllerDrawerVisualStateBlock = { (drawerController, drawerSide, percentVisible) -> Void in
            
            var sideDrawerViewController: UIViewController?
            var anchorPoint: CGPoint
            var maxDrawerWidth: CGFloat = 0.0
            var xOffset: CGFloat
            var angle: CGFloat = 0.0
            
            if drawerSide == .Left {
                sideDrawerViewController = drawerController.leftDrawerViewController
                anchorPoint = CGPoint(x: 1.0, y: 0.5)
                maxDrawerWidth = max(drawerController.maximumLeftDrawerWidth, drawerController.visibleLeftDrawerWidth)
                xOffset = -(maxDrawerWidth / 2) + maxDrawerWidth * percentVisible
                angle = -CGFloat(M_PI_2) + percentVisible * CGFloat(M_PI_2)
            } else {
                sideDrawerViewController = drawerController.rightDrawerViewController
                anchorPoint = CGPoint(x: 0.0, y: 0.5)
                maxDrawerWidth = max(drawerController.maximumRightDrawerWidth, drawerController.visibleRightDrawerWidth)
                xOffset = (maxDrawerWidth / 2) - maxDrawerWidth * percentVisible
                angle = CGFloat(M_PI_2) - percentVisible * CGFloat(M_PI_2)
            }
            
            sideDrawerViewController?.view.layer.anchorPoint = anchorPoint
            sideDrawerViewController?.view.layer.shouldRasterize = true
            sideDrawerViewController?.view.layer.rasterizationScale = UIScreen.mainScreen().scale
            
            var swingingDoorTransform: CATransform3D = CATransform3DIdentity
           
            if percentVisible <= 1.0 {
                var identity: CATransform3D = CATransform3DIdentity
                identity.m34 = -1.0 / 1000.0
                let rotateTransform: CATransform3D = CATransform3DRotate(identity, angle,
                    0.0, 1.0, 0.0)
                let translateTransform: CATransform3D = CATransform3DMakeTranslation(xOffset, 0.0, 0.0)
                let concatTransform = CATransform3DConcat(rotateTransform, translateTransform)
                
                swingingDoorTransform = concatTransform
            } else {
                var overshootTransform = CATransform3DMakeScale(percentVisible, 1.0, 1.0)
                var scalingModifier: CGFloat = 1.0
                
                if (drawerSide == .Right) {
                    scalingModifier = -1.0
                }
                
                overshootTransform = CATransform3DTranslate(overshootTransform, scalingModifier * maxDrawerWidth / 2, 0.0, 0.0)
                swingingDoorTransform = overshootTransform
            }
            
            sideDrawerViewController?.view.layer.transform = swingingDoorTransform
        }
        
        return visualStateBlock
    }
    
    /**
    Creates a parallax experience that slides the side drawer view controller at a different rate than the center view controller during animation. For every parallaxFactor of points moved by the center view controller, the side drawer view controller will move 1 point. Passing in 1.0 is the  equivalent of a applying a sliding animation, while passing in MAX_FLOAT is the equivalent of having no animation at all.
    
    - parameter parallaxFactor: The amount of parallax applied to the side drawer conroller. This value must be greater than 1.0. The closer the value is to 1.0, the faster the side drawer view controller will be parallaxing.
    
    - returns: The visual state block.
    */
    public static func parallaxVisualStateBlock(parallaxFactor: CGFloat) -> DrawerControllerDrawerVisualStateBlock {
        let visualStateBlock: DrawerControllerDrawerVisualStateBlock = { (drawerController, drawerSide, percentVisible) -> Void in
            
            assert({ () -> Bool in
                return parallaxFactor >= 1.0
            }(), "parallaxFactor must be >= 1.0")
            
            var transform: CATransform3D = CATransform3DIdentity
            var sideDrawerViewController: UIViewController?
            
            if (drawerSide == .Left) {
                sideDrawerViewController = drawerController.leftDrawerViewController
                let distance: CGFloat = max(drawerController.maximumLeftDrawerWidth, drawerController.visibleLeftDrawerWidth)
                
                if (percentVisible <= 1.0) {
                    transform = CATransform3DMakeTranslation((-distance) / parallaxFactor + (distance * percentVisible / parallaxFactor), 0.0, 0.0)
                } else {
                    transform = CATransform3DMakeScale(percentVisible, 1.0, 1.0)
                    transform = CATransform3DTranslate(transform, drawerController.maximumLeftDrawerWidth * (percentVisible - 1.0) / 2, 0.0, 0.0)
                }
            } else if (drawerSide == .Right) {
                sideDrawerViewController = drawerController.rightDrawerViewController
                let distance: CGFloat = max(drawerController.maximumRightDrawerWidth, drawerController.visibleRightDrawerWidth)
                
                if (percentVisible <= 1.0) {
                    transform = CATransform3DMakeTranslation((distance) / parallaxFactor - (distance * percentVisible / parallaxFactor), 0.0, 0.0)
                } else {
                    transform = CATransform3DMakeScale(percentVisible, 1.0, 1.0)
                    transform = CATransform3DTranslate(transform, -drawerController.maximumRightDrawerWidth * (percentVisible - 1.0) / 2, 0.0, 0.0)
                }
            }
            
            sideDrawerViewController?.view.layer.transform = transform
        }
            
        return visualStateBlock
    }
    
    public static var animatedHamburgerButtonVisualStateBlock: DrawerControllerDrawerVisualStateBlock {
        let visualStateBlock: DrawerControllerDrawerVisualStateBlock = { (drawerController, drawerSide, percentVisible) -> Void in
            
            var hamburgerItem: DrawerBarButtonItem?
            if let navController = drawerController.centerViewController as? UINavigationController {
                if (drawerSide == .Left) {
                    if let item = navController.topViewController!.navigationItem.leftBarButtonItem as? DrawerBarButtonItem {
                        hamburgerItem = item
                    }
                } else if (drawerSide == .Right) {
                    if let item = navController.topViewController!.navigationItem.rightBarButtonItem as? DrawerBarButtonItem {
                        hamburgerItem = item
                    }
                }
            }

            hamburgerItem?.animateWithPercentVisible(percentVisible, drawerSide: drawerSide)
        }
            
        return visualStateBlock
    }
}