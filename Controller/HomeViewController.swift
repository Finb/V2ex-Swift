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
import MJRefresh

let kHomeTab = "me.fin.homeTab"

class HomeViewController: UIViewController {
    var topicList:Array<TopicListModel>?
    var tab:String? = nil
    var currentPage = 0
    
    private var _tableView :UITableView!
    private var tableView: UITableView {
        get{
            if(_tableView != nil){
                return _tableView!;
            }
            _tableView = UITableView();
            _tableView.scrollsToTop = true
            _tableView.separatorStyle = UITableViewCellSeparatorStyle.None;
            
            regClass(_tableView, cell: HomeTopicListTableViewCell.self);
            
            _tableView.delegate = self;
            _tableView.dataSource = self;
            return _tableView!;
            
        }
    }
    override func viewWillAppear(animated: Bool) {
        V2Client.sharedInstance.drawerController?.openDrawerGestureModeMask = .PanningCenterView
    }
    override func viewWillDisappear(animated: Bool) {
        V2Client.sharedInstance.drawerController?.openDrawerGestureModeMask = []
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title="V2EX";
        self.tab = V2EXSettings.sharedInstance[kHomeTab]
        self.setupNavigationItem()
        
        //监听程序即将进入前台运行、进入后台休眠 事件
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillEnterForeground", name: UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidEnterBackground", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
        self.view.addSubview(self.tableView);
        self.tableView.snp_makeConstraints{ (make) -> Void in
            make.top.right.bottom.left.equalTo(self.view);
        }
        self.tableView.mj_header = V2RefreshHeader(refreshingBlock: {[weak self] () -> Void in
            self?.refresh()
        })
        self.refreshPage()
        
        let footer = V2RefreshFooter(refreshingBlock: {[weak self] () -> Void in
            self?.getNextPage()
        })
        footer.centerOffset = -4
        self.tableView.mj_footer = footer
        
        self.KVOController.observe(V2EXColor.sharedInstance, keyPath: "style", options: [.Initial,.New]) {[weak self] (nav, color, change) -> Void in
            self?.tableView.backgroundColor = V2EXColor.colors.v2_backgroundColor
        }
    }
    func setupNavigationItem(){
        let leftButton = NotificationMenuButton()
        leftButton.frame = CGRectMake(0, 0, 40, 40)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftButton)
        leftButton.addTarget(self, action: Selector("leftClick"), forControlEvents: .TouchUpInside)
        
        
        let rightButton = UIButton(frame: CGRectMake(0, 0, 40, 40))
        rightButton.contentMode = .Center
        rightButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -15)
        rightButton.setImage(UIImage.imageUsedTemplateMode("ic_more_horiz_36pt")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        rightButton.addTarget(self, action: Selector("rightClick"), forControlEvents: .TouchUpInside)

    }
    func leftClick(){
        V2Client.sharedInstance.drawerController?.toggleLeftDrawerSideAnimated(true, completion: nil)
    }
    func rightClick(){
        V2Client.sharedInstance.drawerController?.toggleRightDrawerSideAnimated(true, completion: nil)
    }
    
    func refreshPage(){
        self.tableView.mj_header.beginRefreshing();
        V2EXSettings.sharedInstance[kHomeTab] = tab
    }
    func refresh(){
        
        //如果有上拉加载更多 正在执行，则取消它
        if self.tableView.mj_footer.isRefreshing() {
            self.tableView.mj_footer.endRefreshing()
        }
        
        //根据 tab name 获取帖子列表
        TopicListModel.getTopicList(tab){
            (response:V2ValueResponse<[TopicListModel]>) -> Void in
            
            if response.success {
                
                self.topicList = response.value
                self.tableView.reloadData()
                
                //判断标签是否能加载下一页, 不能就提示下
                let refreshFooter = self.tableView.mj_footer as! V2RefreshFooter
                if self.tab == nil || self.tab == "all" {
                    refreshFooter.noMoreDataStateString = nil
                    refreshFooter.resetNoMoreData()
                }
                else{
                    refreshFooter.noMoreDataStateString = "没更多帖子了,只有【\(NSLocalizedString("all"))】标签能翻页"
                    refreshFooter.endRefreshingWithNoMoreData()
                }
                
                //重置page
                self.currentPage = 0
                
            }
            self.tableView.mj_header.endRefreshing()
        }
    }
    
    func getNextPage(){
        if self.topicList == nil || self.topicList?.count <= 0{
            self.tableView.mj_footer.endRefreshing()
            return;
        }
        //根据 tab name 获取帖子列表
        self.currentPage++
        TopicListModel.getTopicList(tab,page: self.currentPage){
            (response:V2ValueResponse<[TopicListModel]>) -> Void in
            
            if response.success {
                if response.value?.count > 0 {
                    self.topicList! += response.value!
                    self.tableView.reloadData()
                }
            }
            else{
                //加载失败，重置page
                self.currentPage--
            }
            self.tableView.mj_footer.endRefreshing()
        }
    }
    
    static var lastLeaveTime = NSDate()
    func applicationWillEnterForeground(){
        //计算上次离开的时间与当前时间差
        //如果超过2分钟，则自动刷新本页面。
        let interval = -1 * HomeViewController.lastLeaveTime.timeIntervalSinceNow
        if interval > 120 {
            self.tableView.mj_header.beginRefreshing()
        }
    }
    func applicationDidEnterBackground(){
        HomeViewController.lastLeaveTime = NSDate()
    }
}


//MARK: - TableViewDataSource
extension HomeViewController:UITableViewDataSource,UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let list = self.topicList {
            return list.count;
        }
        return 0;
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let item = self.topicList![indexPath.row]
        let titleHeight = item.topicTitleLayout?.textBoundingRect.size.height ?? 0
        //          上间隔   头像高度  头像下间隔       标题高度    标题下间隔 cell间隔
        let height = 12    +  35     +  12      + titleHeight   + 12      + 8

        return height
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = getCell(tableView, cell: HomeTopicListTableViewCell.self, indexPath: indexPath);
        cell.bind(self.topicList![indexPath.row]);
        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = self.topicList![indexPath.row]
        
        if let id = item.topicId {
            let topicDetailController = TopicDetailViewController();
            topicDetailController.topicId = id ;
            topicDetailController.ignoreTopicHandler = {[weak self] (topicId) in
                self?.performSelector("ignoreTopicHandler:", withObject: topicId, afterDelay: 0.6)
            }
            self.navigationController?.pushViewController(topicDetailController, animated: true)
            tableView .deselectRowAtIndexPath(indexPath, animated: true);
        }
    }
    
    func ignoreTopicHandler(topicId:String) {
        let index = self.topicList?.indexOf({$0.topicId == topicId })
        if index == nil {
            return
        }
        
        //看当前忽略的cell 是否在可视列表里
        let indexPaths = self.tableView.indexPathsForVisibleRows
        let visibleIndex =  indexPaths?.indexOf({$0.row == index})
        
        self.topicList?.removeAtIndex(index!)
        //如果不在可视列表，则直接reloadData 就可以
        if visibleIndex == nil {
            self.tableView.reloadData()
        }
        
        //如果在可视列表，则动画删除它
        self.tableView.beginUpdates()
        
        self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: index!, inSection: 0)], withRowAnimation: .Fade)
        
        self.tableView.endUpdates()
        

    }
}
