//
//  V2SpacingLabel.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/11/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class V2SpacingLabel: UILabel {
    var spacing :CGFloat = 3.0
    override var text: String?{
        set{
            if newValue?.Lenght > 0 {
                let attributedString = NSMutableAttributedString(string: newValue!);
                let paragraphStyle = NSMutableParagraphStyle();
                paragraphStyle.lineBreakMode=NSLineBreakMode.byTruncatingTail;
                paragraphStyle.lineSpacing=self.spacing;
                paragraphStyle.alignment=self.textAlignment;
                attributedString.addAttributes(
                    [
                        NSParagraphStyleAttributeName:paragraphStyle
                    ],
                    range: NSMakeRange(0, newValue!.Lenght));
                super.attributedText = attributedString;
            }
        }
        get{
            return super.text;
        }
    }
}
