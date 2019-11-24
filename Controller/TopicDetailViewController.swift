//
//  TopicDetailViewController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/16/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

class TopicDetailViewController: BaseViewController{
    
    var topicId = "0"
    var currentPage = 1
    
    fileprivate var model:TopicDetailModel?
    fileprivate var commentsArray:[TopicCommentModel] = []
    fileprivate var webViewContentCell:TopicDetailWebViewContentCell?
    
    fileprivate enum Order {
        case asc
        case desc
    }
    
    //评论排序
    fileprivate var commentSort = Order.asc
    
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.cancelEstimatedHeight()
        tableView.separatorStyle = .none;
        
        tableView.backgroundColor = V2EXColor.colors.v2_backgroundColor
        regClass(tableView, cell: TopicDetailHeaderCell.self)
        regClass(tableView, cell: TopicDetailWebViewContentCell.self)
        regClass(tableView, cell: TopicDetailCommentCell.self)
        regClass(tableView, cell: BaseDetailTableViewCell.self)
        regClass(tableView, cell: TopicDetailToolCell.self)
        
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    /// 忽略帖子成功后 ，调用的闭包
    var ignoreTopicHandler : ((String) -> Void)?
    //点击右上角more按钮后，弹出的 activityView
    //只在activityView 显示在屏幕上持有它，如果activityView释放了，这里也一起释放。
    fileprivate weak var activityView:V2ActivityViewController?
    
    //MARK: - 页面事件
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("postDetails")
        self.view.backgroundColor = V2EXColor.colors.v2_backgroundColor
        self.view.addSubview(self.tableView);
        self.tableView.snp.makeConstraints{ (make) -> Void in
            make.top.right.bottom.left.equalTo(self.view);
        }
        
