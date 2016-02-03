//
//  UIImageView+Extension.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2/3/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import Kingfisher

private var lastURLKey: Void?

extension UIImageView {
    
    public var fin_webURL: NSURL? {
        return objc_getAssociatedObject(self, &lastURLKey) as? NSURL
    }
    
    private func fin_setWebURL(URL: NSURL) {
        objc_setAssociatedObject(self, &lastURLKey, URL, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    func fin_setImageWithUrl (URL: NSURL ,placeholderImage: UIImage?
        ,imageModificationClosure:((image:UIImage) -> UIImage)?){
            
            self.image = placeholderImage
        
            let resource = Resource(downloadURL: URL)
            fin_setWebURL(resource.downloadURL)
            
            let options = KingfisherManager.DefaultOptions
            
            KingfisherManager.sharedManager.cache.retrieveImageForKey(resource.cacheKey, options: options) { (image, cacheType) -> () in
                if image != nil {
                    dispatch_sync_safely_main_queue({ () -> () in
                        self.image = image
                    })
                }
                else {
                    KingfisherManager.sharedManager.downloader.downloadImageWithURL(resource.downloadURL, options: options, progressBlock: nil, completionHandler: { (image, error, imageURL, originalData) -> () in
                        if let error = error where error.code == KingfisherError.NotModified.rawValue {
                            KingfisherManager.sharedManager.cache.retrieveImageForKey(resource.cacheKey, options: KingfisherManager.DefaultOptions, completionHandler: { (cacheImage, cacheType) -> () in
                                self.fin_setImage(cacheImage!, imageURL: imageURL!)
                            })
                            return
                        }
                        
                        if var image = image, let originalData = originalData {
                            //处理图片
                            if let img = imageModificationClosure?(image: image) {
                                image = img
                            }
                            
                            //保存图片缓存
                            KingfisherManager.sharedManager.cache.storeImage(image, originalData: originalData, forKey: resource.cacheKey, toDisk: !KingfisherManager.DefaultOptions.cacheMemoryOnly, completionHandler: nil)
                            self.fin_setImage(image, imageURL: imageURL!)
                        }
                    })
                }
            }
    }
    
    private func fin_setImage(image:UIImage,imageURL:NSURL) {
        
        dispatch_sync_safely_main_queue { () -> () in
            guard imageURL == self.fin_webURL else {
                return
            }
            self.image = image
        }
        
    }
    
}

func fin_defaultImageModification() -> ((image:UIImage) -> UIImage) {
    return { (var image) -> UIImage in
        image = image.roundedCornerImageWithCornerRadius(3)
        return image
    }
}
