//
//  NodesViewController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2/2/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
class NodesViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource {
    var nodeGroupArray:[NodeGroupModel]?
    
    private var headerView:[UILabel]? = []
    
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
            
            regClass(_tableView, cell: NodeTableViewCell.self);
            
            _tableView.delegate = self;
            _tableView.dataSource = self;
            return _tableView!;
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "节点导航"
        self.view.backgroundColor = V2EXColor.colors.v2_backgroundColor
        self.view.addSubview(self.tableView);
        self.tableView.snp_makeConstraints{ (make) -> Void in
            make.top.bottom.equalTo(self.view);
            make.center.equalTo(self.view);
            make.width.equalTo(SCREEN_WIDTH)
        }
        
        
        NodeGroupModel.getNodes { (response) -> Void in
            if response.success {
                self.nodeGroupArray = response.value
                self.tableView.reloadData()
            }
            self.hideLoadingView()
        }
        
        self.showLoadingView()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let array = self.nodeGroupArray {
            return array.count
        }
        return 0
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.nodeGroupArray![section].childrenRows.count
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 45
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var label:UILabel?
        if self.headerView?.count > section {
            label = self.headerView![section]
        }
        else {
            label = UILabel()
            label?.font = v2Font(16)
            label?.textColor = V2EXColor.colors.v2_TopicListTitleColor
            label?.backgroundColor = V2EXColor.colors.v2_backgroundColor
        }
        if let name = self.nodeGroupArray![section].groupName {
            label?.text =  "    " + name
        }
        return label
            
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let group = self.nodeGroupArray![indexPath.section]
        let rows = group.childrenRows[indexPath.row]

        var nodes:[NodeModel] = []
        
        for var i = rows.first! ; i <= rows.last! ; i++ {
            nodes.append(group.children[i])
        }
        
        //同数量的node 使用同一组cell，省的浪费label
        let identity = "NodeTableViewCell" + "\(rows.count)"
        var cell = tableView.dequeueReusableCellWithIdentifier(identity) as? NodeTableViewCell
        if cell == nil {
            cell = NodeTableViewCell(style: .Default, reuseIdentifier: identity)
        }
        cell!.bind(nodes)
        return cell!
    }
    
}
