//
//  V2PhotoBrowserTransionDismiss.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2/26/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

class V2PhotoBrowserTransionDismiss:NSObject,UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        let fromVC = transitionContext!.viewControllerForKey(UITransitionContextFromViewControllerKey) as! V2PhotoBrowser
        if fromVC.transitionController.interacting {
            return 0.8
        }
        else{
            return 0.3
        }
    }
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! V2PhotoBrowser
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        let container = transitionContext.containerView()
        container!.addSubview(toVC.view)
        container!.bringSubviewToFront(fromVC.view)
        
        //显示引导动画，隐藏真正的照片浏览器
        //如果引导动画的图片没有加载完或加载失败，则显示真正的照片浏览器 渐变隐藏它
        fromVC.guideImageViewHidden(false)
        
        if let delegate = fromVC.delegate ,image = delegate.guideImageInPhotoBrowser(fromVC, index: fromVC.currentPageIndex) {
            fromVC.guideImageView.image = image
            //如果图片过小，则直接中间原图显示 ，否则fit
            if fromVC.guideImageView.originalImage?.size.width > SCREEN_WIDTH || fromVC.guideImageView.originalImage?.size.height > SCREEN_HEIGHT {
                fromVC.guideImageView.contentMode = .ScaleAspectFit
            }
            else{
                fromVC.guideImageView.contentMode = .Center
            }
            
            //重布局一下，因为有可能左右切换图片隐藏时 布局不对
            fromVC.guideImageView.setNeedsLayout()
            fromVC.guideImageView.layoutIfNeeded()
        }
        
        let animations = { () -> Void in
            fromVC.view.backgroundColor = UIColor(white: 0, alpha: 0)
            //如果guideImageView是隐藏的，则证明图片没有加载完不能显示，则渐变隐藏整个browser
            if fromVC.guideImageView.hidden {
                fromVC.pagingScrollView.alpha = 0
            }
            else {
                if !fromVC.transitionController.interacting {
                    if let delegate = fromVC.delegate {
                        fromVC.guideImageView.frame = delegate.guideFrameInPhotoBrowser(fromVC, index: fromVC.currentPageIndex)
                        fromVC.guideImageView.contentMode = delegate.guideContentModeInPhotoBrowser(fromVC, index: fromVC.currentPageIndex)
                    }
                }
                else{
                    var frame = fromVC.guideImageView.frame
                    if fromVC.transitionController.direction == .Downwards {
                        frame.origin.y += fromVC.view.frame.size.height
                    }
                    else {
                        frame.origin.y += 0 - frame.size.height
                    }
                    fromVC.guideImageView.frame = frame
                }
            }
        }
        
        let completion = {(finished: Bool) -> Void in
            fromVC.guideImageViewHidden(true)
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
        
        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: animations, completion: completion)
    }

}


