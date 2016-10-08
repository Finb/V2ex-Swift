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
    
    public var fin_webURL: URL? {
        return objc_getAssociatedObject(self, &lastURLKey) as? URL
    }
    
    fileprivate func fin_setWebURL(_ URL: Foundation.URL) {
        objc_setAssociatedObject(self, &lastURLKey, URL, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    func fin_setImageWithUrl (_ URL: Foundation.URL ,placeholderImage: UIImage? = nil
        ,imageModificationClosure:((_ image:UIImage) -> UIImage)? = nil){
            
            self.image = placeholderImage
        
            let resource = ImageResource(downloadURL: URL)
            fin_setWebURL(resource.downloadURL)
            KingfisherManager.shared.cache.retrieveImage(forKey: resource.cacheKey, options: nil) { (image, cacheType) -> () in
                if image != nil {
                    dispatch_sync_safely_main_queue({ () -> () in
                        self.image = image
                    })
                }
                else {
                    KingfisherManager.shared.downloader.downloadImage(with: resource.downloadURL, options: nil, progressBlock: nil, completionHandler: { (image, error, imageURL, originalData) -> () in
                        if let error = error , error.code == KingfisherError.notModified.rawValue {
                            KingfisherManager.shared.cache.retrieveImage(forKey: resource.cacheKey, options: nil, completionHandler: { (cacheImage, cacheType) -> () in
                                self.fin_setImage(cacheImage!, imageURL: imageURL!)
                            })
                            return
                        }
                        
                        if var image = image, let originalData = originalData {
                            //处理图片
                            if let img = imageModificationClosure?(image) {
                                image = img
                            }
                            
                            //保存图片缓存
                            KingfisherManager.shared.cache.store(image, original: originalData, forKey: resource.cacheKey, toDisk: true, completionHandler: nil)
                            self.fin_setImage(image, imageURL: imageURL!)
                        }
                    })
                }
            }
    }
    
    fileprivate func fin_setImage(_ image:UIImage,imageURL:URL) {
        
        dispatch_sync_safely_main_queue { () -> () in
            guard imageURL == self.fin_webURL else {
                return
            }
            self.image = image
        }
        
    }
    
}

func fin_defaultImageModification() -> ((_ image:UIImage) -> UIImage) {
    return { ( image) -> UIImage in
        let roundedImage = image.roundedCornerImageWithCornerRadius(3)
        return roundedImage
    }
}
