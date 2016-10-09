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
            nodeId = favoriteUrl?.substring(with: Range<String.Index>( startIndex!.upperBound ..< endIndex!.lowerBound ))
            if let _ = nodeId , let favoriteUrl = favoriteUrl {
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
    
    fileprivate var _tableView :UITableView!
    fileprivate var tableView: UITableView {
        get{
            if(_tableView != nil){
                return _tableView!;
            }
            _tableView = UITableView();
            _tableView.backgroundColor = V2EXColor.colors.v2_backgroundColor
            _tableView.separatorStyle = UITableViewCellSeparatorStyle.none;
            
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
        if self.tableView.mj_footer.isRefreshing() {
            self.tableView.mj_footer.endRefreshing()
        }
        
        //根据 tab name 获取帖子列表
        TopicListModel.getTopicList(self.node!.nodeId!, page: self.currentPage){
            [weak self](response:V2ValueResponse<([TopicListModel],String?)>) -> Void in
            if response.success {
                if let weakSelf = self {
                    weakSelf.topicList = response.value?.0
                    weakSelf.favoriteUrl = response.value?.1
                    weakSelf.tableView.reloadData()
                }
            }
            self?.tableView.mj_header.endRefreshing()
            
            self?.hideLoadingView()
        }
    }
    
    func getNextPage(){
        
        if let count = self.topicList?.count, count <= 0{
            self.tableView.mj_footer.endRefreshing()
            return;
        }
        
        self.currentPage += 1

        TopicListModel.getTopicList(self.node!.nodeId!, page: self.currentPage){
            [weak self](response:V2ValueResponse<([TopicListModel],String?)>) -> Void in
            if response.success {
                if let weakSelf = self , let value = response.value  {
                    weakSelf.topicList! += value.0
                    weakSelf.tableView.reloadData()
                }
                else{
                    self?.currentPage -= 1
                }
            }
            self?.tableView.mj_footer.endRefreshing()
        }
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
    
    func toggleFavoriteState(){
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
