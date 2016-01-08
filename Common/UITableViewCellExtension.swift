//
//  UITableViewCellExtension.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/8/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import Foundation

extension UITableViewCell {
    func Identifier() -> NSString {
        return "\(self.classForCoder)";
    }
}
