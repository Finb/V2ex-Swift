//
//  LeftViewController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/14/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import FXBlurView

class LeftViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

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
            
            regClass(self.tableView, cell: LeftUserHeadCell.self)
            regClass(self.tableView, cell: LeftNodeTableViewCell.self)
            
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
        
        let frostedView = FXBlurView()
        frostedView.underlyingView = self.backgroundImageView!
        frostedView.dynamic = false
        frostedView.frame = self.view.frame
        self.view.addSubview(frostedView)
        
        self.view.addSubview(self.tableView);
        self.tableView.snp_makeConstraints{ (make) -> Void in
            make.top.right.bottom.left.equalTo(self.view);
        }
        
        if V2Client.sharedInstance.isLogin {
            self.getUserInfo(V2Client.sharedInstance.username!)
        }

        
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return [1,3,2][section]
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.section == 1 && indexPath.row == 2)
        
        {
            return 55+10
        }
        return [180,55+SEPARATOR_HEIGHT,55+SEPARATOR_HEIGHT][indexPath.section]
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if  indexPath.row == 0 {
                let cell = getCell(tableView, cell: LeftUserHeadCell.self, indexPath: indexPath);
                return cell ;
            }
            else {
                return UITableViewCell()
            }
        }
        else if (indexPath.section == 1) {
            let cell = getCell(tableView, cell: LeftNodeTableViewCell.self, indexPath: indexPath)
            cell.nodeNameLabel!.text = ["个人中心","消息提醒","我的收藏"][indexPath.row]
            return cell
        }
        else {
            let cell = getCell(tableView, cell: LeftNodeTableViewCell.self, indexPath: indexPath)
            cell.nodeNameLabel!.text = ["节点","更多"][indexPath.row]
            return cell
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let loginViewController = LoginViewController()
                V2Client.sharedInstance.centerViewController!.navigationController?.presentViewController(loginViewController, animated: true, completion: nil);
            }
        }
    }
    
    
    
    /**
     获取用户信息
     */
    func getUserInfo(userName:String){
        UserModel.getUserInfoByUsername(userName) {(response:V2ValueResponse<UserModel>) -> Void in
            if response.success {
//                self?.tableView.reloadData()
                NSLog("获取用户信息成功")
            }
            else{
                NSLog("获取用户信息失败")
            }
        }
    }

}
