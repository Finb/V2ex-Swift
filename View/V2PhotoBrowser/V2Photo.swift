//
//  V2Photo.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2/22/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import Kingfisher

class V2Photo :NSObject{
    static let V2PHOTO_PROGRESS_NOTIFICATION = "ME.FIN.V2PHOTO_PROGRESS_NOTIFICATION"
    static let V2PHOTO_LOADING_DID_END_NOTIFICATION = "ME.FIN.V2PHOTO_LOADING_DID_END_NOTIFICATION"
    
    var underlyingImage:UIImage?
    
    var url:URL
    
    init(url:URL) {
        
        if let scheme = url.scheme?.lowercased() , !["https","http"].contains(scheme){
            assert(true, "url.scheme must be a HTTP/HTTPS request")
        }
        self.url = url
    }
    
    func performLoadUnderlyingImageAndNotify(){
        if self.underlyingImage != nil{
            return ;
        }
        let resource = ImageResource(downloadURL: self.url)
        KingfisherManager.shared.cache.retrieveImage(forKey: resource.cacheKey, options: nil) { (image, cacheType) -> () in
            if image != nil {
                dispatch_sync_safely_main_queue({ () -> () in
                    self.imageLoadingComplete(image)
                })
            }
            else{
                KingfisherManager.shared.downloader.downloadImage(with: resource.downloadURL, options: nil, progressBlock: { (receivedSize, totalSize) -> () in
                    let progress = Float(receivedSize) / Float(totalSize)
                    let dict = [
                        "progress":progress,
                        "photo":self
                    ] as [String : Any]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: V2Photo.V2PHOTO_PROGRESS_NOTIFICATION), object: dict)
                    }){ (image, error, imageURL, originalData) -> () in
                        
                        dispatch_sync_safely_main_queue({ () -> () in
                            self.imageLoadingComplete(image)
                        })
                        
                        if let image = image {
                            //保存图片缓存
                            KingfisherManager.shared.cache.store(image, original: originalData, forKey: resource.cacheKey, toDisk: true, completionHandler: nil)
                        }
                }
                
                
            }
        }
    }
    
    func imageLoadingComplete(_ image:UIImage?){
        self.underlyingImage = image
        NotificationCenter.default.post(name: Notification.Name(rawValue: V2Photo.V2PHOTO_LOADING_DID_END_NOTIFICATION), object: self)
    }
}
