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
        self.title = NSLocalizedString("viewOptions")

        self.tableView.separatorStyle = .none
        regClass(self.tableView, cell: BaseDetailTableViewCell.self)
        regClass(self.tableView, cell: FontSizeSliderTableViewCell.self)
        regClass(self.tableView, cell: FontDisplayTableViewCell.self)
        self.themeChangedHandler = {[weak self] (style) -> Void in
            self?.view.backgroundColor = V2EXColor.colors.v2_backgroundColor
            self?.tableView.reloadData()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return [3,3][section]
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = [NSLocalizedString("viewOptionThemeSet")
            ,NSLocalizedString("viewOptionTextSize")
            ][section]
        label.textColor = V2EXColor.colors.v2_TopicListUserNameColor
        label.font = v2Font(12)
        label.backgroundColor = V2EXColor.colors.v2_backgroundColor
        return label
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                if #available(iOS 13.0, *) {
                    return 44
                }
                else{
                    return 0
                }
            }
            return 44
        }
        else {
            return [70,25,185][indexPath.row]
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = getCell(tableView, cell: BaseDetailTableViewCell.self, indexPath: indexPath)
            cell.clipsToBounds = true
            cell.titleLabel.text =
                [NSLocalizedString("followSystem"),
                 NSLocalizedString("default"),
                 NSLocalizedString("dark")][indexPath.row]
            var index:Int = ([V2EXColor.V2EXColorStyleDefault,V2EXColor.V2EXColorStyleDark]
                .firstIndex{ $0 == V2EXColor.sharedInstance.style } ?? 0) + 1
            if V2EXColor.sharedInstance.isFollowSystem {
                index = 0
            }
            cell.detailLabel.text = index == indexPath.row ? NSLocalizedString("current") : ""
            
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                //跟随系统
                V2EXColor.sharedInstance.isFollowSystem = true
            }
            else{
                V2EXColor.sharedInstance.isFollowSystem = false
                V2EXColor.sharedInstance.setStyleAndSave(
                    [V2EXColor.V2EXColorStyleDefault,
                     V2EXColor.V2EXColorStyleDark][indexPath.row - 1])
            }
        }
    }
}
