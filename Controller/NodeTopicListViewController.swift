//
//  NodeTopicListViewController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2/3/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

class NodeTopicListViewController: BaseViewController ,UITableViewDataSource,UITableViewDelegate  {
    var node:NodeModel?
    
    private var topicList:Array<TopicListModel>?
    var currentPage = 1
    
    private var _tableView :UITableView!
    private var tableView: UITableView {
        get{
            if(_tableView != nil){
                return _tableView!;
            }
            _tableView = UITableView();
            _tableView.backgroundColor = V2EXColor.colors.v2_backgroundColor
            _tableView.estimatedRowHeight=200;
            _tableView.separatorStyle = UITableViewCellSeparatorStyle.None;
            
            regClass(_tableView, cell: HomeTopicListTableViewCell.self)
            
            _tableView.delegate = self
            _tableView.dataSource = self
            return _tableView!;
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.node?.nodeId == nil {
            return;
        }

        self.title = self.node?.nodeName
        self.view.backgroundColor = V2EXColor.colors.v2_backgroundColor
        self.view.addSubview(self.tableView);
        self.tableView.snp_makeConstraints{ (make) -> Void in
            make.top.right.bottom.left.equalTo(self.view);
        }
        
        self.showLoadingView()
        
        self.tableView.mj_header = V2RefreshHeader(refreshingBlock: {[weak self] () -> Void in
            self?.refresh()
            })
        self.tableView.mj_header.beginRefreshing()
        
        self.tableView.mj_footer = V2RefreshFooter(refreshingBlock: {[weak self] () -> Void in
            self?.getNextPage()
        })
        
    }
    func refresh(){

        self.currentPage = 1
        
        //如果有上拉加载更多 正在执行，则取消它
        if self.tableView.mj_footer.isRefreshing() {
            self.tableView.mj_footer.endRefreshing()
        }
        
        //根据 tab name 获取帖子列表
        TopicListModel.getTopicList(self.node!.nodeId!, page: self.currentPage){
            [weak self](response:V2ValueResponse<[TopicListModel]>) -> Void in
            if response.success {
                if let weakSelf = self {
                    weakSelf.topicList = response.value
                    weakSelf.tableView.fin_reloadData()
                }
            }
            self?.tableView.mj_header.endRefreshing()
            
            self?.hideLoadingView()
        }
    }
    
    func getNextPage(){
        
        if self.topicList == nil || self.topicList?.count <= 0{
            self.tableView.mj_footer.endRefreshing()
            return;
        }
        
        self.currentPage++

        TopicListModel.getTopicList(self.node!.nodeId!, page: self.currentPage){
            [weak self](response:V2ValueResponse<[TopicListModel]>) -> Void in
            if response.success {
                if let weakSelf = self , value = response.value  {
                    weakSelf.topicList! += value
                    weakSelf.tableView.fin_reloadData()
                }
                else{
                    self?.currentPage-- ;
                }
            }
            self?.tableView.mj_footer.endRefreshing()
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
            cell.bindNodeModel(self.topicList![indexPath.row]);
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = getCell(tableView, cell: HomeTopicListTableViewCell.self, indexPath: indexPath);
        cell.bindNodeModel(self.topicList![indexPath.row]);
        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = self.topicList![indexPath.row]
        
        if let id = item.topicId {
            let topicDetailController = TopicDetailViewController();
            topicDetailController.topicId = id ;
            self.navigationController?.pushViewController(topicDetailController, animated: true)
            tableView .deselectRowAtIndexPath(indexPath, animated: true);
        }
    }

}
