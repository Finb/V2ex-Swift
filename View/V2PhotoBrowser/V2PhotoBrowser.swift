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
    
    /**
     引导动画的Image
     */
    func guideImageInPhotoBrowser(photoBrowser:V2PhotoBrowser, index:Int) -> UIImage?
    /**
     引导动画的ContentMode
     */
    func guideContentModeInPhotoBrowser(photoBrowser:V2PhotoBrowser, index:Int) -> UIViewContentMode
    /**
     引导动画在window上的位置
     */
    func guideFrameInPhotoBrowser(photoBrowser:V2PhotoBrowser, index:Int) -> CGRect
}


class V2PhotoBrowser: UIViewController ,UIScrollViewDelegate ,UIViewControllerTransitioningDelegate {
    static let PADDING:CGFloat = 10
    
    /// 引导guideImageView，用于引导进入动画和退出动画
    private var guideImageView:INSImageView = INSImageView()
    
    weak var delegate:V2PhotoBrowserDelegate?
    
    private var  photoCount = NSNotFound
    private var photos:[NSObject] = []
    
    private var _currentPageIndex = 0
    var currentPageIndex:Int {
        get {
            return _currentPageIndex
        }
        set {
            if _currentPageIndex == newValue || newValue < 0 || newValue >= self.numberOfPhotos() {
                return
            }
            _currentPageIndex = newValue
            self.jumpPageAtIndex(_currentPageIndex)
        }
    }
    
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
        self.view.backgroundColor = UIColor(white: 0, alpha: 0)
        self.transitioningDelegate = self
        
        self.pagingScrollView.pagingEnabled = true
        self.pagingScrollView.delegate = self
        self.pagingScrollView.showsHorizontalScrollIndicator = false
        self.pagingScrollView.showsVerticalScrollIndicator = false
        self.pagingScrollView.contentSize = self.contentSizeForPagingScrollView()
        self.view.addSubview(self.pagingScrollView)
        
        var frame = self.view.bounds
        frame.origin.x -= V2PhotoBrowser.PADDING
        frame.size.width += 2 * V2PhotoBrowser.PADDING
        self.pagingScrollView.frame = frame
        self.pagingScrollView.contentSize = self.contentSizeForPagingScrollView()
        
        /// 一进来时，是隐藏，等引导动画结束时再显示
        self.pagingScrollView.hidden = true
        

        self.guideImageView.clipsToBounds = true
        self.view.addSubview(self.guideImageView)
        
        self.reloadData()
        
        self.jumpPageAtIndex(self.currentPageIndex)
        
    }
    
    override func viewDidLoad() {
     
    }
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
    }
    override func viewWillDisappear(animated: Bool) {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
    }
    func dismiss(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func jumpPageAtIndex(index:Int){
        if self.isViewLoaded() {
            let pageFrame = self.frameForPageAtIndex(_currentPageIndex)
            self.pagingScrollView.setContentOffset(CGPointMake(pageFrame.origin.x - V2PhotoBrowser.PADDING, 0), animated: false)
        }
    }
    
    func guideImageViewHidden(hidden:Bool){
        if hidden {
            self.guideImageView.hidden = true
            self.pagingScrollView.hidden = false
        }
        else {
            if self.guideImageView.originalImage != nil{
                //隐藏引导动画图
                self.guideImageView.hidden = false
                
                //隐藏真正的图片浏览器,等引导动画完后再显示
                self.pagingScrollView.hidden = true
            }
            else {
                //如果没有图片，则直接显示真正的图片浏览器
                self.guideImageViewHidden(true)
            }
        }
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
            self._currentPageIndex = max(0, min(self._currentPageIndex, numberOfPhotos - 1));
        } else {
            self._currentPageIndex = 0;
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
        self._currentPageIndex = index
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
        
        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            fromVC.view.backgroundColor = UIColor(white: 0, alpha: 0)

            //如果guideImageView是隐藏的，则证明图片没有加载完不能显示，则渐变隐藏整个browser
            if fromVC.guideImageView.hidden {
                fromVC.pagingScrollView.alpha = 0
            }
            else{
                if let delegate = fromVC.delegate {
                    fromVC.guideImageView.frame = delegate.guideFrameInPhotoBrowser(fromVC, index: fromVC.currentPageIndex)
                    fromVC.guideImageView.contentMode = delegate.guideContentModeInPhotoBrowser(fromVC, index: fromVC.currentPageIndex)
                }
            }
            
            }) { (finished: Bool) -> Void in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
}
