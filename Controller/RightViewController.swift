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
    var currentSelectedTabIndex = 0;
    /**
     第一次自动高亮的cell，
     因为再次点击其他cell，这个cell并不会自动调用 setSelected 取消自身的选中状态
     所以保存这个cell用于手动取消选中状态
     我也不知道这是不是BUG，还是我用法不对。
    */
    var firstAutoHighLightCell:UITableViewCell?
    
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
        
        var currentTab = V2EXSettings.sharedInstance[kHomeTab]
        if currentTab == nil {
            currentTab = "all"
        }
        self.currentSelectedTabIndex = rightNodes.index { $0.nodeTab == currentTab }!
        
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
        self.thmemChangedHandler = {[weak self] (style) -> Void in
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
        let paddingTop = (SCREEN_HEIGHT - CGFloat(rowCount) * rowHeight) / 2
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: paddingTop))

    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 调整RightView宽度
        let cell = RightNodeTableViewCell()
        let cellFont = UIFont(name: cell.nodeNameLabel.font.familyName, size: cell.nodeNameLabel.font.pointSize)
        for node in rightNodes {
            let size = node.nodeName!.boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT)),
                                                   options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                   attributes: ["NSFontAttributeName":cellFont!],
                                                   context: nil)
            let width = size.width + 56
            if width > V2Client.sharedInstance.drawerController!.maximumRightDrawerWidth {
                V2Client.sharedInstance.drawerController?.maximumRightDrawerWidth = width
            }
        }
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
        return cell ;
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let highLightCell = self.firstAutoHighLightCell{
            self.firstAutoHighLightCell = nil
            if(indexPath.row != self.currentSelectedTabIndex){
                highLightCell.setSelected(false, animated: false)
            }
        }
        let node = self.rightNodes[indexPath.row];
        V2Client.sharedInstance.centerViewController?.tab = node.nodeTab
        V2Client.sharedInstance.centerViewController?.refreshPage()
        V2Client.sharedInstance.drawerController?.closeDrawer(animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.currentSelectedTabIndex && cell.isSelected == false {
            if let highLightCell = self.firstAutoHighLightCell{
                highLightCell.setSelected(false, animated: false)
            }
            self.firstAutoHighLightCell = cell;
            cell.setSelected(true, animated: true)
        }
    }
}



struct rightNodeModel {
    var nodeName:String?
    var nodeTab:String?
}
