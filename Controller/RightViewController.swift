//
//  RightViewController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/14/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

class RightViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
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
    
    var backgroundImageView:UIImageView?
    
    private var _tableView :UITableView!
    private var tableView: UITableView {
        get{
            if(_tableView != nil){
                return _tableView!;
            }
            _tableView = UITableView();
            _tableView.backgroundColor = UIColor.clearColor()
            _tableView.estimatedRowHeight=100;
            _tableView.separatorStyle = UITableViewCellSeparatorStyle.None;
            
            regClass(self.tableView, cell: RightNodeTableViewCell.self)
            
            _tableView.delegate = self;
            _tableView.dataSource = self;
            return _tableView!;
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = V2EXColor.colors.v2_backgroundColor;
        
        self.backgroundImageView = UIImageView(image: UIImage(named: "32.jpg"))
        self.backgroundImageView!.frame = self.view.frame
        self.backgroundImageView!.contentMode = .ScaleToFill
        view.addSubview(self.backgroundImageView!)
        
        let frostedView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        frostedView.frame = self.view.frame
        self.view.addSubview(frostedView)
        
        self.view.addSubview(self.tableView);
        self.tableView.snp_makeConstraints{ (make) -> Void in
            make.top.right.bottom.left.equalTo(self.view);
        }
        
        self.tableView.tableHeaderView = UIView(frame: CGRectMake(0, 0, SCREEN_WIDTH, 32))
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rightNodes.count;
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55 + SEPARATOR_HEIGHT
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = getCell(tableView, cell: RightNodeTableViewCell.self, indexPath: indexPath);
        cell.nodeNameLabel!.text = self.rightNodes[indexPath.row].nodeName
        return cell ;
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let node = self.rightNodes[indexPath.row];
        V2Client.sharedInstance.centerViewController?.refreshPage(node.nodeTab)
        V2Client.sharedInstance.drawerController?.closeDrawerAnimated(true, completion: nil)
    }
}



struct rightNodeModel {
    var nodeName:String?
    var nodeTab:String?
}