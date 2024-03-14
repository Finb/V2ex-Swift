//
//  V2ZoomingScrollView.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2/22/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import Photos
import Kingfisher

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
                self.loadingView.isHidden = false
                self.loadingView.startAnimating()
                self._photo?.performLoadUnderlyingImageAndNotify()
            }
        }
    }
    
    fileprivate var loadingView = UIActivityIndicatorView(style: .white)

    weak var photoBrowser:V2PhotoBrowser?

    init(browser:V2PhotoBrowser){
        super.init(frame: CGRect.zero)
        self.photoImageView.tapDelegate = self
        self.photoImageView.contentMode = .center
        self.photoImageView.backgroundColor = UIColor.clear
        self.addSubview(self.photoImageView)
        
        self.addSubview(self.loadingView)
        self.loadingView.startAnimating()
        self.loadingView.center = browser.view.center
        
        self.delegate = self
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.decelerationRate = UIScrollView.DecelerationRate.fast
        
        NotificationCenter.default.addObserver(self, selector: #selector(V2ZoomingScrollView.loadingDidEndNotification(_:)), name: NSNotification.Name(rawValue: V2Photo.V2PHOTO_LOADING_DID_END_NOTIFICATION), object: nil)
        self.photoBrowser = browser
        self.photoImageView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(imageLongPress)))
        
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.singleTap()
        self.next?.touchesEnded(touches, with: event)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func loadingDidEndNotification(_ notification:Notification){
        self.loadingView.isHidden = true
        self.loadingView.stopAnimating()
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
            self.contentSize = CGSize(width: 0, height: 0)
            
            self.photoImageView.image = image
            
            let photoImageViewFrame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
            self.photoImageView.frame = photoImageViewFrame
            self.contentSize = photoImageViewFrame.size
            
            self.setMaxMinZoomScalesForCurrentBounds()
            
            self.loadingView.isHidden = true
            self.loadingView.stopAnimating()
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
        
        self.photoImageView.frame = CGRect(x: 0, y: 0, width: self.photoImageView.frame.size.width, height: self.photoImageView.frame.size.height);
        
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
        
//        self.zoomScale = self.initialZoomScaleWithMinScale()
        self.zoomScale = self.minimumZoomScale
        
        if self.zoomScale != minScale {
            self.contentOffset = CGPoint(x: (imageSize.width * self.zoomScale - boundsSize.width) / 2.0,
                                             y: (imageSize.height * self.zoomScale - boundsSize.height) / 2.0);
        }
        self.isScrollEnabled = false
        
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
        
        if !(self.photoImageView.frame).equalTo(frameToCenter) {
            self.photoImageView.frame = frameToCenter
        }
        
    }
    
    //MARK: UIScrollViewDelegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.photoImageView
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        self.isScrollEnabled = true
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    func singleTap(){
        self.handelSingleTap()
    }
    func singleTapDetected(_ imageView: UIImageView, touch: UITouch) {
        self.handelSingleTap()
    }
    func handelSingleTap(){
        
        if self.photo?.underlyingImage == nil {
            self.photoBrowser?.dismiss()
        }
        
        // Zoom
        if (self.zoomScale != self.minimumZoomScale && self.zoomScale != self.initialZoomScaleWithMinScale()) {
            
            // Zoom out
            self.setZoomScale(self.minimumZoomScale, animated: true)
            
        }
        else {
            self.photoBrowser?.dismiss()
        }
    }
    
    func doubleTapDetected(_ imageView: UIImageView, touch: UITouch) {
        // Zoom
        if (self.zoomScale != self.minimumZoomScale && self.zoomScale != self.initialZoomScaleWithMinScale()) {
            
            // Zoom out
            self.setZoomScale(self.minimumZoomScale, animated: true)
            
        } else {
            
            let touchPoint = touch.location(in: imageView)
            // Zoom in to twice the size
            let newZoomScale = ((self.maximumZoomScale + self.minimumZoomScale) / 2);
            let xsize = self.bounds.size.width / newZoomScale;
            let ysize = self.bounds.size.height / newZoomScale;
            self.zoom(to: CGRect(x: touchPoint.x - xsize/2, y: touchPoint.y - ysize/2, width: xsize, height: ysize), animated: true)
            
        }

    }
}

extension V2ZoomingScrollView {
    @objc func imageLongPress(sender:UIGestureRecognizer){
        if sender.state == .began {
            
            let controller = UIAlertController(title: "", message: "图片", preferredStyle: .actionSheet)
            controller.addAction(UIAlertAction(title: "保存图片", style: .default, handler: { [weak self] (_) in
                self?.saveImage()
            }))
            controller.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            
            V2Client.sharedInstance.topNavigationController.presentedViewController?.present(controller, animated: true, completion: nil)
            
        }
    }
    @objc private func saveImage(){
        guard let image = photoImageView.image, let photo = self.photo, var imageData:Data = image.pngData() else {
            return
        }

        let resource = KF.ImageResource(downloadURL: photo.url)
        let filePath = KingfisherManager.shared.cache.cachePath(forKey: resource.cacheKey)
        if let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) {
            //拿一下原始Data数据，保存效果更佳~
            imageData = data
        }
        
        func requestAuthorizationCompletion(status:PHAuthorizationStatus) {
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges({
                    let option = PHAssetResourceCreationOptions()
                    let request = PHAssetCreationRequest.forAsset()
                    request.addResource(with: .photo, data: imageData, options: option)
                    request.creationDate = Date()
                }, completionHandler: { (success, error) in
                    if error != nil {
                        V2Error(error?.rawString())
                    }
                    else{
                        V2Success("保存成功")
                    }
                })
            }
            else{
                V2Error("无法保存，无权限访问相册")
            }
        }
        
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { (status) in
                requestAuthorizationCompletion(status: status)
            }
        } else {
            PHPhotoLibrary.requestAuthorization { (status) in
                requestAuthorizationCompletion(status: status)
            }
        }
    }
}
