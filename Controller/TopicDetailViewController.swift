//
//  TopicDetailViewController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/16/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import SVProgressHUD
class TopicDetailViewController: BaseViewController{
    
    var topicId = "0"
    var currentPage = 1
    
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
    /// 忽略帖子成功后 ，调用的闭包
    var ignoreTopicHandler : ((String) -> Void)?
    //点击右上角more按钮后，弹出的 activityView
    //只在activityView 显示在屏幕上持有它，如果activityView释放了，这里也一起释放。
    private weak var activityView:V2ActivityViewController?
    
    //MARK: - 页面事件
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
        rightButton.setImage(UIImage(named: "ic_more_horiz_36pt")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        rightButton.addTarget(self, action: Selector("rightClick"), forControlEvents: .TouchUpInside)
        
        //根据 topicId 获取 帖子信息 、回复。
        TopicDetailModel.getTopicDetailById(self.topicId){
            (response:V2ValueResponse<(TopicDetailModel?,[TopicCommentModel])>) -> Void in
            if response.success {
                
                if let aModel = response.value!.0{
                    self.model = aModel
                }
                
                self.commentsArray = response.value!.1
                
                self.tableView.reloadData()
            }
            self.hideLoadingView()
        }
        
        self.tableView.mj_footer = V2RefreshFooter(refreshingBlock: {[weak self] () -> Void in
            self?.getNextPage()
            })
        
        self.showLoadingView()
    }
    
    /**
     点击右上角 more 按钮
     */
    func rightClick(){
        if  self.model != nil {
            let activityView = V2ActivityViewController()
            activityView.dataSource = self
            self.navigationController!.presentViewController(activityView, animated: true, completion: nil)
            self.activityView = activityView
        }
    }
    
    /**
     获取下一页评论，如果有的话
     */
    func getNextPage(){
        if self.model == nil || self.commentsArray.count <= 0 {
            self.endRefreshingWithNoMoreData("暂无评论")
            return;
        }
        self.currentPage++
        
        if self.currentPage > self.model?.totalPages {
            self.endRefreshingWithNoMoreData("没有更多评论了")
            return;
        }
        
        TopicDetailModel.getTopicCommentsById(self.topicId, page: self.currentPage) { (response) -> Void in
            if response.success {
                self.commentsArray += response.value!
                self.tableView.reloadData()
                self.tableView.mj_footer.endRefreshing()
                
                if self.currentPage == self.model?.totalPages {
                    self.endRefreshingWithNoMoreData("没有更多评论了")
                }
                
            }
            else{
                self.currentPage--
            }
        }
    }
    
    /**
     禁用上拉加载更多，并显示一个字符串提醒
     */
    func endRefreshingWithNoMoreData(noMoreString:String){
        (self.tableView.mj_footer as! V2RefreshFooter).noMoreDataStateString = noMoreString
        self.tableView.mj_footer.endRefreshingWithNoMoreData()
    }
}



//MARK: - UITableView DataSource
enum TopicDetailTableViewSection: Int {
    case Header = 0, Comment, Other
}

enum TopicDetailHeaderComponent: Int {
    case Title = 0,  WebViewContent, Other
}

