//
//  NodeTableViewCell.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2/2/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

class NodeTableViewCell: UITableViewCell {
    /// 节点间的 间距
    static let nodeSpacing:CGFloat = 15
    /// 离屏幕左侧和右侧的 间距
    static let leftAndRightSpacing:CGFloat = 15
    
    static let fontSize:CGFloat = 15
    
    var labelArray:[UILabel] = []
    
    var nodes:[NodeModel]?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        self.selectionStyle = .None
    }
    
    func getLabel(index:Int) -> UILabel{
        if index < labelArray.count {
            return labelArray[index]
        }
        let label = UILabel()
        label.userInteractionEnabled = true
        label.font = v2Font(NodeTableViewCell.fontSize)
        label.textColor = V2EXColor.colors.v2_TopicListUserNameColor
        label.backgroundColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
        
        let tap = UITapGestureRecognizer(target: self, action: "labelClick:")
        label.addGestureRecognizer(tap)
        
        labelArray.append(label)
        self.contentView.addSubview(label)
    
        return label
    }
    func labelClick(sender:UITapGestureRecognizer) {
        let index = labelArray.indexOf(sender.view as! UILabel)
        if index != nil && index >= 0 && index <= self.nodes?.count {
            self.pushNodeTopicListController(self.nodes![index!])
        }
    }
    
    func pushNodeTopicListController(node:NodeModel) {
        let controller = NodeTopicListViewController()
        controller.node = node
        V2Client.sharedInstance.centerNavigation?.pushViewController(controller, animated: true)
    }
    
    func bind(nodes:[NodeModel]) {
        self.nodes = nodes
        for var i = 0 ; i < nodes.count ; i++ {
            let node = nodes[i]
            let label = getLabel(i)
            label.hidden = false
            label.text = node.nodeName
            label.snp_remakeConstraints(closure: { (make) -> Void in
                if i == 0 {
                    make.left.equalTo(self.contentView).offset(NodeTableViewCell.leftAndRightSpacing)
                }
                else {
                    make.left.equalTo(getLabel(i-1).snp_right).offset(NodeTableViewCell.nodeSpacing)
                }
                make.centerY.equalTo(self.contentView)
                make.width.equalTo(node.width + 1)
            })
        }
        
        for var i = nodes.count ; i < labelArray.count ; i++ {
            labelArray[i].hidden = true
        }
    }
    
    
}
