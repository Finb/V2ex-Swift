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
        self.backgroundColor = V2EXColor.colors.v2_CellWhiteBackgroundColor

        self.textLabel!.text = "注销当前账号"
        self.textLabel!.textAlignment = .center
        self.textLabel!.textColor = V2EXColor.colors.v2_NoticePointColor
        
        let separator = UIImageView(image: createImageWithColor(V2EXColor.colors.v2_SeparatorColor))
        self.contentView.addSubview(separator)
        separator.snp.makeConstraints{ (make) -> Void in
            make.left.equalTo(self.contentView)
            make.right.bottom.equalTo(self.contentView)
            make.height.equalTo(SEPARATOR_HEIGHT)
        }
    }
}
