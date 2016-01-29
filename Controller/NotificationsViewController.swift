//
//  NotificationsViewController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/29/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import MJRefresh
class NotificationsViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    private var notificationsArray:[NotificationsModel] = []
    
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
            
            regClass(_tableView, cell: NotificationTableViewCell.self)
            
            _tableView.delegate = self;
            _tableView.dataSource = self;
            return _tableView!;
            
        }
    }
    
    private weak var _loadView:V2LoadingView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.tableView);
        self.tableView.snp_makeConstraints{ (make) -> Void in
            make.top.right.bottom.left.equalTo(self.view);
        }

        self.setupLoadingView()
        self.tableView.mj_header = V2RefreshHeader(refreshingBlock:{[weak self] () -> Void in
            self?.refresh()
        })
        self.tableView.mj_header.beginRefreshing();

    }
    
    func setupLoadingView (){
        self.title = "通知"
        self.view.backgroundColor = V2EXColor.colors.v2_backgroundColor
        
        let aloadView = V2LoadingView()
        aloadView.backgroundColor = self.view.backgroundColor
        self.view.addSubview(aloadView)
        aloadView.snp_makeConstraints{ (make) -> Void in
            make.top.right.bottom.left.equalTo(self.view)
        }
        self._loadView = aloadView
    }
    
    
    func refresh(){
        NotificationsModel.getNotifications {[weak self] (response) -> Void in
            if response.success && response.value != nil {
                if let weakSelf = self{
                    weakSelf.notificationsArray = response.value!
                    weakSelf.tableView.fin_reloadData()
                }
            }
            self?.tableView.mj_header.endRefreshing()
            if let view = self?._loadView{
                view.hide()
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notificationsArray.count
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.fin_heightForCellWithIdentifier(NotificationTableViewCell.self, indexPath: indexPath) { (cell) -> Void in
            cell.bind(self.notificationsArray[indexPath.row]);
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = getCell(tableView, cell: NotificationTableViewCell.self, indexPath: indexPath)
        cell.bind(self.notificationsArray[indexPath.row])
        if cell.replyButton?.allTargets().count <= 0 {
            cell.replyButton?.addTarget(self, action: Selector("replyClick:"), forControlEvents: .TouchUpInside)
        }
        cell.replyButton?.tag = indexPath.row
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = self.notificationsArray[indexPath.row]
        if let id = item.topicId {
            let topicDetailController = TopicDetailViewController();
            topicDetailController.topicId = id ;
            self.navigationController?.pushViewController(topicDetailController, animated: true)
            tableView .deselectRowAtIndexPath(indexPath, animated: true);
        }
    }

    func replyClick(sender:UIButton) {
        let item = self.notificationsArray[sender.tag]

        let replyViewController = ReplyingViewController()
        
        let tempTopicModel = TopicDetailModel()
        replyViewController.atSomeone = "@" + item.userName! + " "
        tempTopicModel.topicId = item.topicId
        replyViewController.topicModel = tempTopicModel
        
        let nav = V2EXNavigationController(rootViewController:replyViewController)
        self.navigationController?.presentViewController(nav, animated: true, completion:nil)
    }
    
}
