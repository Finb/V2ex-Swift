//
//  TopicDetailViewController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/16/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import SVProgressHUD
class TopicDetailViewController: BaseViewController, UITableViewDelegate,UITableViewDataSource ,UIActionSheetDelegate{

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
            
            _tableView.backgroundColor = V2EXColor.colors.v2_backgroundColor
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
        
        let rightButton = UIButton(frame: CGRectMake(0, 0, 40, 40))
        rightButton.contentMode = .Center
        rightButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -15)
        rightButton.setImage(UIImage(named: "ic_speaker_notes")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        rightButton.addTarget(self, action: Selector("rightClick"), forControlEvents: .TouchUpInside)
        
        //根据 topicId 获取 帖子信息 、回复。
        TopicDetailModel.getTopicDetailById(self.topicId){
            (response:V2ValueResponse<(TopicDetailModel?,[TopicCommentModel])>) -> Void in
            if response.success {
                
                if let aModel = response.value!.0{
                    self.model = aModel
                    self.tableView.fin_reloadData()
                }
                
                self.commentsArray = response.value!.1
                
                self.tableView.fin_reloadData()
            }
            self.hideLoadingView()
        }
        
        self.showLoadingView()
    }
    
    func rightClick(){
        if let model = self.model {
            let replyViewController = ReplyingViewController()
            replyViewController.topicModel = model
            let nav = V2EXNavigationController(rootViewController:replyViewController)
            self.navigationController?.presentViewController(nav, animated: true, completion:nil)
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
        else if section == 1{
            return self.commentsArray.count;
        }
        else {
            return 0;
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
                if self.webViewContentCell?.contentHeight > 0 {
                    return self.webViewContentCell!.contentHeight
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
            let layout = self.commentsArray[indexPath.row].textLayout!
            return layout.textBoundingRect.size.height + 12 + 35 + 12 + 12 + 1
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
                    if let weakSelf = self {
                        //在cell显示在屏幕时更新，否则会崩溃会崩溃会崩溃
                        if weakSelf.tableView.visibleCells.contains(weakSelf.webViewContentCell!) {
                            if weakSelf.webViewContentCell?.contentHeight > 1.5 * SCREEN_HEIGHT{ //太长了就别动画了。。
                                UIView.animateWithDuration(0, animations: { () -> Void in
                                    self?.tableView.beginUpdates()
                                    self?.tableView.endUpdates()
                                })
                            }
                            else {
                                self?.tableView.beginUpdates()
                                self?.tableView.endUpdates()
                            }
                        }
                    }
                }
                return self.webViewContentCell!
            }
            
            else if indexPath.row == 2 {
                let cell = getCell(tableView, cell: BaseDetailTableViewCell.self, indexPath: indexPath)
                cell.detailMarkHidden = true
                cell.titleLabel?.text = self.model?.topicCommentTotalCount
                cell.titleLabel?.font = v2Font(12)
                cell.backgroundColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
                cell.separator?.image = createImageWithColor(self.view.backgroundColor!)
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: "回复", "感谢")
            actionSheet.tag = indexPath.row
            actionSheet.showInView(self.view)
        }
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        
        tableView .deselectRowAtIndexPath(NSIndexPath(forRow: actionSheet.tag, inSection: 1), animated: true);
        switch buttonIndex {
        case 1 : //回复
            let item = self.commentsArray[actionSheet.tag]
            let replyViewController = ReplyingViewController()
            replyViewController.atSomeone = "@" + item.userName! + " "
            replyViewController.topicModel = self.model!
            let nav = V2EXNavigationController(rootViewController:replyViewController)
            self.navigationController?.presentViewController(nav, animated: true, completion:nil)
            
        case 2://感谢
            let row = actionSheet.tag
            let item = self.commentsArray[row]
            if item.replyId == nil {
                SVProgressHUD.showErrorWithStatus("回复replyId为空")
                return;
            }
            if self.model?.token == nil {
                SVProgressHUD.showErrorWithStatus("帖子token为空")
                return;
            }
            item.favorites++
            self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: row, inSection: 1)], withRowAnimation: .None)
            
            TopicCommentModel.replyThankWithReplyId(item.replyId!, token: self.model!.token!) {
                [weak item, weak self](response) in
                if response.success {
                }
                else{
                    SVProgressHUD.showSuccessWithStatus("感谢失败了")
                    //失败后 取消增加的数量
                    item?.favorites--
                    self?.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: row, inSection: 1)], withRowAnimation: .None)
                }
            }
        default :
            break
        }
    }
    
    
}
