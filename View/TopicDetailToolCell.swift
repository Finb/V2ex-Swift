//
//  TopicDetailToolCell.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2018/12/6.
//  Copyright © 2018 Fin. All rights reserved.
//

import UIKit

class TopicDetailToolCell: UITableViewCell {
    var titleLabel:UILabel = {
        let label = UILabel()
        label.font = v2Font(12)
        return label
    }()
    
    var separator:UIImageView = UIImageView()
    let sortButton:V2HitTestSlopButton = {
        let btn = V2HitTestSlopButton()
        btn.titleLabel?.font = v2Font(12)
        btn.setTitleColor(V2EXColor.colors.v2_TopicListTitleColor, for: .normal)
        btn.hitTestSlop = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
        btn.titleLabel?.textAlignment = .left
        return btn
    }()
    var sortButtonClick:((_ sender:UIButton) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        self.setup();
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup() {
        self.selectionStyle = .none
        
        self.contentView.addSubview(sortButton)
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.separator)
        
        sortButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(12)
        }
        
        self.titleLabel.snp.makeConstraints{ (make) -> Void in
            make.left.equalTo(self.sortButton.snp.right).offset(8)
            make.centerY.equalTo(self.contentView)
        }
        self.separator.snp.makeConstraints{ (make) -> Void in
            make.left.right.bottom.equalTo(self.contentView)
            make.height.equalTo(SEPARATOR_HEIGHT)
        }
        
        self.themeChangedHandler = {[weak self] (style) -> Void in
            self?.backgroundColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
            self?.titleLabel.textColor = V2EXColor.colors.v2_TopicListTitleColor
            self?.separator.image = createImageWithColor(V2EXColor.colors.v2_backgroundColor)
        }
        
        self.sortButton.addTarget(self, action: #selector(sortClick(sender:)), for: .touchUpInside)
    }
    
    @objc func sortClick(sender:UIButton){
        sortButtonClick?(sender)
    }
}
