//
//  AccountManagerViewController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2/11/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import SVProgressHUD

/// 多账户管理
class AccountsManagerViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate {
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
            regClass(_tableView, cell: LogoutTableViewCell.self)
            
            _tableView.delegate = self;
            _tableView.dataSource = self;
            return _tableView!;
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "账户"
        self.view.backgroundColor = V2EXColor.colors.v2_backgroundColor
        
        let warningButton = UIButton(frame: CGRectMake(0, 0, 40, 40))
        warningButton.contentMode = .Center
        warningButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -20)
        warningButton.setImage(UIImage.imageUsedTemplateMode("ic_warning")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: warningButton)
        warningButton.addTarget(self, action: Selector("warningClick"), forControlEvents: .TouchUpInside)
        
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

    func warningClick(){
        let alertView = UIAlertView(title: "临时隐私声明", message: "当你登陆时，软件会自动将你的账号与密码保存于系统的Keychain中（非常安全）。如果你不希望软件保存你的账号与密码，可以左滑账号并点击删除。\n后续会完善隐私声明页面，并添加 关闭保存账号密码机制 的选项。\n但我强烈推荐你不要关闭，因为这个会帮助你【登陆过期自动重连】、或者【切换多账号】", delegate: nil, cancelButtonTitle: "我知道了")
        alertView.show()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //     账户数量            分割线   退出登录按钮
        return self.users.count   + 1       + 1
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row < self.users.count {
            return 55
        }
        else if indexPath.row == self.users.count {//分割线
            return 15
        }
        else { //退出登录按钮
            return 45
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row < self.users.count {
            let cell = getCell(tableView, cell: AccountListTableViewCell.self, indexPath: indexPath)
            cell.bind(self.users[indexPath.row])
            return cell
        }
        else if indexPath.row == self.users.count {//分割线
            let cell = getCell(tableView, cell: BaseDetailTableViewCell.self, indexPath: indexPath)
            cell.detailMarkHidden = true
            cell.backgroundColor = tableView.backgroundColor
            return cell
        }
        else{
            return getCell(tableView, cell: LogoutTableViewCell.self, indexPath: indexPath)
        }
    }
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        if indexPath.row < self.users.count{
            return true
        }
        return false
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            if let username = self.users[indexPath.row].username {
                self.users.removeAtIndex(indexPath.row)
                V2UsersKeychain.sharedInstance.removeUser(username)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .None)
            }
        }
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let totalNumOfRows = self.tableView(tableView, numberOfRowsInSection: 0)
        if indexPath.row < self.users.count {
            let user = self.users[indexPath.row]
            if user.username == V2Client.sharedInstance.username {
                return;
            }
            let alertView = UIAlertView(title: "确定切换到账号 " + user.username! + " 吗?", message: "无论新账号是否登录成功，都会注销当前账号。", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定")
            //这里一个属性两用了，除了用于标记它是切换账号的 alertView, 后面还加上了当前是点击了第几个账号
            //太懒了，懒得用其他什么写法
            //同学们注意，这种写法是相当的low的，如果硬要这样写，千万要留下足够的注释解释
            alertView.tag = 100001 + indexPath.row
            alertView.show()
        }
        else if indexPath.row == totalNumOfRows - 1{ //最后一行，也就是退出登录按钮那行
            let alertView = UIAlertView(title: "确定注销当前账号吗？", message: "注销只会退出登录，并不会删除保存在Keychain中的账户名与密码。如需删除，请左滑需要删除的账号，然后点击删除按钮", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "注销")
            alertView.tag = 100000
            alertView.show()
        }
    }
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        if alertView.tag > 100000 { //切换账号的alertView
            if buttonIndex == 0 {
                return
            }
            V2Client.sharedInstance.loginOut()
            self.tableView.reloadData()
            
            let user = self.users[alertView.tag - 100001]
            
            if let username = user.username,let password = user.password {
                SVProgressHUD.showWithStatus("正在登陆")
                UserModel.Login(username, password: password){
                    (response:V2ValueResponse<String>) -> Void in
                    if response.success {
                        SVProgressHUD.showSuccessWithStatus("登陆成功")
                        let username = response.value!
                        NSLog("登陆成功 %@",username)
                        //保存下用户名
                        V2EXSettings.sharedInstance[kUserName] = username
                        //获取用户信息
                        UserModel.getUserInfoByUsername(username, completionHandler: { (response) -> Void in
                            self.tableView.reloadData()
                        })
                    }
                    else{
                        SVProgressHUD.showErrorWithStatus(response.message)
                    }
                }
            }
        }
        else { //注销登录的alertView
            if buttonIndex == 1 {
                V2Client.sharedInstance.loginOut()
                self.navigationController?.popToRootViewControllerAnimated(true)
            }
        }
    }
}
