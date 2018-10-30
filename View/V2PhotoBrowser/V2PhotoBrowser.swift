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
//import INSImageView

@objc protocol V2PhotoBrowserDelegate {
    func numberOfPhotosInPhotoBrowser(_ photoBrowser:V2PhotoBrowser) -> Int
    func photoAtIndexInPhotoBrowser(_ photoBrowser:V2PhotoBrowser, index:Int) -> V2Photo
    
    /**
     引导动画的Image
     */
    func guideImageInPhotoBrowser(_ photoBrowser:V2PhotoBrowser, index:Int) -> UIImage?
    /**
     引导动画的ContentMode
     */
    func guideContentModeInPhotoBrowser(_ photoBrowser:V2PhotoBrowser, index:Int) -> UIViewContentMode
    /**
     引导动画在window上的位置
     */
    func guideFrameInPhotoBrowser(_ photoBrowser:V2PhotoBrowser, index:Int) -> CGRect
}


class V2PhotoBrowser: UIViewController ,UIScrollViewDelegate ,UIViewControllerTransitioningDelegate {
    static let PADDING:CGFloat = 10
    
    /// 引导guideImageView，用于引导进入动画和退出动画
    var guideImageView:INSImageView = INSImageView()
    
    weak var delegate:V2PhotoBrowserDelegate?
    
    fileprivate var  photoCount = NSNotFound
    fileprivate var photos:[NSObject] = []
    
    fileprivate var _currentPageIndex = 0
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
    
    fileprivate var visiblePages:NSMutableSet = []
    fileprivate var recycledPages:NSMutableSet = []
    var pagingScrollView = UIScrollView()
    
    var transitionController = V2PhotoBrowserSwipeInteractiveTransition()
    
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
        
        self.pagingScrollView.isPagingEnabled = true
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
        self.pagingScrollView.isHidden = true
        

        self.guideImageView.clipsToBounds = true
        self.view.addSubview(self.guideImageView)
        
        self.reloadData()
        
        self.jumpPageAtIndex(self.currentPageIndex)
        
    }
    
    
    override func viewDidLoad() {
        self.transitionController.browser = self
        self.transitionController.prepareGestureRecognizerInView(self.view)
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.transitionController.interacting ? self.transitionController : nil
    }
    
    override var prefersStatusBarHidden: Bool{
        get {
            return self.isAppeared
        }
    }
    var isAppeared = false
    override func viewDidAppear(_ animated: Bool) {
        isAppeared = true
        self.setNeedsStatusBarAppearanceUpdate()
    }
    func dismiss(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func jumpPageAtIndex(_ index:Int){
        if self.isViewLoaded {
            let pageFrame = self.frameForPageAtIndex(_currentPageIndex)
            self.pagingScrollView.setContentOffset(CGPoint(x: pageFrame.origin.x - V2PhotoBrowser.PADDING, y: 0), animated: false)
        }
    }
    
    func guideImageViewHidden(_ hidden:Bool){
        if hidden {
            self.guideImageView.isHidden = true
            self.pagingScrollView.isHidden = false
        }
        else {
            if self.guideImageView.originalImage != nil{
                //隐藏引导动画图
                self.guideImageView.isHidden = false
                
                //隐藏真正的图片浏览器,等引导动画完后再显示
                self.pagingScrollView.isHidden = true
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
        return CGSize(width: bounds.size.width * CGFloat(self.numberOfPhotos()), height: bounds.size.height)
    }
    
    func frameForPageAtIndex(_ index:Int) -> CGRect{
        let bounds = self.pagingScrollView.bounds
        var pageFrame = bounds
        pageFrame.size.width -= (2 * V2PhotoBrowser.PADDING);
        pageFrame.origin.x = (bounds.size.width * CGFloat(index) ) + V2PhotoBrowser.PADDING;
        return pageFrame.integral;
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
    
    func photoAtIndex(_ index:Int) -> V2Photo? {
        if index < self.photos.count {
            if self.photos[index].isKind(of: NSNull.self) {
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
        for _ in 0 ..< numberOfPhotos {
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
        var iFirstIndex = Int( floorf( Float( (visibleBounds.minX + V2PhotoBrowser.PADDING * 2) / visibleBounds.width ) ) );
        var iLastIndex = Int( floorf( Float( (visibleBounds.maxX - V2PhotoBrowser.PADDING * 2 - 1) / visibleBounds.width ) ) );
        iFirstIndex = max(0,iFirstIndex)
        iFirstIndex = min (self.numberOfPhotos() - 1,iFirstIndex)
        iLastIndex = max(0,iLastIndex)
        iLastIndex = min (self.numberOfPhotos() - 1,iLastIndex)
        var pageIndex = 0
        for page in self.visiblePages {
            if let page = page as? V2ZoomingScrollView {
                pageIndex = page.index
                if pageIndex < iFirstIndex || pageIndex > iLastIndex {
                    self.recycledPages.add(page)
                    page.prepareForReuse()
                    page.removeFromSuperview()
                }
            }
        }
        
        self.visiblePages.minus(self.recycledPages as Set<NSObject>)
        
        while self.recycledPages.count > 2 {
            self.recycledPages.remove(self.recycledPages.anyObject()!)
        }
        
        for index in iFirstIndex ... iLastIndex {
            if !self.isDisplayingPageForIndex(index) {
                var page = self.dequeueRecycledPage()
                if page == nil {
                    page = V2ZoomingScrollView(browser: self)
                }
                
                self.configurePage(page!, index: index)
                self.visiblePages.add(page!)
                
                self.pagingScrollView.addSubview(page!)
            }
        }
        
    }
    func isDisplayingPageForIndex(_ index:Int) -> Bool {
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
            self.recycledPages.remove(page)
            return page
        }
        return nil
    }
    
    func configurePage(_ page:V2ZoomingScrollView,index:Int){
        page.frame = self.frameForPageAtIndex(index)
        page.index = index
        page.photo = self.photoAtIndex(index)
    }
    
    
    //MARK: UIScrollView Delegate 
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.tilePages()
        
        let visibleBounds = self.pagingScrollView.bounds
        var index = Int ( floorf( Float(visibleBounds.midX / visibleBounds.width) ) )
        index = max (0,index)
        index = min(self.numberOfPhotos() - 1 , index)
        self._currentPageIndex = index
    }
    
    
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return V2PhotoBrowserTransionPresent()
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return V2PhotoBrowserTransionDismiss()
    }
}



