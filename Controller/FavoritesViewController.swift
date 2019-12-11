//
//  FavoritesViewController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/30/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

class FavoritesViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate {
    var topicList:[TopicListModel]?
    var currentPage = 1
    //最大的Page
    var maxPage = 1
    fileprivate lazy var tableView: UITableView = {
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
        self.title = NSLocalizedString("favorites")
        self.view.addSubview(self.tableView);
        self.tableView.snp.makeConstraints{ (make) -> Void in
            make.top.right.bottom.left.equalTo(self.view);
        }
        
        self.showLoadingView()
        
        self.tableView.mj_header = V2RefreshHeader(refreshingBlock: {[weak self] () -> Void in
            self?.refresh()
        })
        self.tableView.mj_header.beginRefreshing()
        
        let footer = V2RefreshFooter(refreshingBlock: {[weak self] () -> Void in
            self?.getNextPage()
            })
        footer?.centerOffset = -4
        self.tableView.mj_footer = footer
        
        self.themeChangedHandler = {[weak self] _ in
            self?.view.backgroundColor = V2EXColor.colors.v2_backgroundColor
            self?.tableView.backgroundColor = V2EXColor.colors.v2_backgroundColor
        }
    }
    
    func refresh(){
        //根据 tab name 获取帖子列表
        self.currentPage = 1
        
        _ = TopicListApi.provider
            .requestAPI(.favoriteList(page: self.currentPage))
            .getJiDataFirst(hander: { (ji) in
                var maxPage = 1
                if let aRootNode = ji.xPath("//*[@class='page_normal']")?.last
                    , let page = aRootNode.content
                    , let pageInt = Int(page)
                {
                    maxPage = pageInt
                }
                self.maxPage = maxPage
            })
            .mapResponseToJiArray(FavoriteListModel.self)
            .subscribe(onNext: { (response) in
                self.topicList = response
                self.tableView.mj_footer.resetNoMoreData()
                self.tableView.reloadData()
                
                self.tableView.mj_header.endRefreshing()
                self.hideLoadingView()
            }, onError: { (error) in
                V2Error(error.rawString())
                
                self.tableView.mj_header.endRefreshing()
                self.hideLoadingView()
            })
        
    }
    func getNextPage(){
        if let count = self.topicList?.count, count <= 0 {
            self.tableView.mj_footer.endRefreshing()
            return;
        }
        if self.currentPage >= maxPage {
            self.tableView.mj_footer.endRefreshingWithNoMoreData()
            return;
        }
        self.currentPage += 1
        
        _ = TopicListApi.provider
            .requestAPI(.favoriteList(page: self.currentPage))
            .mapResponseToJiArray(FavoriteListModel.self)
            .subscribe(onNext: { (response) in
                self.topicList?.append(contentsOf: response)
                self.tableView.reloadData()
                self.tableView.mj_footer.endRefreshing()
            }, onError: { (error) in
                self.currentPage -= 1
                V2Error(error.rawString())
            })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let list = self.topicList {
            return list.count;
        }
        return 0;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = self.topicList![indexPath.row]
        let titleHeight = item.topicTitleLayout?.textBoundingRect.size.height ?? 0
        //          上间隔   头像高度  头像下间隔       标题高度    标题下间隔 cell间隔
        let height = 12    +  35     +  12      + titleHeight   + 12      + 8
        return height
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
            self.navigationController?.pushViewController(topicDetailController, animated: true)
            tableView .deselectRow(at: indexPath, animated: true);
        }
    }
}
