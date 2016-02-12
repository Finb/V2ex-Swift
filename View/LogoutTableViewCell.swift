//
//  LogoutTableViewCell.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2/12/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

class LogoutTableViewCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        self.setup();
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setup()->Void{
        
        self.textLabel!.text = "注销当前账号"
        self.textLabel!.textAlignment = .Center
        self.textLabel!.textColor = colorWith255RGB(207, g: 70, b: 71)
        
        let separator = UIImageView(image: createImageWithColor(colorWith255RGB(190, g: 190, b: 190)))
        self.contentView.addSubview(separator)
        separator.snp_makeConstraints{ (make) -> Void in
            make.left.equalTo(self.contentView)
            make.right.bottom.equalTo(self.contentView)
            make.height.equalTo(SEPARATOR_HEIGHT)
        }
    }
}
