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
    var nodeId:String?
    var favorited:Bool = false
    var favoriteUrl:String? {
        didSet{
            let startIndex = favoriteUrl?.range(of: "/", options: .backwards, range: nil, locale: nil)
            let endIndex = favoriteUrl?.range(of: "?")
            let nodeId = favoriteUrl?[startIndex!.upperBound ..< endIndex!.lowerBound]
            if let nodeId = nodeId , let favoriteUrl = favoriteUrl {
                self.nodeId = String(nodeId)
                if favoriteUrl.hasPrefix("/favorite"){
                    favorited = false
                }
                else{
                    favorited = true
                }
                self.setupFavorite()
            }
        }
    }
    var followButton:UIButton?
    fileprivate var topicList:Array<TopicListModel>?
    var currentPage = 1
    
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.cancelEstimatedHeight()
        tableView.backgroundColor = V2EXColor.colors.v2_backgroundColor
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        regClass(tableView, cell: HomeTopicListTableViewCell.self)
        
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.node?.nodeId == nil {
            return;
        }

        self.title = self.node?.nodeName
        self.view.backgroundColor = V2EXColor.colors.v2_backgroundColor
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
        
    }
    func refresh(){

        self.currentPage = 1
        
        //如果有上拉加载更多 正在执行，则取消它
        if self.tableView.mj_footer.isRefreshing {
            self.tableView.mj_footer.endRefreshing()
        }
        
        //根据 tab name 获取帖子列表
        _ = TopicListApi.provider
            .requestAPI(.nodeTopicList(nodeName: self.node!.nodeId!, page: self.currentPage))
            .getJiDataFirst { (ji) in
                if let node = ji.xPath("//*[@id='Wrapper']/div/div[1]/div[1]/div[1]/a")?.first{
                    self.favoriteUrl = node["href"]
                }
            }
            .mapResponseToJiArray(NodeTopicListModel.self)
            .subscribe(onNext: { (response) in
                self.topicList = response
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
        
        if let count = self.topicList?.count, count <= 0{
            self.tableView.mj_footer.endRefreshing()
            return;
        }
        
        self.currentPage += 1
        
        _ = TopicListApi.provider
            .requestAPI(.nodeTopicList(nodeName: self.node!.nodeId!, page: self.currentPage))
            .mapResponseToJiArray(NodeTopicListModel.self)
            .subscribe(onNext: { (response) in
                self.topicList?.append(contentsOf: response)
                self.tableView.reloadData()
                
                self.tableView.mj_footer.endRefreshing()
            }, onError: { (error) in
                self.currentPage -= 1
                V2Error(error.rawString())
                
                self.tableView.mj_footer.endRefreshing()
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
        cell.bindNodeModel(self.topicList![indexPath.row]);
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

extension NodeTopicListViewController {
    func setupFavorite(){
        if(self.followButton != nil){
            return;
        }
        let followButton = UIButton(frame:CGRect(x: 0, y: 0, width: 26, height: 26))
        followButton.addTarget(self, action: #selector(toggleFavoriteState), for: .touchUpInside)
        
        let followItem = UIBarButtonItem(customView: followButton)
        
        //处理间距
        let fixedSpaceItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpaceItem.width = -5
        self.navigationItem.rightBarButtonItems = [fixedSpaceItem,followItem]
        
        self.followButton = followButton;
        refreshButtonImage()
    }
    
    func refreshButtonImage() {
        let followImage = self.favorited == true ? UIImage(named: "ic_favorite")! : UIImage(named: "ic_favorite_border")!
        self.followButton?.setImage(followImage.withRenderingMode(.alwaysTemplate), for: UIControlState())
    }
    
    @objc func toggleFavoriteState(){
        if(self.favorited == true){
            unFavorite()
        }
        else{
            favorite()
        }
        refreshButtonImage()
    }
    func favorite() {
        TopicListModel.favorite(self.nodeId!, type: 0)
        self.favorited = true
        V2Success("收藏成功")
    }
    func unFavorite() {
        TopicListModel.favorite(self.nodeId!, type: 1)
        self.favorited = false
        V2Success("取消收藏了~")
    }
}
