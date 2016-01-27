//
//  HomeViewController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/8/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import SnapKit

import Alamofire
import AlamofireObjectMapper

import Ji
import MJRefresh

let kHomeTab = "me.fin.homeTab"

class HomeViewController: UIViewController ,UITableViewDataSource,UITableViewDelegate{
    var topicList:Array<TopicListModel>?
    var tab:String? = nil
    
    private var _tableView :UITableView!
    private var tableView: UITableView {
        get{
            if(_tableView != nil){
                return _tableView!;
            }
            _tableView = UITableView();
            _tableView.backgroundColor = V2EXColor.colors.v2_backgroundColor
            _tableView.estimatedRowHeight=100;
            _tableView.separatorStyle = UITableViewCellSeparatorStyle.None;
            
            regClass(_tableView, cell: HomeTopicListTableViewCell.self);
            
            _tableView.delegate = self;
            _tableView.dataSource = self;
            return _tableView!;
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title="V2EX";
        self.tab = V2EXSettings.sharedInstance[kHomeTab]
        
        let leftButton = UIButton(frame: CGRectMake(0, 0, 40, 40))
        leftButton.contentMode = .Center
        leftButton.imageEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0)
        leftButton.setImage(UIImage(named: "ic_menu_36pt")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftButton)
        leftButton.addTarget(self, action: Selector("leftClick"), forControlEvents: .TouchUpInside)
        

        let rightButton = UIButton(frame: CGRectMake(0, 0, 40, 40))
        rightButton.contentMode = .Center
        rightButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -15)
        rightButton.setImage(UIImage(named: "ic_more_horiz_36pt")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        rightButton.addTarget(self, action: Selector("rightClick"), forControlEvents: .TouchUpInside)

        
        self.view.addSubview(self.tableView);
        self.tableView.snp_makeConstraints{ (make) -> Void in
            make.top.right.bottom.left.equalTo(self.view);
        }
        self.tableView.mj_header = V2RefreshHeader(refreshingBlock: {[weak self] () -> Void in
            self?.refresh()
        })
        self.refreshPage()
    }
    func leftClick(){
        V2Client.sharedInstance.drawerController?.toggleLeftDrawerSideAnimated(true, completion: nil)
    }
    func rightClick(){
        V2Client.sharedInstance.drawerController?.toggleRightDrawerSideAnimated(true, completion: nil)
    }
    
    func refreshPage(){
        self.tableView.mj_header.beginRefreshing();
        V2EXSettings.sharedInstance[kHomeTab] = tab
    }
    
    func refresh(){
        //根据 tab name 获取帖子列表
        TopicListModel.getTopicList(tab){
            [weak self](response:V2ValueResponse<[TopicListModel]>) -> Void in
            if response.success {
                if let weakSelf = self {
                    weakSelf.topicList = response.value
                    weakSelf.tableView.fin_reloadData()
                    if weakSelf.tableView.mj_header.isRefreshing() {
                        weakSelf.tableView.mj_header.endRefreshing()
                    }
                }
            }
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let list = self.topicList {
            return list.count;
        }
        return 0;
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.fin_heightForCellWithIdentifier(HomeTopicListTableViewCell.self, indexPath: indexPath) { (cell) -> Void in
            cell.bind(self.topicList![indexPath.row]);
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = getCell(tableView, cell: HomeTopicListTableViewCell.self, indexPath: indexPath);
        cell.bind(self.topicList![indexPath.row]);
        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = self.topicList![indexPath.row]
        
        if let id = item.topicId {
            let topicDetailController = TopicDetailViewController();
            topicDetailController.topicId = id ;
            self.navigationController?.pushViewController(topicDetailController, animated: true)
            tableView .deselectRowAtIndexPath(indexPath, animated: true);
        }
    }
}

