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

import SVProgressHUD

let kHomeTab = "me.fin.homeTab"

class HomeViewController: UIViewController {
    var topicList:Array<TopicListModel>?
    var tab:String? = nil {
        didSet{
            var name = "全部"
            for model in RightViewControllerRightNodes {
                if model.nodeTab == tab {
                    name = model.nodeName ?? ""
                    break;
                }
            }
            self.title = name
        }
    }
    var currentPage = 0
    
    fileprivate lazy var tableView: UITableView  = {
        let tableView = UITableView()
        tableView.cancelEstimatedHeight()
        tableView.separatorStyle = .none
        
        regClass(tableView, cell: HomeTopicListTableViewCell.self)
        
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tab = V2EXSettings.sharedInstance[kHomeTab]
        self.setupNavigationItem()
        
        //监听程序即将进入前台运行、进入后台休眠 事件
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.applicationWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        self.view.addSubview(self.tableView);
        self.tableView.snp.makeConstraints{ (make) -> Void in
            make.top.right.bottom.left.equalTo(self.view);
        }
        self.tableView.mj_header = V2RefreshHeader(refreshingBlock: {[weak self] () -> Void in
            self?.refresh()
        })
        self.refreshPage()
        
        let footer = V2RefreshFooter(refreshingBlock: {[weak self] () -> Void in
            self?.getNextPage()
        })
        footer?.centerOffset = -4
        self.tableView.mj_footer = footer
        
        self.themeChangedHandler = {[weak self] (style) -> Void in
            self?.tableView.backgroundColor = V2EXColor.colors.v2_backgroundColor
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        V2Client.sharedInstance.drawerController?.openDrawerGestureModeMask = .panningCenterView
    }
    override func viewWillDisappear(_ animated: Bool) {
        V2Client.sharedInstance.drawerController?.openDrawerGestureModeMask = []
    }
    func setupNavigationItem(){
        let leftButton = NotificationMenuButton()
        leftButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftButton)
        leftButton.addTarget(self, action: #selector(HomeViewController.leftClick), for: .touchUpInside)
        
        
        let rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        rightButton.contentMode = .center
        rightButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -15)
        rightButton.setImage(UIImage.imageUsedTemplateMode("ic_more_horiz_36pt")!.withRenderingMode(.alwaysTemplate), for: .normal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        rightButton.addTarget(self, action: #selector(HomeViewController.rightClick), for: .touchUpInside)

    }
    @objc func leftClick(){
        V2Client.sharedInstance.drawerController?.toggleLeftDrawerSide(animated: true, completion: nil)
    }
    @objc func rightClick(){
        V2Client.sharedInstance.drawerController?.toggleRightDrawerSide(animated: true, completion: nil)
    }
    
    func refreshPage(){
        self.tableView.mj_header.beginRefreshing();
        V2EXSettings.sharedInstance[kHomeTab] = tab
    }
    func refresh(){
        
        //如果有上拉加载更多 正在执行，则取消它
        if self.tableView.mj_footer.isRefreshing {
            self.tableView.mj_footer.endRefreshing()
        }
        
        //根据 tab name 获取帖子列表
        _ = TopicListApi.provider
            .requestAPI(.topicList(tab: tab, page: 0))
            .mapResponseToJiArray(TopicListModel.self)
            .subscribe(onNext: { (response) in
                self.topicList = response
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
                self.tableView.mj_header.endRefreshing()
                
            }, onError: { (error) in
                if let err = error as? ApiError {
                    switch err {
                    case .needs2FA:
                        V2Client.sharedInstance.centerViewController!.navigationController?.present(TwoFAViewController(), animated: true, completion: nil);
                    default:
                        SVProgressHUD.showError(withStatus: err.rawString())
                    }
                }
                else {
                    SVProgressHUD.showError(withStatus: error.rawString())
                }
                self.tableView.mj_header.endRefreshing()
            })
    }
    
    func getNextPage(){
        if let count = self.topicList?.count , count <= 0{
            self.tableView.mj_footer.endRefreshing()
            return;
        }
        
        //根据 tab name 获取帖子列表
        self.currentPage += 1
        _ = TopicListApi.provider
            .requestAPI(.topicList(tab: tab, page: self.currentPage))
            .mapResponseToJiArray(TopicListModel.self)
            .subscribe(onNext: { (response) in
                if response.count > 0 {
                    self.topicList? += response
                    self.tableView.reloadData()
                }
                self.tableView.mj_footer.endRefreshing()
            }, onError: { (error) in
                self.currentPage -= 1
                SVProgressHUD.showError(withStatus: error.rawString())
                self.tableView.mj_footer.endRefreshing()
            })
    }
    
    static var lastLeaveTime = Date()
    @objc func applicationWillEnterForeground(){
        //计算上次离开的时间与当前时间差
        //如果超过2分钟，则自动刷新本页面。
        let interval = -1 * HomeViewController.lastLeaveTime.timeIntervalSinceNow
        if interval > 120 {
            self.tableView.mj_header.beginRefreshing()
        }
    }
    @objc func applicationDidEnterBackground(){
        HomeViewController.lastLeaveTime = Date()
    }
}


//MARK: - TableViewDataSource
extension HomeViewController:UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let list = self.topicList {
            return list.count;
        }
        return 0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getCell(tableView, cell: HomeTopicListTableViewCell.self, indexPath: indexPath);
        cell.bind(self.topicList![indexPath.row]);
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.topicList![indexPath.row]
        
        if let id = item.topicId {
            let topicDetailController = TopicDetailViewController();
            topicDetailController.topicId = id ;
            topicDetailController.ignoreTopicHandler = {[weak self] (topicId) in
                self?.perform(#selector(HomeViewController.ignoreTopicHandler(_:)), with: topicId, afterDelay: 0.6)
            }
            self.navigationController?.pushViewController(topicDetailController, animated: true)
            tableView .deselectRow(at: indexPath, animated: true);
        }
    }
    
    @objc func ignoreTopicHandler(_ topicId:String) {
        guard let index = self.topicList?.firstIndex(where: {$0.topicId == topicId }) else  {
            return
        }
        
        //看当前忽略的cell 是否在可视列表里
        let indexPaths = self.tableView.indexPathsForVisibleRows
        let visibleIndex =  indexPaths?.firstIndex(where: {($0 as IndexPath).row == index})
        
        self.topicList?.remove(at: index)
        //如果不在可视列表，则直接reloadData 就可以
        if visibleIndex == nil {
            self.tableView.reloadData()
            return
        }
        
        //如果在可视列表，则动画删除它
        self.tableView.beginUpdates()
        
        self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
        
        self.tableView.endUpdates()
        

    }
}
