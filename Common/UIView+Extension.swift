//
//  UIView+Extension.swift
//  V2ex-Swift
//
//  Created by huangfeng on 16/12/14.
//  Copyright © 2016年 Fin. All rights reserved.
//

import UIKit

extension UIView {
    func screenshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, 0);
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: false);
        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return snapshotImage;
    }
}
