//
//  MoreViewController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/30/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

class MoreViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "更多"
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none;
        regClass(self.tableView, cell: BaseDetailTableViewCell.self)
        
        self.thmemChangedHandler = {[weak self] (style) -> Void in
            self?.view.backgroundColor = V2EXColor.colors.v2_backgroundColor
            self?.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 9
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return [30,50,12,50,50,12,50,50,50][(indexPath as NSIndexPath).row]
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getCell(tableView, cell: BaseDetailTableViewCell.self, indexPath: indexPath)
        cell.selectionStyle = .none
        
        //设置标题
        cell.titleLabel.text = ["","阅读设置","","去商店评分","提出BUG或改进", "","关注本项目源代码","开源库","版本号"][(indexPath as NSIndexPath).row]
        
        //设置颜色
        if [0,2,5].contains((indexPath as NSIndexPath).row) {
            cell.backgroundColor = self.tableView.backgroundColor
        }
        else{
            cell.backgroundColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
        }
        
        //设置右侧箭头
        if [0,2,5,8].contains((indexPath as NSIndexPath).row) {
            cell.detailMarkHidden = true
        }
        else {
            cell.detailMarkHidden = false
        }
        
        //设置右侧文本
        if (indexPath as NSIndexPath).row == 8 {
            cell.detailLabel.text = "Version " + (Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)
                + " (Build " + (Bundle.main.infoDictionary!["CFBundleVersion"] as! String ) + ")"
        }
        else {
            cell.detailLabel.text = ""
        }
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).row == 1 {
            V2Client.sharedInstance.centerNavigation?.pushViewController(SettingsTableViewController(), animated: true)
        }
        else if (indexPath as NSIndexPath).row == 3 {
            let str = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=1078157349"
            UIApplication.shared.openURL(URL(string: str)!)
        }
        else if (indexPath as NSIndexPath).row == 4 {
            UIApplication.shared.openURL(URL(string: "http://finb.github.io/blog/2016/02/01/v2ex-ioske-hu-duan-bug-and-jian-yi/")!)
        }
        else if (indexPath as NSIndexPath).row == 6 {
            UIApplication.shared.openURL(URL(string: "https://github.com/Finb/V2ex-Swift")!)
        }
        else if (indexPath as NSIndexPath).row == 7 {
            V2Client.sharedInstance.centerNavigation?.pushViewController(PodsTableViewController(), animated: true)
        }
    }
}
