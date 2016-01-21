//
//  TopicDetailViewController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/16/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

class TopicDetailViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {

    var topicId = "0"
    private var model:TopicDetailModel?
    private var commentsArray:[TopicCommentModel] = []
    private var webViewContentCell:TopicDetailWebViewContentCell?
    
    private var _tableView :UITableView!
    private var tableView: UITableView {
        get{
            if(_tableView != nil){
                return _tableView!;
            }
            _tableView = UITableView();
            _tableView.estimatedRowHeight=200;
            _tableView.separatorStyle = UITableViewCellSeparatorStyle.None;
            
            regClass(_tableView, cell: TopicDetailHeaderCell.self)
            regClass(_tableView, cell: TopicDetailWebViewContentCell.self)
            regClass(_tableView, cell: TopicDetailCommentCell.self)
            regClass(_tableView, cell: BaseDetailTableViewCell.self)
            
            _tableView.delegate = self
            _tableView.dataSource = self
            return _tableView!;
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "帖子详情"
        self.view.backgroundColor = V2EXColor.colors.v2_backgroundColor
        self.view.addSubview(self.tableView);
        self.tableView.snp_makeConstraints{ (make) -> Void in
            make.top.right.bottom.left.equalTo(self.view);
        }
        
        //根据 topicId 获取 帖子信息 、回复。
        TopicDetailModel.getTopicDetailById(self.topicId){
            (response:V2Response<(TopicDetailModel?,[TopicCommentModel])>) -> Void in
            if response.success {
                
                if let aModel = response.value.0{
                    self.model = aModel
                    self.tableView.fin_reloadData()
                }
                
                self.commentsArray = response.value.1
                
                self.tableView.fin_reloadData()
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if self.model != nil{
                return 3
            }
            else{
                return 0
            }
        }
        else {
            return self.commentsArray.count;
        }
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            
            if indexPath.row == 0{
                return tableView.fin_heightForCellWithIdentifier(TopicDetailHeaderCell.self, indexPath: indexPath) { (cell) -> Void in
                    cell.bind(self.model!);
                }
            }
            
            else if indexPath.row == 1 {
                if let cell = self.webViewContentCell {
                    return cell.contentHeight
                }
                else {
                    return 1
                }
            }
            
            else if indexPath.row == 2 {
                return 45
            }
            
        }
       
        else {
            return tableView.fin_heightForCellWithIdentifier(TopicDetailCommentCell.self, indexPath: indexPath) { (cell) -> Void in
                cell.bind(self.commentsArray[indexPath.row])
            }
        }
        
        return 200 ;
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0{
                //帖子标题
                let cell = getCell(tableView, cell: TopicDetailHeaderCell.self, indexPath: indexPath);
                cell.bind(self.model!);
                return cell;
            }
            else if indexPath.row == 1{
                //帖子内容
                if self.webViewContentCell == nil {
                    self.webViewContentCell = getCell(tableView, cell: TopicDetailWebViewContentCell.self, indexPath: indexPath);
                }
                else {
                    return self.webViewContentCell!
                }
                self.webViewContentCell!.load(self.model!);
                self.webViewContentCell!.contentHeightChanged = { [weak self] (height:CGFloat) -> Void  in
                    self?.tableView.beginUpdates()
                    self?.tableView.endUpdates()
                }
                return self.webViewContentCell!
            }
            
            else if indexPath.row == 2 {
                let cell = getCell(tableView, cell: BaseDetailTableViewCell.self, indexPath: indexPath)
                cell.detailMarkHidden = true
                cell.titleLabel?.text = self.model?.topicCommentTotalCount
                cell.titleLabel?.font = v2Font(12)
                return cell
            }
        }
            
        else if indexPath.section == 1{
            //帖子评论
            let cell = getCell(tableView, cell: TopicDetailCommentCell.self, indexPath: indexPath)
            cell.bind(self.commentsArray[indexPath.row])
            return cell
        }
        return UITableViewCell();
    }
    
}
