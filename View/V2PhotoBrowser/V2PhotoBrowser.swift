//
//  V2PhotoBrowser.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2/22/16.
//  Copyright © 2016 Fin. All rights reserved.
//
//此部分代码实现参考了
//https://github.com/mwaterfall/MWPhotoBrowser

import UIKit
import INSImageView

@objc protocol V2PhotoBrowserDelegate {
    func numberOfPhotosInPhotoBrowser(photoBrowser:V2PhotoBrowser) -> Int
    func photoAtIndexInPhotoBrowser(photoBrowser:V2PhotoBrowser, index:Int) -> V2Photo
    
    func guideImageInPhotoBrowser(photoBrowser:V2PhotoBrowser, index:Int) -> UIImage?
    func guideContentModeInPhotoBrowser(photoBrowser:V2PhotoBrowser, index:Int) -> UIViewContentMode
    func guideFrameInPhotoBrowser(photoBrowser:V2PhotoBrowser, index:Int) -> CGRect
}


class V2PhotoBrowser: UIViewController ,UIScrollViewDelegate ,UIViewControllerTransitioningDelegate {
    static let PADDING:CGFloat = 10
    
    /// 引导guideImageView，用于引导进入动画和退出动画
    private var guideImageView:INSImageView = INSImageView()
    
    weak var delegate:V2PhotoBrowserDelegate?
    
    private var  photoCount = NSNotFound
    private var photos:[NSObject] = []
    var currentPageIndex = 0
    
    private var visiblePages:NSMutableSet = []
    private var recycledPages:NSMutableSet = []
    private var pagingScrollView = UIScrollView()
    
    
    init(delegate:V2PhotoBrowserDelegate){
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setup(){
        self.transitioningDelegate = self
        
        self.pagingScrollView.pagingEnabled = true
        self.pagingScrollView.delegate = self
        self.pagingScrollView.showsHorizontalScrollIndicator = false
        self.pagingScrollView.showsVerticalScrollIndicator = false
        self.pagingScrollView.backgroundColor = UIColor(white: 0, alpha: 0)
        self.pagingScrollView.contentSize = self.contentSizeForPagingScrollView()
        self.view.addSubview(self.pagingScrollView)
        
        self.guideImageView.clipsToBounds = true
        self.view.addSubview(self.guideImageView)
        
    }
    
    override func viewDidLoad() {
        self.layoutSubviews()
    }
    
    func dismiss(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func layoutSubviews() {
        var frame = self.view.bounds
        frame.origin.x -= V2PhotoBrowser.PADDING
        frame.size.width += 2 * V2PhotoBrowser.PADDING
        self.pagingScrollView.frame = frame
        self.pagingScrollView.contentSize = self.contentSizeForPagingScrollView()
    }
    
    //MARK: Frame Calculations
    
    func contentSizeForPagingScrollView() -> CGSize {
        let bounds = self.pagingScrollView.bounds
        return CGSizeMake(bounds.size.width * CGFloat(self.numberOfPhotos()), bounds.size.height)
    }
    
    func frameForPageAtIndex(index:Int) -> CGRect{
        let bounds = self.pagingScrollView.bounds
        var pageFrame = bounds
        pageFrame.size.width -= (2 * V2PhotoBrowser.PADDING);
        pageFrame.origin.x = (bounds.size.width * CGFloat(index) ) + V2PhotoBrowser.PADDING;
        return CGRectIntegral(pageFrame);
    }
    
    //MARK: Data 
    func numberOfPhotos() -> Int {
        if self.photoCount == NSNotFound {
            if let delegate = self.delegate {
                self.photoCount = delegate.numberOfPhotosInPhotoBrowser(self)
            }
        }
        if self.photoCount == NSNotFound {
            self.photoCount = 0
        }
        return self.photoCount
    }
    
    func photoAtIndex(index:Int) -> V2Photo? {
        if index < self.photos.count {
            if self.photos[index].isKindOfClass(NSNull.self) {
                if let delegate = self.delegate {
                    let photo = delegate.photoAtIndexInPhotoBrowser(self, index: index)
                    self.photos[index] = photo
                    return photo
                }
            }
            else {
                return self.photos[index] as? V2Photo
            }
        }
        return nil
    }
    
    func reloadData(){
        self.photoCount = NSNotFound
        
        let numberOfPhotos = self.numberOfPhotos()
        self.photos = []
        for var i = 0; i < numberOfPhotos; i++ {
            self.photos.append(NSNull())
        }
        
        // Update current page index
        if (numberOfPhotos > 0) {
            self.currentPageIndex = max(0, min(self.currentPageIndex, numberOfPhotos - 1));
        } else {
            self.currentPageIndex = 0;
        }
        
        while self.pagingScrollView.subviews.count > 0 {
            self.pagingScrollView.subviews.last?.removeFromSuperview()
        }
        
        self.tilePages()
        
    }
    
    //MARK: Perform
    func tilePages(){
        let visibleBounds = self.pagingScrollView.bounds
        var iFirstIndex = Int( floorf( Float( (CGRectGetMinX(visibleBounds) + V2PhotoBrowser.PADDING * 2) / CGRectGetWidth(visibleBounds) ) ) );
        var iLastIndex = Int( floorf( Float( (CGRectGetMaxX(visibleBounds) - V2PhotoBrowser.PADDING * 2 - 1) / CGRectGetWidth(visibleBounds) ) ) );
        iFirstIndex = max(0,iFirstIndex)
        iFirstIndex = min (self.numberOfPhotos() - 1,iFirstIndex)
        iLastIndex = max(0,iLastIndex)
        iLastIndex = min (self.numberOfPhotos() - 1,iLastIndex)
        var pageIndex = 0
        for page in self.visiblePages {
            if let page = page as? V2ZoomingScrollView {
                pageIndex = page.index
                if pageIndex < iFirstIndex || pageIndex > iLastIndex {
                    self.recycledPages.addObject(page)
                    page.prepareForReuse()
                    page.removeFromSuperview()
                }
            }
        }
        
        self.visiblePages.minusSet(self.recycledPages as Set<NSObject>)
        
        while self.recycledPages.count > 2 {
            self.recycledPages.removeObject(self.recycledPages.anyObject()!)
        }
        
        for var index = iFirstIndex ; index <= iLastIndex ;index++ {
            if !self.isDisplayingPageForIndex(index) {
                var page = self.dequeueRecycledPage()
                if page == nil {
                    page = V2ZoomingScrollView(browser: self)
                }
                
                self.configurePage(page!, index: index)
                self.visiblePages.addObject(page!)
                
                self.pagingScrollView.addSubview(page!)
            }
        }
        
    }
    func isDisplayingPageForIndex(index:Int) -> Bool {
        for page in self.visiblePages {
            if  let page = page as? V2ZoomingScrollView  {
                if page.index == index {
                    return true
                }
            }
        }
        return false
    }
    
    func dequeueRecycledPage() -> V2ZoomingScrollView? {
        if let page = self.recycledPages.anyObject() as? V2ZoomingScrollView {
            self.recycledPages.removeObject(page)
            return page
        }
        return nil
    }
    
    func configurePage(page:V2ZoomingScrollView,index:Int){
        page.frame = self.frameForPageAtIndex(index)
        page.index = index
        page.photo = self.photoAtIndex(index)
    }
    
    
    //MARK: UIScrollView Delegate 
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.tilePages()
        
        let visibleBounds = self.pagingScrollView.bounds
        var index = Int ( floorf( Float(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)) ) )
        index = max (0,index)
        index = min(self.numberOfPhotos() - 1 , index)
        self.currentPageIndex = index
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return V2PhotoBrowserTransionPresent()
    }
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return V2PhotoBrowserTransionDismiss()
    }
}

