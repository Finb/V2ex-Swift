//
//  V2SpacingLabel.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/11/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

class V2SpacingLabel: UILabel {
    var spacing :CGFloat = 3.0
    override var text: String?{
        set{
            if let len = newValue?.Lenght, len > 0 {
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
