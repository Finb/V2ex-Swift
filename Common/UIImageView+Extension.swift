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
        
            let resource = KF.ImageResource(downloadURL: URL)
            fin_setWebURL(resource.downloadURL)
            KingfisherManager.shared.cache.retrieveImage(forKey: resource.cacheKey, options: nil) { result -> () in
                let image = try? result.get().image
                if image != nil {
                    dispatch_sync_safely_main_queue({ () -> () in
                        self.image = image
                    })
                }
                else {
                    KingfisherManager.shared.downloader.downloadImage(with: resource.downloadURL, options: nil, progressBlock: nil, completionHandler: { (result) -> () in
                        
                        switch result {
                        case .success(let imageResult):
                            let originalData = imageResult.originalData
                            let imageURL = imageResult.url
                            var image = imageResult.image
                            //处理图片
                            if let img = imageModificationClosure?(image) {
                                image = img
                            }
                            
                            //保存图片缓存
                            KingfisherManager.shared.cache.store(image, original: originalData, forKey: resource.cacheKey, toDisk: true, completionHandler: nil)
                            self.fin_setImage(image, imageURL: imageURL!)
                        case .failure:
                            break
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
