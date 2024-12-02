//
//  RightViewController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/14/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import FXBlurView
let RightViewControllerRightNodes = [
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
class RightViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    let rightNodes = RightViewControllerRightNodes
    var currentSelectedTabIndex = 0;
    
    var backgroundImageView:UIImageView?
    var frostedView = FXBlurView()
    
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = UIColor.clear
        tableView.estimatedRowHeight=100
        tableView.separatorStyle = .none
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        regClass(tableView, cell: RightNodeTableViewCell.self)
        
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    override var preferredStatusBarStyle: UIStatusBarStyle{
        get {
            if V2EXColor.sharedInstance.style == V2EXColor.V2EXColorStyleDefault {
                if #available(iOS 13.0, *) {
                    return .darkContent
                } else {
                    return .default
                }
            }
            else{
                return .lightContent
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = V2EXColor.colors.v2_backgroundColor;
        
        var currentTab:String? = V2EXSettings.sharedInstance[kHomeTab]
        if currentTab == nil {
            currentTab = "all"
        }
        self.currentSelectedTabIndex = rightNodes.firstIndex { $0.nodeTab == currentTab }!
        
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
        self.tableView.snp.makeConstraints{ (make) -> Void in
            make.top.right.bottom.left.equalTo(self.view);
        }
        self.themeChangedHandler = {[weak self] (style) -> Void in
            if V2EXColor.sharedInstance.style == V2EXColor.V2EXColorStyleDefault {
                self?.backgroundImageView?.image = UIImage(named: "32.jpg")
            }
            else{
                self?.backgroundImageView?.image = UIImage(named: "12.jpg")
            }
            self?.frostedView.updateAsynchronously(true, completion: nil)
        }
        
        let rowHeight = self.tableView(self.tableView, heightForRowAt: IndexPath(row: 0, section: 0))
        let rowCount = self.tableView(self.tableView, numberOfRowsInSection: 0)
        var paddingTop = (SCREEN_HEIGHT - CGFloat(rowCount) * rowHeight) / 2
        if paddingTop <= 0 {
            paddingTop = 20
        }
        self.tableView.contentInset = UIEdgeInsets(top: paddingTop, left: 0, bottom: 0, right: 0)
    }
    func maximumRightDrawerWidth() -> CGFloat{
        // 调整RightView宽度
        let cell = RightNodeTableViewCell()
        let cellFont = UIFont(name: cell.nodeNameLabel.font.familyName, size: cell.nodeNameLabel.font.pointSize)
        for node in rightNodes {
            let size = node.nodeName!.boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT)),
                                                   options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                   attributes: [NSAttributedString.Key(rawValue: "NSFontAttributeName"):cellFont!],
                                                   context: nil)
            let width = size.width + 50
            if width > 100 {
                return width
            }
        }
        return 100
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rightNodes.count;
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getCell(tableView, cell: RightNodeTableViewCell.self, indexPath: indexPath);
        cell.nodeNameLabel.text = self.rightNodes[indexPath.row].nodeName
        
        if indexPath.row == self.currentSelectedTabIndex && cell.isSelected == false {
            self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .middle)
        }
        return cell ;
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let node = self.rightNodes[indexPath.row];
        V2Client.sharedInstance.centerViewController?.tabName = node.nodeTab
        V2Client.sharedInstance.centerViewController?.refreshPage()
        V2Client.sharedInstance.drawerController?.closeDrawer(animated: true, completion: nil)
    }
}



struct rightNodeModel {
    var nodeName:String?
    var nodeTab:String?
}