extension TopicDetailViewController: UITableViewDelegate,UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let _section = TopicDetailTableViewSection(rawValue: section)!
        switch _section {
        case .Header:
            if self.model != nil{
                return 3
            }
            else{
                return 0
            }
        case .Comment:
            return self.commentsArray.count;
        case .Other:
            return 0;
        }
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let _section = TopicDetailTableViewSection(rawValue: indexPath.section)!
        var _headerComponent = TopicDetailHeaderComponent.Other
        if let headerComponent = TopicDetailHeaderComponent(rawValue: indexPath.row) {
            _headerComponent = headerComponent
        }
        switch _section {
        case .Header:
            switch _headerComponent {
            case .Title:
                return tableView.fin_heightForCellWithIdentifier(TopicDetailHeaderCell.self, indexPath: indexPath) { (cell) -> Void in
                    cell.bind(self.model!);
                }
            case .WebViewContent:
                if self.webViewContentCell?.contentHeight > 0 {
                    return self.webViewContentCell!.contentHeight
                }
                else {
                    return 1
                }
            case .Other:
                return 45
            }
        case .Comment:
            let layout = self.commentsArray[indexPath.row].textLayout!
            return layout.textBoundingRect.size.height + 12 + 35 + 12 + 12 + 1
        case .Other:
            return 200
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let _section = TopicDetailTableViewSection(rawValue: indexPath.section)!
        var _headerComponent = TopicDetailHeaderComponent.Other
        if let headerComponent = TopicDetailHeaderComponent(rawValue: indexPath.row) {
            _headerComponent = headerComponent
        }

        switch _section {
        case .Header:
            switch _headerComponent {
            case .Title:
                //帖子标题
                let cell = getCell(tableView, cell: TopicDetailHeaderCell.self, indexPath: indexPath);
                cell.bind(self.model!);
                return cell;
            case .WebViewContent:
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
            case .Other:
                let cell = getCell(tableView, cell: BaseDetailTableViewCell.self, indexPath: indexPath)
                cell.detailMarkHidden = true
                cell.titleLabel?.text = self.model?.topicCommentTotalCount
                cell.titleLabel?.font = v2Font(12)
                cell.backgroundColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
                cell.separator?.image = createImageWithColor(self.view.backgroundColor!)
                return cell
            }
        case .Comment:
            let cell = getCell(tableView, cell: TopicDetailCommentCell.self, indexPath: indexPath)
            cell.bind(self.commentsArray[indexPath.row])
            return cell
        case .Other:
            return UITableViewCell();
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            self.selectedRowWithActionSheet(indexPath)
        }
    }
}




//MARK: - actionSheet
extension TopicDetailViewController: UIActionSheetDelegate {
    func selectedRowWithActionSheet(indexPath:NSIndexPath){
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true);

        //这段代码也可以执行，但是当点击时，会有个0.3秒的dismiss动画。
        //然后再弹出回复页面或者查看对话页面。感觉太长了，暂时不用
//        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
//        let replyAction = UIAlertAction(title: "回复", style: .Default) { _ in
//            self.replyComment(indexPath.row)
//        }
//        let thankAction = UIAlertAction(title: "感谢", style: .Default) { _ in
//            self.thankComment(indexPath.row)
//        }
//        let relevantCommentsAction = UIAlertAction(title: "查看对话", style: .Default) { _ in
//            self.relevantComment(indexPath.row)
//        }
//        let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
//        //将action全加进actionSheet
//        [replyAction,thankAction,relevantCommentsAction,cancelAction].forEach { (action) -> () in
//            actionSheet.addAction(action)
//        }
//        self.navigationController?.presentViewController(actionSheet, animated: true, completion: nil)
        
        //这段代码在iOS8.3中弃用，但是现在还可以使用，先用着吧
        let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: "回复", "感谢" ,"查看对话")
        actionSheet.tag = indexPath.row
        actionSheet.showInView(self.view)
        
    }
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex > 0 && buttonIndex <= 3 {
            self.performSelector(["replyComment:","thankComment:","relevantComment:"][buttonIndex - 1], withObject: actionSheet.tag)
        }
    }
    func replyComment(row:NSNumber){
        V2Client.sharedInstance.ensureLoginWithHandler {
            let item = self.commentsArray[row as Int]
            let replyViewController = ReplyingViewController()
            replyViewController.atSomeone = "@" + item.userName! + " "
            replyViewController.topicModel = self.model!
            let nav = V2EXNavigationController(rootViewController:replyViewController)
            self.navigationController?.presentViewController(nav, animated: true, completion:nil)
        }
    }
    func thankComment(row:NSNumber){
        guard V2Client.sharedInstance.isLogin else {
            SVProgressHUD.showInfoWithStatus("请先登录")
            return;
        }
        let item = self.commentsArray[row as Int]
        if item.replyId == nil {
            SVProgressHUD.showErrorWithStatus("回复replyId为空")
            return;
        }
        if self.model?.token == nil {
            SVProgressHUD.showErrorWithStatus("帖子token为空")
            return;
        }
        item.favorites++
        self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: row as Int, inSection: 1)], withRowAnimation: .None)
        
        TopicCommentModel.replyThankWithReplyId(item.replyId!, token: self.model!.token!) {
            [weak item, weak self](response) in
            if response.success {
            }
            else{
                SVProgressHUD.showSuccessWithStatus("感谢失败了")
                //失败后 取消增加的数量
                item?.favorites--
                self?.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: row as Int, inSection: 1)], withRowAnimation: .None)
            }
        }
    }
    func relevantComment(row:NSNumber){
        let item = self.commentsArray[row as Int]
        let relevantComments = TopicCommentModel.getRelevantCommentsInArray(self.commentsArray, firstComment: item)
        if relevantComments.count <= 0 {
            return;
        }
        let controller = RelevantCommentsNav(comments: relevantComments)
        self.presentViewController(controller, animated: true, completion: nil)
    }
}



