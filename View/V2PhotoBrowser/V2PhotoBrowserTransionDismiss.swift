//
//  V2PhotoBrowserTransionDismiss.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2/26/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

class V2PhotoBrowserTransionDismiss:NSObject,UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        let fromVC = transitionContext!.viewController(forKey: UITransitionContextViewControllerKey.from) as! V2PhotoBrowser
        if fromVC.transitionController.interacting {
            return 0.8
        }
        else{
            return 0.3
        }
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! V2PhotoBrowser
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        
        let container = transitionContext.containerView
        container.addSubview(toVC.view)
        container.bringSubviewToFront(fromVC.view)
        
        
        if let delegate = fromVC.delegate ,let image = delegate.guideImageInPhotoBrowser(fromVC, index: fromVC.currentPageIndex) {
            fromVC.guideImageView.image = image
            //如果图片过小，则直接中间原图显示 ，否则fit
            if (fromVC.guideImageView.originalImage?.size.width)! > SCREEN_WIDTH || (fromVC.guideImageView.originalImage?.size.height)! > SCREEN_HEIGHT {
                fromVC.guideImageView.contentMode = .scaleAspectFit
            }
            else{
                fromVC.guideImageView.contentMode = .center
            }
            
            //重布局一下，因为有可能左右切换图片隐藏时 布局不对
            fromVC.guideImageView.setNeedsLayout()
            fromVC.guideImageView.layoutIfNeeded()
        }
        
        //显示引导动画，隐藏真正的照片浏览器
        //如果引导动画的图片没有加载完或加载失败，则显示真正的照片浏览器 渐变隐藏它
        fromVC.guideImageViewHidden(false)
        
        let animations = { () -> Void in
            fromVC.view.backgroundColor = UIColor(white: 0, alpha: 0)
            //如果guideImageView是隐藏的，则证明图片没有加载完不能显示，则渐变隐藏整个browser
            if fromVC.guideImageView.isHidden {
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
                    if fromVC.transitionController.direction == .downwards {
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
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
        let  options = fromVC.transitionController.interacting ? UIView.AnimationOptions.curveLinear : UIView.AnimationOptions()
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: options, animations: animations, completion: completion)
    }

}


