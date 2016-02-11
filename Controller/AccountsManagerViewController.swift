//
//  AccountManagerViewController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2/11/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

/// 多账户管理
class AccountsManagerViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    private var users:[LocalSecurityAccountModel] = []
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
            
            regClass(_tableView, cell: BaseDetailTableViewCell.self);
            regClass(_tableView, cell: AccountListTableViewCell.self);
            
            _tableView.delegate = self;
            _tableView.dataSource = self;
            return _tableView!;
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "账户"
        self.view.backgroundColor = V2EXColor.colors.v2_backgroundColor
        self.view.addSubview(self.tableView);
        self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        self.tableView.snp_makeConstraints{ (make) -> Void in
            make.top.bottom.equalTo(self.view);
            make.center.equalTo(self.view);
            make.width.equalTo(SCREEN_WIDTH)
        }
        
        for (_,user) in V2UsersKeychain.sharedInstance.users {
            self.users.append(user)
        }
        
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = getCell(tableView, cell: AccountListTableViewCell.self, indexPath: indexPath)
        cell.bind(self.users[indexPath.row])
        return cell
    }
}
