//
//  NotificationsViewController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/29/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import MJRefresh
class NotificationsViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate {

    fileprivate var notificationsArray:[NotificationsModel] = []
    
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = UIColor.clear
        tableView.estimatedRowHeight = 100
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        regClass(tableView, cell: NotificationTableViewCell.self)
        
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.tableView);
        self.title = NSLocalizedString("notifications")
        self.view.backgroundColor = V2EXColor.colors.v2_backgroundColor
        
        self.tableView.snp.makeConstraints{ (make) -> Void in
            make.top.right.bottom.left.equalTo(self.view);
        }

        self.tableView.mj_header = V2RefreshHeader(refreshingBlock:{[weak self] () -> Void in
            self?.refresh()
        })
        self.showLoadingView()
        self.tableView.mj_header.beginRefreshing();

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
            self?.hideLoadingView()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notificationsArray.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.fin_heightForCellWithIdentifier(NotificationTableViewCell.self, indexPath: indexPath) { (cell) -> Void in
            cell.bind(self.notificationsArray[indexPath.row]);
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getCell(tableView, cell: NotificationTableViewCell.self, indexPath: indexPath)
        cell.bind(self.notificationsArray[indexPath.row])
        cell.replyButton.tag = indexPath.row
        if cell.replyButtonClickHandler == nil {
            cell.replyButtonClickHandler = { [weak self] (sender) in
                self?.replyClick(sender)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.notificationsArray[indexPath.row]
        if let id = item.topicId {
            let topicDetailController = TopicDetailViewController();
            topicDetailController.topicId = id ;
            self.navigationController?.pushViewController(topicDetailController, animated: true)
            tableView .deselectRow(at: indexPath, animated: true);
        }
    }

    func replyClick(_ sender:UIButton) {
        let item = self.notificationsArray[sender.tag]

        let replyViewController = ReplyingViewController()
        
        let tempTopicModel = TopicDetailModel()
        replyViewController.atSomeone = "@" + item.userName! + " "
        tempTopicModel.topicId = item.topicId
        replyViewController.topicModel = tempTopicModel
        
        let nav = V2EXNavigationController(rootViewController:replyViewController)
        self.navigationController?.present(nav, animated: true, completion:nil)
    }
    
}
