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
        self.view.backgroundColor = V2EXColor.colors.v2_backgroundColor
        self.title = "更多"
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None;
        regClass(self.tableView, cell: BaseDetailTableViewCell.self)
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 9
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return [30,50,12,50,50,12,50,50,50][indexPath.row]
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = getCell(tableView, cell: BaseDetailTableViewCell.self, indexPath: indexPath)
        cell.selectionStyle = .None
        
        //设置标题
        cell.titleLabel?.text = ["","阅读设置","","去商店评分","提出BUG或改进", "","关注本项目源代码","开源库","版本号"][indexPath.row]
        
        //设置颜色
        if [0,2,5].contains(indexPath.row) {
            cell.backgroundColor = self.tableView.backgroundColor
        }
        else{
            cell.backgroundColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
        }
        
        //设置右侧箭头
        if [0,2,5,8].contains(indexPath.row) {
            cell.detailMarkHidden = true
        }
        else {
            cell.detailMarkHidden = false
        }
        
        //设置右侧文本
        if indexPath.row == 8 {
            cell.detailLabel!.text = "Version " + (NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String)
                + " (Build " + (NSBundle.mainBundle().infoDictionary!["CFBundleVersion"] as! String ) + ")"
        }
        else {
            cell.detailLabel!.text = ""
        }
        
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 3 {
            let str = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=1078157349"
            UIApplication.sharedApplication().openURL(NSURL(string: str)!)
        }
        else if indexPath.row == 4 {
            UIApplication.sharedApplication().openURL(NSURL(string: "http://finb.github.io/blog/2016/02/01/v2ex-ioske-hu-duan-bug-and-jian-yi/")!)
        }
        else if indexPath.row == 6 {
            UIApplication.sharedApplication().openURL(NSURL(string: "https://github.com/Finb/V2ex-Swift")!)
        }
        else if indexPath.row == 7 {
            V2Client.sharedInstance.centerNavigation?.pushViewController(PodsTableViewController(), animated: true)
        }
    }
}
