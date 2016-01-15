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

class HomeViewController: UIViewController ,UITableViewDataSource,UITableViewDelegate{
    var topicList:Array<TopicListModel>?
    private var _tab:String? = nil
    
    private var _tableView :UITableView!
    private var tableView: UITableView {
        get{
            if(_tableView != nil){
                return _tableView!;
            }
            _tableView = UITableView();
            _tableView.estimatedRowHeight=100;
            _tableView.separatorStyle = UITableViewCellSeparatorStyle.None;
            
            regClass(_tableView, cell: HomeTopicListTableViewCell.self);
            
            _tableView.registerClass(HomeTopicListTableViewCell.self , forCellReuseIdentifier: HomeTopicListTableViewCell.Identifier());
            
            _tableView.delegate = self;
            _tableView.dataSource = self;
            return _tableView!;
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title="V2EX";
        
        self.view.addSubview(self.tableView);
        self.tableView.snp_makeConstraints{ (make) -> Void in
            make.top.right.bottom.left.right.equalTo(self.view);
        }
        self.refreshPage();
    }
    
    func refreshPage(tab:String? = nil){
        if let tab = tab {
            _tab = tab
        }
        TopicListModel.getTopicList(_tab){
            [weak self](response:V2Response<[TopicListModel]>) -> Void in
            if response.success {
                self?.topicList = response.value
                self?.tableView.fin_reloadData()
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
}

