//
//  UIImage+Extension.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2/3/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

extension UIImage {
    
    func roundedCornerImageWithCornerRadius(var cornerRadius:CGFloat) -> UIImage {
        
        let w = self.size.width
        let h = self.size.height
        
        if cornerRadius < 0 {
            cornerRadius = 0
        }
        if cornerRadius > min(w, h) {
            cornerRadius = min(w,h)
        }
        
        let imageFrame = CGRectMake(0, 0, w, h)
        UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.mainScreen().scale)
        
        UIBezierPath(roundedRect: imageFrame, cornerRadius: cornerRadius).addClip()
        self.drawInRect(imageFrame)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }
    
    class func imageUsedTemplateMode(named:String) -> UIImage? {
        let image = UIImage(named: named)
        if image == nil {
            return nil
        }
        return image!.imageWithRenderingMode(.AlwaysTemplate)
    }
}
