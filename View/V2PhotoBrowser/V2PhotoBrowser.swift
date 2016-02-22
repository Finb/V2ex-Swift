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

@objc protocol V2PhotoBrowserDelegate {
    func numberOfPhotosInPhotoBrowser(photoBrowser:V2PhotoBrowser) -> Int
    func photoAtIndex(photoBrowser:V2PhotoBrowser, index:Int) -> V2Photo
    
}


class V2PhotoBrowser: UIView ,UIScrollViewDelegate {
    static let PADDING:CGFloat = 10
    
    weak var delegate:V2PhotoBrowserDelegate?
    
    private var  photoCount = NSNotFound
    private var photos:[NSObject] = []
    private var currentPageIndex = 0
    
    private var visiblePages:NSMutableSet = []
    private var recycledPages:NSMutableSet = []
    private var pagingScrollView = UIScrollView()
    
    
    init(delegate:V2PhotoBrowserDelegate){
        self.delegate = delegate
        super.init(frame: CGRectZero)
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setup(){
        self.pagingScrollView.pagingEnabled = true
        self.pagingScrollView.delegate = self
        self.pagingScrollView.showsHorizontalScrollIndicator = false
        self.pagingScrollView.showsVerticalScrollIndicator = false
        self.pagingScrollView.backgroundColor = UIColor.blackColor()
        self.pagingScrollView.contentSize = self.contentSizeForPagingScrollView()
        self.addSubview(self.pagingScrollView)
        self.reloadData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var frame = self.bounds
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
                    let photo = delegate.photoAtIndex(self, index: index)
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
        self.setNeedsLayout()
        
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
                    NSLog("removed: %i", pageIndex)
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
}
