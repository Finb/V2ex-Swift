//
//  AccountManagerViewController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2/11/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

/// 多账户管理
class AccountsManagerViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate {
    fileprivate var users:[LocalSecurityAccountModel] = []
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.estimatedRowHeight = 100
        tableView.separatorStyle = .none
        
        regClass(tableView, cell: BaseDetailTableViewCell.self)
        regClass(tableView, cell: AccountListTableViewCell.self)
        regClass(tableView, cell: LogoutTableViewCell.self)
        
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("accounts")

        let warningButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        warningButton.contentMode = .center
        warningButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -20)
        warningButton.setImage(UIImage.imageUsedTemplateMode("ic_warning")!.withRenderingMode(.alwaysTemplate), for: .normal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: warningButton)
        warningButton.addTarget(self, action: #selector(AccountsManagerViewController.warningClick), for: .touchUpInside)

        self.view.addSubview(self.tableView);
        self.tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        self.tableView.snp.makeConstraints{ (make) -> Void in
            make.top.bottom.equalTo(self.view);
            make.center.equalTo(self.view);
            make.width.equalTo(SCREEN_WIDTH)
        }

        for (_,user) in V2UsersKeychain.sharedInstance.users {
            self.users.append(user)
        }
        
        self.themeChangedHandler = {[weak self] _ in
            self?.tableView.backgroundColor = V2EXColor.colors.v2_backgroundColor
            self?.view.backgroundColor = V2EXColor.colors.v2_backgroundColor
        }
    }

    @objc func warningClick(){
        let alertView = UIAlertView(title: "临时隐私声明", message: "当你登录时，软件会自动将你的用户名保存于系统的Keychain中（非常安全）。如果你不希望软件保存你的用户名，可以左滑账号并点击删除。\n后续会完善隐私声明页面，并添加 关闭保存用户名 的选项。", delegate: nil, cancelButtonTitle: "我知道了")
        alertView.show()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //     账户数量            分割线   退出登录按钮
        return self.users.count   + 1       + 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

        if indexPath.row < self.users.count{
            return true
        }
        return false
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let username = self.users[indexPath.row].username {
                self.users.remove(at: indexPath.row)
                V2UsersKeychain.sharedInstance.removeUser(username)
                tableView.deleteRows(at: [indexPath], with: .none)
            }
        }
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)

        let totalNumOfRows = self.tableView(tableView, numberOfRowsInSection: 0)
        if indexPath.row == totalNumOfRows - 1{ //最后一行，也就是退出登录按钮那行
            let alertView = UIAlertView(title: "确定注销当前账号吗？", message: "注销只会退出登录，并不会删除保存在Keychain中的账户名与密码。如需删除，请左滑需要删除的账号，然后点击删除按钮", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "注销")
            alertView.tag = 100000
            alertView.show()
        }
    }
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int){
        //注销登录的alertView
        if buttonIndex == 1 {
            V2User.sharedInstance.loginOut()
            self.navigationController?.popToRootViewController(animated: true)
        }
        
    }
}
