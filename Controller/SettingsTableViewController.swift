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

        self.tableView.separatorStyle = .none
        regClass(self.tableView, cell: BaseDetailTableViewCell.self)
        regClass(self.tableView, cell: FontSizeSliderTableViewCell.self)
        regClass(self.tableView, cell: FontDisplayTableViewCell.self)
        self.thmemChangedHandler = {[weak self] (style) -> Void in
            self?.view.backgroundColor = V2EXColor.colors.v2_backgroundColor
            self?.tableView.reloadData()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return [2,3][section]
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = ["    配色 - 点击下面选项，设置APP的配色方案"
            ,"    文字大小 - 滑动滑块调整文字大小"
            ][section]
        label.textColor = V2EXColor.colors.v2_TopicListUserNameColor
        label.font = v2Font(12)
        label.backgroundColor = V2EXColor.colors.v2_backgroundColor
        return label
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 0 {
            return 44
        }
        else {
            return [70,25,175][(indexPath as NSIndexPath).row]
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).section == 0 {
            let cell = getCell(tableView, cell: BaseDetailTableViewCell.self, indexPath: indexPath)
            cell.titleLabel.text = ["默认","暗色"][(indexPath as NSIndexPath).row]
            if V2EXColor.sharedInstance.style == V2EXColor.V2EXColorStyleDefault {
                cell.detailLabel.text = ["正在使用",""][(indexPath as NSIndexPath).row]
            }
            else{
                cell.detailLabel.text = ["","正在使用"][(indexPath as NSIndexPath).row]
            }
            return cell
        }
        
        else {
            if (indexPath as NSIndexPath).row == 0 {
                let cell = getCell(tableView, cell: FontSizeSliderTableViewCell.self, indexPath: indexPath)
                return cell
            }
            else if (indexPath as NSIndexPath).row == 1 {
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 0 {
            V2EXColor.sharedInstance.setStyleAndSave([V2EXColor.V2EXColorStyleDefault,V2EXColor.V2EXColorStyleDark][(indexPath as NSIndexPath).row])
        }
    }
}
