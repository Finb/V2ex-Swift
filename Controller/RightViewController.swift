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
        rightNodeModel(nodeName: NSLocalizedString("hot"), nodeTag: "hot"),
        rightNodeModel(nodeName: NSLocalizedString("all"), nodeTag: "all"),
        rightNodeModel(nodeName: NSLocalizedString("tech" ), nodeTag: "tech"),
        rightNodeModel(nodeName: NSLocalizedString("creative" ), nodeTag: "creative"),
        rightNodeModel(nodeName: NSLocalizedString("play" ), nodeTag: "play"),
        rightNodeModel(nodeName: NSLocalizedString("apple" ), nodeTag: "apple"),
        rightNodeModel(nodeName: NSLocalizedString("jobs" ), nodeTag: "jobs"),
        rightNodeModel(nodeName: NSLocalizedString("deals" ), nodeTag: "deals"),
        rightNodeModel(nodeName: NSLocalizedString("city" ), nodeTag: "city"),
        rightNodeModel(nodeName: NSLocalizedString("qna" ), nodeTag: "qna"),
        rightNodeModel(nodeName: NSLocalizedString("r2" ), nodeTag: "r2"),
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
    
}



struct rightNodeModel {
    var nodeName:String?
    var nodeTag:String?
}