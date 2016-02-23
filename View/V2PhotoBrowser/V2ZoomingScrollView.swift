//
//  V2ZoomingScrollView.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2/22/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

class V2ZoomingScrollView: UIScrollView ,V2TapDetectingImageViewDelegate , UIScrollViewDelegate{
    var index:Int = Int.max
    var photoImageView:V2TapDetectingImageView = V2TapDetectingImageView()
    
    var _photo:V2Photo?
    var photo:V2Photo? {
        get{
            return self._photo
        }
        set {
            self._photo = newValue
            if let _ = self._photo?.underlyingImage {
                self.displayImage()
            }
            else {
                self._photo?.performLoadUnderlyingImageAndNotify()
            }
        }
    }

    init(browser:V2PhotoBrowser){
        super.init(frame: CGRectZero)
        self.photoImageView.tapDelegate = self
        self.photoImageView.contentMode = .Center
        self.photoImageView.backgroundColor = UIColor.blackColor()
        self.addSubview(self.photoImageView)
        
        self.delegate = self
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.decelerationRate = UIScrollViewDecelerationRateFast
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadingDidEndNotification:", name: V2Photo.V2PHOTO_LOADING_DID_END_NOTIFICATION, object: nil)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadingDidEndNotification(notification:NSNotification){
        if notification.object as? V2Photo == self.photo , let _ = self._photo?.underlyingImage {
            self.displayImage()
        }
    }

    func prepareForReuse(){
        self.photo = nil
        self.photoImageView.image = nil
        self.index = Int.max
    }
    
    func displayImage(){
        if self.photoImageView.image == nil , let image = self.photo?.underlyingImage {
            self.maximumZoomScale = 1
            self.minimumZoomScale = 1
            self.zoomScale = 1
            self.contentSize = CGSizeMake(0, 0)
            
            self.photoImageView.image = image
            
            let photoImageViewFrame = CGRectMake(0, 0, image.size.width, image.size.height)
            self.photoImageView.frame = photoImageViewFrame
            self.contentSize = photoImageViewFrame.size
            
            self.setMaxMinZoomScalesForCurrentBounds()
            
        }
        self.setNeedsLayout()
    }
    
    
    func setMaxMinZoomScalesForCurrentBounds(){
        // Reset
        self.maximumZoomScale = 1
        self.minimumZoomScale = 1
        self.zoomScale = 1
        
        if self.photoImageView.image == nil {
            return
        }
        
        self.photoImageView.frame = CGRectMake(0, 0, self.photoImageView.frame.size.width, self.photoImageView.frame.size.height);
        
        let boundsSize = self.bounds.size;
        let imageSize = self.photoImageView.image!.size
        
        let xScale = boundsSize.width / imageSize.width
        let yScale = boundsSize.height / imageSize.height
        var minScale = min(xScale,yScale)
        let maxScale:CGFloat = 3
        // Image is smaller than screen so no zooming!
        if xScale >= 1 && yScale >= 1 {
           minScale = 1
        }
        
        self.maximumZoomScale = maxScale
        self.minimumZoomScale = minScale
        
        self.zoomScale = self.initialZoomScaleWithMinScale()
        
        if self.zoomScale != minScale {
            self.contentOffset = CGPointMake((imageSize.width * self.zoomScale - boundsSize.width) / 2.0,
                                             (imageSize.height * self.zoomScale - boundsSize.height) / 2.0);
        }
        self.scrollEnabled = false
        
        self.setNeedsLayout()
    }
    
    func initialZoomScaleWithMinScale() -> CGFloat{
        var zoomScale = self.minimumZoomScale
        if self.photoImageView.image != nil {
            let boundsSize = self.bounds.size
            let imageSize = self.photoImageView.image!.size
            let boundsAR = boundsSize.width / boundsSize.height
            let imageAR = imageSize.width / imageSize.height
            let xScale = boundsSize.width / imageSize.width
            let yScale = boundsSize.height / imageSize.height
            
            // Zooms standard portrait images on a 3.5in screen but not on a 4in screen.
            if abs(boundsAR - imageAR) < 0.17 {
                zoomScale = max(xScale, yScale);
                // Ensure we don't zoom in or out too far, just in case
                zoomScale = min(max(self.minimumZoomScale, zoomScale), self.maximumZoomScale);
            }
        }
        return zoomScale
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let boundsSize = self.bounds.size
        var frameToCenter = self.photoImageView.frame
        
        // Horizontally
        if (frameToCenter.size.width < boundsSize.width) {
            let f = Float( (boundsSize.width - frameToCenter.size.width) / CGFloat(2.0) )
            frameToCenter.origin.x = CGFloat( floorf(f) );
        } else {
            frameToCenter.origin.x = 0;
        }
        
        // Vertically
        if (frameToCenter.size.height < boundsSize.height) {
            let f = Float( (boundsSize.height - frameToCenter.size.height) / CGFloat(2.0) )
            frameToCenter.origin.y = CGFloat( floorf(f) );
        } else {
            frameToCenter.origin.y = 0;
        }
        
        if !CGRectEqualToRect(self.photoImageView.frame, frameToCenter) {
            self.photoImageView.frame = frameToCenter
        }
        
    }
    
    //MARK: UIScrollViewDelegate
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.photoImageView
    }
    
    func scrollViewWillBeginZooming(scrollView: UIScrollView, withView view: UIView?) {
        self.scrollEnabled = true
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    func singleTapDetected(imageView: UIImageView, touch: UITouch) {
        // Zoom
        if (self.zoomScale != self.minimumZoomScale && self.zoomScale != self.initialZoomScaleWithMinScale()) {
            
            // Zoom out
            self.setZoomScale(self.minimumZoomScale, animated: true)
            
        }
    }
    
    func doubleTapDetected(imageView: UIImageView, touch: UITouch) {
        // Zoom
        if (self.zoomScale != self.minimumZoomScale && self.zoomScale != self.initialZoomScaleWithMinScale()) {
            
            // Zoom out
            self.setZoomScale(self.minimumZoomScale, animated: true)
            
        } else {
            
            let touchPoint = touch.locationInView(imageView)
            // Zoom in to twice the size
            let newZoomScale = ((self.maximumZoomScale + self.minimumZoomScale) / 2);
            let xsize = self.bounds.size.width / newZoomScale;
            let ysize = self.bounds.size.height / newZoomScale;
            self.zoomToRect(CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize), animated: true)
            
        }

    }
}
