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
    
    private var url:NSURL
    
    init(url:NSURL) {
        if !["https","http"].contains(url.scheme.lowercaseString) {
            assert(true, "url.scheme must be a HTTP/HTTPS request")
        }
        self.url = url
    }
    
    func performLoadUnderlyingImageAndNotify(){
        if self.underlyingImage != nil{
            return ;
        }
        
        KingfisherManager.sharedManager.downloader.downloadImageWithURL(self.url, options: KingfisherManager.DefaultOptions, progressBlock: { (receivedSize, totalSize) -> () in
            let progress = Float(receivedSize) / Float(totalSize)
            let dict = [
                "progress":progress,
                "photo":self
            ]
            NSNotificationCenter.defaultCenter().postNotificationName(V2Photo.V2PHOTO_PROGRESS_NOTIFICATION, object: dict)
            NSLog("progress : %f", progress)
            
            }){ (image, error, imageURL, originalData) -> () in
                self.underlyingImage = image
                dispatch_sync_safely_main_queue({ () -> () in
                    self.imageLoadingComplete()
                })
        }
    }
    
    func imageLoadingComplete(){
        NSNotificationCenter.defaultCenter().postNotificationName(V2Photo.V2PHOTO_LOADING_DID_END_NOTIFICATION, object: self)
    }
}
