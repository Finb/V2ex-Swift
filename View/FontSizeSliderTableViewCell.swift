//
//  FontSizeSliderTableViewCell.swift
//  V2ex-Swift
//
//  Created by huangfeng on 3/10/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

class FontSizeSliderTableViewCell: UITableViewCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        self.setup();
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func setup() {
        self.selectionStyle = .None
        
        let leftLabel = UILabel()
        leftLabel.font = v2Font(14 * 0.8)
        leftLabel.text = "A"
        leftLabel.textAlignment = .Center
        self.contentView.addSubview(leftLabel)
        leftLabel.snp_makeConstraints{ (make) -> Void in
            make.centerY.equalTo(self.contentView)
            make.width.height.equalTo(30)
            make.left.equalTo(self.contentView)
        }
        
        let rightLabel = UILabel()
        rightLabel.font = v2Font(14 * 1.6)
        rightLabel.text = "A"
        rightLabel.textAlignment = .Center
        self.contentView.addSubview(rightLabel)
        rightLabel.snp_makeConstraints{ (make) -> Void in
            make.centerY.equalTo(self.contentView)
            make.width.height.equalTo(30)
            make.right.equalTo(self.contentView)
        }
        
        let slider = V2Slider()
        slider.valueChanged = { (fontSize) in
            let size = fontSize * 0.05 + 0.8
            if V2Style.sharedInstance.fontScale != size {
                V2Style.sharedInstance.fontScale = size
            }
        }
        self.contentView.addSubview(slider)
        slider.snp_makeConstraints{ (make) -> Void in
            make.left.equalTo(leftLabel.snp_right)
            make.right.equalTo(rightLabel.snp_left)
            make.centerY.equalTo(self.contentView)
        }
        
        let topSeparator = UIImageView()
        self.contentView.addSubview(topSeparator)
        topSeparator.snp_makeConstraints{ (make) -> Void in
            make.left.right.top.equalTo(self.contentView)
            make.height.equalTo(SEPARATOR_HEIGHT)
        }
        
        let bottomSeparator = UIImageView()
        self.contentView.addSubview(bottomSeparator)
        bottomSeparator.snp_makeConstraints{ (make) -> Void in
            make.left.right.bottom.equalTo(self.contentView)
            make.height.equalTo(SEPARATOR_HEIGHT)
        }
        
        self.KVOController.observe(V2EXColor.sharedInstance, keyPath: "style", options: [.Initial,.New]) {_ in
            self.backgroundColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
            leftLabel.textColor = V2EXColor.colors.v2_TopicListTitleColor
            rightLabel.textColor = V2EXColor.colors.v2_TopicListTitleColor
            topSeparator.image = createImageWithColor( V2EXColor.colors.v2_SeparatorColor )
            bottomSeparator.image = topSeparator.image
        }
    }
}