//MARK: - V2ActivityView
enum V2ActivityViewTopicDetailAction : Int {
    case Block = 0, Favorite, Grade, Explore
}

extension TopicDetailViewController: V2ActivityViewDataSource {
    func V2ActivityView(activityView: V2ActivityViewController, numberOfCellsInSection section: Int) -> Int {
        return 4
    }
    func V2ActivityView(activityView: V2ActivityViewController, ActivityAtIndexPath indexPath: NSIndexPath) -> V2Activity {
        return V2Activity(title: ["忽略","收藏","感谢","Safari"][indexPath.row], image: UIImage(named: ["ic_block_48pt","ic_grade_48pt","ic_favorite_48pt","ic_explore_48pt"][indexPath.row])!)
    }
    func V2ActivityView(activityView:V2ActivityViewController ,heightForFooterInSection section: Int) -> CGFloat{
        return 45
    }
    func V2ActivityView(activityView:V2ActivityViewController ,viewForFooterInSection section: Int) ->UIView?{
        let view = UIView()
        view.backgroundColor = V2EXColor.colors.v2_ButtonBackgroundColor
        
        let label = UILabel()
        label.font = v2Font(18)
        label.text = "回  复"
        label.textAlignment = .Center
        label.textColor = UIColor.whiteColor()
        view.addSubview(label)
        label.snp_makeConstraints{ (make) -> Void in
            make.top.right.bottom.left.equalTo(view)
        }
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "reply"))
        
        return view
    }
    
    func V2ActivityView(activityView: V2ActivityViewController, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        activityView.dismiss()
        // 用safari打开是不用登录的
        guard V2Client.sharedInstance.isLogin || indexPath.row == V2ActivityViewTopicDetailAction.Explore.rawValue else {
            SVProgressHUD.showInfoWithStatus("请先登录")
            return;
        }
        let action = V2ActivityViewTopicDetailAction(rawValue: indexPath.row)!
        switch action {
        case .Block:
            SVProgressHUD.show()
            if let topicId = self.model?.topicId  {
                TopicDetailModel.ignoreTopicWithTopicId(topicId, completionHandler: {[weak self] (response) -> Void in
                    if response.success {
                        SVProgressHUD.showSuccessWithStatus("忽略成功")
                        self?.navigationController?.popViewControllerAnimated(true)
                        self?.ignoreTopicHandler?(topicId)
                    }
                    else{
                        SVProgressHUD.showErrorWithStatus("忽略失败")
                    }
                    })
            }
        case .Favorite:
            SVProgressHUD.show()
            if let topicId = self.model?.topicId ,let token = self.model?.token {
                TopicDetailModel.favoriteTopicWithTopicId(topicId, token: token, completionHandler: { (response) -> Void in
                    if response.success {
                        SVProgressHUD.showSuccessWithStatus("收藏成功")
                    }
                    else{
                        SVProgressHUD.showErrorWithStatus("收藏失败")
                    }
                })
            }
        case .Grade:
            SVProgressHUD.show()
            if let topicId = self.model?.topicId ,let token = self.model?.token {
                TopicDetailModel.topicThankWithTopicId(topicId, token: token, completionHandler: { (response) -> Void in
                    if response.success {
                        SVProgressHUD.showSuccessWithStatus("成功送了一波铜币")
                    }
                    else{
                        SVProgressHUD.showErrorWithStatus("没感谢成功，再试一下吧")
                    }
                })
            }
        case .Explore:
            UIApplication.sharedApplication().openURL(NSURL(string: V2EXURL + "t/" + self.model!.topicId!)!)
        }
    }
    
    func reply(){
        self.activityView?.dismiss()
        V2Client.sharedInstance.ensureLoginWithHandler {
            let replyViewController = ReplyingViewController()
            replyViewController.topicModel = self.model!
            let nav = V2EXNavigationController(rootViewController:replyViewController)
            self.navigationController?.presentViewController(nav, animated: true, completion:nil)
        }
    }
    
}