class V2PhotoBrowserTransionPresent:NSObject,UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3
    }
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! V2PhotoBrowser
        let container = transitionContext.containerView()
        container!.addSubview(toVC.view)
        if let delegate = toVC.delegate{
            toVC.guideImageView.frame = delegate.guideFrameInPhotoBrowser(toVC, index: toVC.currentPageIndex)
            
            toVC.guideImageView.image = delegate.guideImageInPhotoBrowser(toVC, index: toVC.currentPageIndex)
            
            toVC.guideImageView.contentMode = delegate.guideContentModeInPhotoBrowser(toVC, index: toVC.currentPageIndex)
        }
    
    
        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            toVC.pagingScrollView.backgroundColor = UIColor(white: 0, alpha: 1)
            toVC.guideImageView.frame = toVC.view.bounds
            if toVC.guideImageView.originalImage?.size.width > SCREEN_WIDTH || toVC.guideImageView.originalImage?.size.height > SCREEN_HEIGHT {
                toVC.guideImageView.contentMode = .ScaleAspectFit
            }
            else{
                toVC.guideImageView.contentMode = .Center
            }
            }) { (finished: Bool) -> Void in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
                toVC.reloadData()
                toVC.guideImageView.hidden = true
        }
    }
}

class V2PhotoBrowserTransionDismiss:NSObject,UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3
    }
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! V2PhotoBrowser
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!

        let container = transitionContext.containerView()
        container!.addSubview(toVC.view)
        container!.bringSubviewToFront(fromVC.view)
        
        fromVC.guideImageView.hidden = false
        
        while fromVC.pagingScrollView.subviews.count > 0 {
            fromVC.pagingScrollView.subviews.last?.removeFromSuperview()
        }
        
        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            fromVC.pagingScrollView.backgroundColor = UIColor(white: 0, alpha: 0)
            if let delegate = fromVC.delegate{
                fromVC.guideImageView.frame = delegate.guideFrameInPhotoBrowser(fromVC, index: fromVC.currentPageIndex)
                
                fromVC.guideImageView.image = delegate.guideImageInPhotoBrowser(fromVC, index: fromVC.currentPageIndex)
                
                fromVC.guideImageView.contentMode = delegate.guideContentModeInPhotoBrowser(fromVC, index: fromVC.currentPageIndex)
            }
            
            }) { (finished: Bool) -> Void in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
}
