//
//  RightViewController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/14/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import FXBlurView

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
        rightNodeModel(nodeName: NSLocalizedString("nodes" ), nodeTab: "nodes"),
        rightNodeModel(nodeName: NSLocalizedString("members" ), nodeTab: "members"),
    ]
    
    var backgroundImageView:UIImageView?
    var frostedView = FXBlurView()
    
    fileprivate var _tableView :UITableView!
    fileprivate var tableView: UITableView {
        get{
            if(_tableView != nil){
                return _tableView!;
            }
            _tableView = UITableView();
            _tableView.backgroundColor = UIColor.clear
            _tableView.estimatedRowHeight=100;
            _tableView.separatorStyle = UITableViewCellSeparatorStyle.none;
            
            regClass(self.tableView, cell: RightNodeTableViewCell.self)
            
            _tableView.delegate = self;
            _tableView.dataSource = self;
            return _tableView!;
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = V2EXColor.colors.v2_backgroundColor;
        
        self.backgroundImageView = UIImageView()
        self.backgroundImageView!.frame = self.view.frame
        self.backgroundImageView!.contentMode = .left
        view.addSubview(self.backgroundImageView!)

        frostedView.underlyingView = self.backgroundImageView!
        frostedView.isDynamic = false
        frostedView.frame = self.view.frame
        frostedView.tintColor = UIColor.black
        self.view.addSubview(frostedView)
        
        self.view.addSubview(self.tableView);
        self.tableView.snp_makeConstraints{ (make) -> Void in
            make.top.right.bottom.left.equalTo(self.view);
        }
        self.thmemChangedHandler = {[weak self] (style) -> Void in
            if V2EXColor.sharedInstance.style == V2EXColor.V2EXColorStyleDefault {
                self?.backgroundImageView?.image = UIImage(named: "32.jpg")
            }
            else{
                self?.backgroundImageView?.image = UIImage(named: "12.jpg")
            }
            self?.frostedView.updateAsynchronously(true, completion: nil)
        }
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 25.5))
        

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rightNodes.count;
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getCell(tableView, cell: RightNodeTableViewCell.self, indexPath: indexPath);
        cell.nodeNameLabel.text = self.rightNodes[(indexPath as NSIndexPath).row].nodeName
        return cell ;
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let node = self.rightNodes[(indexPath as NSIndexPath).row];
        V2Client.sharedInstance.centerViewController?.tab = node.nodeTab
        V2Client.sharedInstance.centerViewController?.refreshPage()
        V2Client.sharedInstance.drawerController?.closeDrawer(animated: true, completion: nil)
    }
}



struct rightNodeModel {
    var nodeName:String?
    var nodeTab:String?
}
