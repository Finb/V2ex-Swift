//
//  SettingsTableViewController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2/23/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "阅读设置"

        self.tableView.separatorStyle = .None
        regClass(self.tableView, cell: BaseDetailTableViewCell.self)
        regClass(self.tableView, cell: FontSizeSliderTableViewCell.self)
        regClass(self.tableView, cell: FontDisplayTableViewCell.self)
        self.thmemChangedHandler = {[weak self] (style) -> Void in
            self?.view.backgroundColor = V2EXColor.colors.v2_backgroundColor
            self?.tableView.reloadData()
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return [2,3][section]
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = ["    配色 - 点击下面选项，设置APP的配色方案"
            ,"    文字大小 - 滑动滑块调整文字大小"
            ][section]
        label.textColor = V2EXColor.colors.v2_TopicListUserNameColor
        label.font = v2Font(12)
        label.backgroundColor = V2EXColor.colors.v2_backgroundColor
        return label
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 44
        }
        else {
            return [70,25,175][indexPath.row]
        }
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = getCell(tableView, cell: BaseDetailTableViewCell.self, indexPath: indexPath)
            cell.titleLabel.text = ["默认","暗色"][indexPath.row]
            if V2EXColor.sharedInstance.style == V2EXColor.V2EXColorStyleDefault {
                cell.detailLabel.text = ["正在使用",""][indexPath.row]
            }
            else{
                cell.detailLabel.text = ["","正在使用"][indexPath.row]
            }
            return cell
        }
        
        else {
            if indexPath.row == 0 {
                let cell = getCell(tableView, cell: FontSizeSliderTableViewCell.self, indexPath: indexPath)
                return cell
            }
            else if indexPath.row == 1 {
                let cell = getCell(tableView, cell: BaseDetailTableViewCell.self, indexPath: indexPath)
                cell.backgroundColor = V2EXColor.colors.v2_backgroundColor
                cell.detailMarkHidden = true
                return cell
            }
            else{
                let cell = getCell(tableView, cell: FontDisplayTableViewCell.self, indexPath: indexPath)
                return cell
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            V2EXColor.sharedInstance.setStyleAndSave([V2EXColor.V2EXColorStyleDefault,V2EXColor.V2EXColorStyleDark][indexPath.row])
        }
    }
}
