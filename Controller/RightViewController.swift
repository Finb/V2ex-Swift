//
//  RightViewController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/14/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

class RightViewController: UITableViewController {
    let rightNodes = [
        rightNodeModel(nodeName: NSLocalizedString("tech" ), nodeTab: "tech"),
        rightNodeModel(nodeName: NSLocalizedString("creative" ), nodeTab: "creative"),
        rightNodeModel(nodeName: NSLocalizedString("play" ), nodeTab: "play"),
        rightNodeModel(nodeName: NSLocalizedString("apple" ), nodeTab: "apple"),
        rightNodeModel(nodeName: NSLocalizedString("jobs" ), nodeTab: "jobs"),
        rightNodeModel(nodeName: NSLocalizedString("deals" ), nodeTab: "deals"),
        rightNodeModel(nodeName: NSLocalizedString("city" ), nodeTab: "city"),
        rightNodeModel(nodeName: NSLocalizedString("qna" ), nodeTab: "qna"),
        rightNodeModel(nodeName: NSLocalizedString("hot"), nodeTab: "hot"),
        rightNodeModel(nodeName: NSLocalizedString("all"), nodeTab: "all"),
        rightNodeModel(nodeName: NSLocalizedString("r2" ), nodeTab: "r2"),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = V2EXColor.colors.v2_backgroundColor;
        
        self.tableView.tableHeaderView = UIView(frame: CGRectMake(0, 0, SCREEN_WIDTH, 64))
        regClass(self.tableView, cell: UITableViewCell.self)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rightNodes.count;
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = getCell(tableView, cell: UITableViewCell.self, indexPath: indexPath);
        cell.textLabel?.text = self.rightNodes[indexPath.row].nodeName
        cell.textLabel?.textAlignment = .Right
        return cell ;
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let node = self.rightNodes[indexPath.row];
        V2Client.sharedInstance.centerViewController?.refreshPage(node.nodeTab)
        V2Client.sharedInstance.drawerController?.closeDrawerAnimated(true, completion: nil)
    }
}



struct rightNodeModel {
    var nodeName:String?
    var nodeTab:String?
}