        let rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        rightButton.contentMode = .center
        rightButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -15)
        rightButton.setImage(UIImage(named: "ic_more_horiz_36pt")!.withRenderingMode(.alwaysTemplate), for: .normal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        rightButton.addTarget(self, action: #selector(TopicDetailViewController.rightClick), for: .touchUpInside)
        
        
        self.showLoadingView()
        self.getData()
        
        self.tableView.mj_header = V2RefreshHeader(refreshingBlock: {[weak self] in
            self?.getData()
        })
        self.tableView.mj_footer = V2RefreshFooter(refreshingBlock: {[weak self] in
            self?.getNextPage()
        })
    }
    
    func getData(){
        //根据 topicId 获取 帖子信息 、回复。
        TopicDetailModel.getTopicDetailById(self.topicId){
            (response:V2ValueResponse<(TopicDetailModel?,[TopicCommentModel])>) -> Void in
            if response.success {
                
                if let aModel = response.value!.0{
                    self.model = aModel
                }
                self.commentSort = .asc
                
                self.commentsArray = response.value!.1
                
                self.currentPage = 1
                
                //清除将帖子内容cell,因为这是个缓存，如果赋值后，就会cache到这个变量，之后直接读这个变量不重新赋值。
                //这里刷新了，则可能需要更新帖子内容cell ,实际上只是重新调用了 cell.load(_:)方法
                self.webViewContentCell = nil
                
                self.tableView.reloadData()
                
            }
            else{
                V2Error(response.message);
            }
            if self.tableView.mj_header.isRefreshing{
                self.tableView.mj_header.endRefreshing()
            }
            self.tableView.mj_footer.resetNoMoreData()
            self.hideLoadingView()
        }
    }
    
    /**
     点击右上角 more 按钮
     */
    @objc func rightClick(){
        if  self.model != nil {
            let activityView = V2ActivityViewController()
            activityView.dataSource = self
            self.navigationController!.present(activityView, animated: true, completion: nil)
            self.activityView = activityView
        }
    }
    /**
     点击节点
     */
    func nodeClick() {
       let node = NodeModel()
        node.nodeId = self.model?.node
        node.nodeName = self.model?.nodeName
        let controller = NodeTopicListViewController()
        controller.node = node
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    /**
     获取下一页评论，如果有的话
     */
    func getNextPage(){
        if self.model == nil{
            self.endRefreshingWithNoDataAtAll()
            return;
        }
        if self.commentSort == .asc {
            self.currentPage += 1
        }
        else{
            self.currentPage -= 1
        }
        
        if self.model == nil
            || self.currentPage > self.model!.commentTotalPages
            || self.currentPage <= 0 {
            self.endRefreshingWithNoMoreData()
            return;
        }
        
        TopicDetailModel.getTopicCommentsById(self.topicId, page: self.currentPage) { (response) -> Void in
            if response.success {
                if self.needsClearOldComments {
                    self.needsClearOldComments = false
                    self.commentsArray.removeAll()
                }
                var arr = response.value!
                if self.commentSort == .desc {
                    arr = arr.reversed()
                    if self.currentPage == 0 {
                        self.endRefreshingWithNoMoreData()
                    }
                }
                else {
                    if self.currentPage == self.model?.commentTotalPages {
                        self.endRefreshingWithNoMoreData()
                    }
                }
                self.commentsArray += arr
                self.tableView.reloadData()
                self.tableView.mj_footer.endRefreshing()
            }
            else{
                self.currentPage -= 1
            }
        }
    }
    
    var needsClearOldComments = false;
    func toggleSoryType(){
        guard self.model != nil
            && !self.tableView.mj_footer.isRefreshing
            && !self.tableView.mj_header.isRefreshing
            else {
            return
        }
        self.commentSort = self.commentSort == .asc ? .desc : .asc;
        if self.commentSort == .asc {
            self.currentPage = 0
        }
        else {
            self.currentPage = self.model!.commentTotalPages + 1;
        }
        self.tableView.mj_footer.resetNoMoreData()
        needsClearOldComments = true
        self.getNextPage()
    }
    
    /**
     禁用上拉加载更多，并显示一个字符串提醒
     */
    func endRefreshingWithStateString(_ string:String){
        (self.tableView.mj_footer as! V2RefreshFooter).noMoreDataStateString = string
        self.tableView.mj_footer.endRefreshingWithNoMoreData()
    }

    func endRefreshingWithNoDataAtAll() {
        self.endRefreshingWithStateString("暂无评论")
    }

    func endRefreshingWithNoMoreData() {
        self.endRefreshingWithStateString("没有更多评论了")
    }
}



//MARK: - UITableView DataSource
enum TopicDetailTableViewSection: Int {
    case header = 0, comment, other
}

enum TopicDetailHeaderComponent: Int {
    case title = 0,  webViewContent, other
}

extension TopicDetailViewController: UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let _section = TopicDetailTableViewSection(rawValue: section)!
        switch _section {
        case .header:
            if self.model != nil{
                return 3
            }
            else{
                return 0
            }
        case .comment:
            return self.commentsArray.count;
        case .other:
            return 0;
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let _section = TopicDetailTableViewSection(rawValue: indexPath.section)!
        var _headerComponent = TopicDetailHeaderComponent.other
        if let headerComponent = TopicDetailHeaderComponent(rawValue: indexPath.row) {
            _headerComponent = headerComponent
        }
        switch _section {
        case .header:
            switch _headerComponent {
            case .title:
                return tableView.fin_heightForCellWithIdentifier(TopicDetailHeaderCell.self, indexPath: indexPath) { (cell) -> Void in
                    cell.bind(self.model!);
                }
            case .webViewContent:
                if let height =  self.webViewContentCell?.contentHeight , height > 0 {
                    return self.webViewContentCell!.contentHeight
                }
                else {
                    return 1
                }
            case .other:
                return 45
            }
        case .comment:
            let layout = self.commentsArray[indexPath.row].textLayout!
            return layout.textBoundingRect.size.height + 1 + 12 + 35 + 12 + 12 + 1
        case .other:
            return 200
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let _section = TopicDetailTableViewSection(rawValue: indexPath.section)!
        var _headerComponent = TopicDetailHeaderComponent.other
        if let headerComponent = TopicDetailHeaderComponent(rawValue: indexPath.row) {
            _headerComponent = headerComponent
        }

        switch _section {
        case .header:
            switch _headerComponent {
            case .title:
                //帖子标题
                let cell = getCell(tableView, cell: TopicDetailHeaderCell.self, indexPath: indexPath);
                if(cell.nodeClickHandler == nil){
                    cell.nodeClickHandler = {[weak self] () -> Void in
                        self?.nodeClick()
                    }
                }
                cell.bind(self.model!);
                return cell;
            case .webViewContent:
                //帖子内容
                if self.webViewContentCell == nil {
                    self.webViewContentCell = getCell(tableView, cell: TopicDetailWebViewContentCell.self, indexPath: indexPath);
                    self.webViewContentCell?.parentScrollView = self.tableView
                }
                else {
                    return self.webViewContentCell!
                }
                self.webViewContentCell!.load(self.model!);
                if self.webViewContentCell!.contentHeightChanged == nil {
                    self.webViewContentCell!.contentHeightChanged = { [weak self] (height:CGFloat) -> Void  in
                        if let weakSelf = self {
                            //在cell显示在屏幕时更新，否则会崩溃会崩溃会崩溃
                            //另外刷新清空旧cell,重新创建这个cell ,所以 contentHeightChanged 需要判断cell是否为nil
                            if let cell = weakSelf.webViewContentCell, weakSelf.tableView.visibleCells.contains(cell) {
                                if let height = weakSelf.webViewContentCell?.contentHeight, height > 1.5 * SCREEN_HEIGHT{ //太长了就别动画了。。
                                    UIView.animate(withDuration: 0, animations: { () -> Void in
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
                }
                return self.webViewContentCell!
            case .other:
                let cell = getCell(tableView, cell: TopicDetailToolCell.self, indexPath: indexPath)
                cell.titleLabel.text = self.model?.topicCommentTotalCount
                cell.sortButton.setTitle(self.commentSort == .asc ? "顺序查看" : "倒序查看", for: .normal)
                if cell.sortButtonClick == nil {
                    cell.sortButtonClick = {[weak self] sender in
                        sender.setTitle("正在加载", for: .normal)
                        self?.toggleSoryType()
                    }
                }
                return cell
            }
        case .comment:
            let cell = getCell(tableView, cell: TopicDetailCommentCell.self, indexPath: indexPath)
            let comment = self.commentsArray[indexPath.row]
            cell.bind(comment)
            cell.isAuthor = self.model?.userName == comment.userName
            return cell
        case .other:
            return UITableViewCell();
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            self.selectedRowWithActionSheet(indexPath)
        }
    }
}




//MARK: - actionSheet
extension TopicDetailViewController: UIActionSheetDelegate {
    func selectedRowWithActionSheet(_ indexPath:IndexPath){
        self.tableView.deselectRow(at: indexPath, animated: true);

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
        actionSheet.show(in: self.view)
        
    }
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        guard buttonIndex > 0 && buttonIndex <= 3 else{
            return
        }
        self.perform([#selector(TopicDetailViewController.replyComment(_:)),
                      #selector(TopicDetailViewController.thankComment(_:)),
                      #selector(TopicDetailViewController.relevantComment(_:))][buttonIndex - 1],
                     with: actionSheet.tag)
    }
    @objc func replyComment(_ row:NSNumber){
        V2User.sharedInstance.ensureLoginWithHandler {
            let item = self.commentsArray[row as! Int]
            let replyViewController = ReplyingViewController()
            replyViewController.atSomeone = "@" + item.userName! + " "
            replyViewController.topicModel = self.model!
            let nav = V2EXNavigationController(rootViewController:replyViewController)
            self.navigationController?.present(nav, animated: true, completion:nil)
        }
    }
    @objc func thankComment(_ row:NSNumber){
        guard V2User.sharedInstance.isLogin else {
            V2Inform("请先登录")
            return;
        }
        let item = self.commentsArray[row as! Int]
        if item.replyId == nil {
            V2Error("回复replyId为空")
            return;
        }
        if self.model?.token == nil {
            V2Error("帖子token为空")
            return;
        }
        item.favorites += 1
        self.tableView.reloadRows(at: [IndexPath(row: row as! Int, section: 1)], with: .none)
        V2User.sharedInstance.getOnce { (response) -> Void in
            if response.success , let once = V2User.sharedInstance.once {
                TopicCommentModel.replyThankWithReplyId(item.replyId!, token:once ) {
                    [weak item, weak self](response) in
                    if response.success {
                    }
                    else{
                        V2Error("感谢失败了")
                        //失败后 取消增加的数量
                        item?.favorites -= 1
                        self?.tableView.reloadRows(at: [IndexPath(row: row as! Int, section: 1)], with: .none)
                    }
                }
            }
            else{
                V2Error("获取 once 失败")
            }
        }
    }
    @objc func relevantComment(_ row:NSNumber){
        let item = self.commentsArray[row as! Int]
        let sourceArr = self.commentSort == .asc ? self.commentsArray : self.commentsArray.reversed()
        let relevantComments = TopicCommentModel.getRelevantCommentsInArray(sourceArr, firstComment: item)
        if relevantComments.count <= 0 {
            return;
        }
        let controller = RelevantCommentsNav(comments: relevantComments)
        self.present(controller, animated: true, completion: nil)
    }
}



//MARK: - V2ActivityView
enum V2ActivityViewTopicDetailAction : Int {
    case block = 0, favorite, grade, share, explore
}

extension TopicDetailViewController: V2ActivityViewDataSource {
    func V2ActivityView(_ activityView: V2ActivityViewController, numberOfCellsInSection section: Int) -> Int {
        return 5
    }
    func V2ActivityView(_ activityView: V2ActivityViewController, ActivityAtIndexPath indexPath: IndexPath) -> V2Activity {
        return V2Activity(title: [
            NSLocalizedString("ignore"),
            NSLocalizedString("favorite"),
            NSLocalizedString("thank"),
            NSLocalizedString("share"),
            "Safari"][indexPath.row], image: UIImage(named: ["ic_block_48pt","ic_grade_48pt","ic_favorite_48pt","ic_share_48pt","ic_explore_48pt"][indexPath.row])!)
    }
    func V2ActivityView(_ activityView:V2ActivityViewController ,heightForFooterInSection section: Int) -> CGFloat{
        return 45
    }
    func V2ActivityView(_ activityView:V2ActivityViewController ,viewForFooterInSection section: Int) ->UIView?{
        let view = UIView()
        view.backgroundColor = V2EXColor.colors.v2_ButtonBackgroundColor
        
        let label = UILabel()
        label.font = v2Font(18)
        label.text = NSLocalizedString("reply2")
        label.textAlignment = .center
        label.textColor = UIColor.white
        view.addSubview(label)
        label.snp.makeConstraints{ (make) -> Void in
            make.top.right.bottom.left.equalTo(view)
        }
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TopicDetailViewController.reply)))
        
        return view
    }
    
    func V2ActivityView(_ activityView: V2ActivityViewController, didSelectRowAtIndexPath indexPath: IndexPath) {
        activityView.dismiss()
        let action = V2ActivityViewTopicDetailAction(rawValue: indexPath.row)!
        
        guard V2User.sharedInstance.isLogin
            // 用safari打开是不用登录的
            || action == V2ActivityViewTopicDetailAction.explore
            || action == V2ActivityViewTopicDetailAction.share else {
            V2Inform("请先登录")
            return;
        }
        switch action {
        case .block:
            V2BeginLoading()
            if let topicId = self.model?.topicId  {
                TopicDetailModel.ignoreTopicWithTopicId(topicId, completionHandler: {[weak self] (response) -> Void in
                    if response.success {
                        V2Success("忽略成功")
                        self?.navigationController?.popViewController(animated: true)
                        self?.ignoreTopicHandler?(topicId)
                    }
                    else{
                        V2Error("忽略失败")
                    }
                    })
            }
        case .favorite:
            V2BeginLoading()
            if let topicId = self.model?.topicId ,let token = self.model?.token {
                TopicDetailModel.favoriteTopicWithTopicId(topicId, token: token, completionHandler: { (response) -> Void in
                    if response.success {
                        V2Success("收藏成功")
                    }
                    else{
                        V2Error("收藏失败")
                    }
                })
            }
        case .grade:
            V2BeginLoading()
            
            V2User.sharedInstance.getOnce { (response) -> Void in
                if response.success , let once = V2User.sharedInstance.once {
                    TopicDetailModel.topicThankWithTopicId(self.model?.topicId ?? "", token: once, completionHandler: { (response) -> Void in
                        if response.success {
                            V2Success("成功送了一波铜币")
                        }
                        else{
                            V2Error(response.message)
                        }
                    })
                }
                else{
                    V2Error("获取 once 失败")
                }
            }

        case .share:
            let shareUrl = NSURL.init(string: V2EXURL + "t/" + self.model!.topicId!)
            let shareArr:NSArray = [shareUrl!]
            let activityController = UIActivityViewController.init(activityItems: shareArr as [AnyObject], applicationActivities: nil)
            activityController.excludedActivityTypes = [UIActivity.ActivityType.airDrop]
            self.navigationController?.present(activityController, animated: true, completion: nil)
        case .explore:
            UIApplication.shared.openURL(URL(string: V2EXURL + "t/" + self.model!.topicId!)!)
        }
    }
    
    @objc func reply(){
        self.activityView?.dismiss()
        V2User.sharedInstance.ensureLoginWithHandler {
            let replyViewController = ReplyingViewController()
            replyViewController.topicModel = self.model!
            let nav = V2EXNavigationController(rootViewController:replyViewController)
            self.navigationController?.present(nav, animated: true, completion:nil)
        }
    }
    
}
