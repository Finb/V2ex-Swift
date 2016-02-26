//
//  V2PhotoBrowserTransionPresent.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2/26/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

class V2PhotoBrowserTransionPresent:NSObject,UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3
    }
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! V2PhotoBrowser
        let container = transitionContext.containerView()
        container!.addSubview(toVC.view)
        
        //给引导动画赋值
        if let delegate = toVC.delegate{
            toVC.guideImageView.frame = delegate.guideFrameInPhotoBrowser(toVC, index: toVC.currentPageIndex)
            toVC.guideImageView.image = delegate.guideImageInPhotoBrowser(toVC, index: toVC.currentPageIndex)
            toVC.guideImageView.contentMode = delegate.guideContentModeInPhotoBrowser(toVC, index: toVC.currentPageIndex)
        }
        
        //显示引导动画的imageView
        toVC.guideImageViewHidden(false)
        
        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            toVC.view.backgroundColor = UIColor(white: 0, alpha: 1)
            toVC.guideImageView.frame = toVC.view.bounds
            
            //如果图片过小，则直接中间原图显示 ，否则fit
            if toVC.guideImageView.originalImage?.size.width > SCREEN_WIDTH || toVC.guideImageView.originalImage?.size.height > SCREEN_HEIGHT {
                toVC.guideImageView.contentMode = .ScaleAspectFit
            }
            else{
                toVC.guideImageView.contentMode = .Center
            }
            
            }) { (finished: Bool) -> Void in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
                //隐藏引导动画
                toVC.guideImageViewHidden(true)
        }
    }
}