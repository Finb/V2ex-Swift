//
//  MemberViewController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2/1/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import FXBlurView

class MemberViewController: UIViewController,UITableViewDataSource,UITableViewDelegate ,UIScrollViewDelegate {
    var color:CGFloat = 0
    
    var username:String?
    var blockButton:UIButton?
    var followButton:UIButton?
    var model:MemberModel?
    
    var backgroundImageView:UIImageView?
    private var _tableView :UITableView!
    private var tableView: UITableView {
        get{
            if(_tableView != nil){
                return _tableView!;
            }
            _tableView = UITableView();
            _tableView.backgroundColor = UIColor.clearColor()
            _tableView.estimatedRowHeight=200;
            _tableView.separatorStyle = UITableViewCellSeparatorStyle.None;
            
            regClass(_tableView, cell: MemberHeaderCell.self)
            regClass(_tableView, cell: MemberTopicCell.self)
            regClass(_tableView, cell: MemberReplyCell.self)
            
            _tableView.delegate = self
            _tableView.dataSource = self
            return _tableView!;
            
        }
    }
    
    private weak var _loadView:UIActivityIndicatorView?
    
    var tableViewHeader:[UIView?] = []
    
    var titleView:UIView?
    var titleLabel:UILabel?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = V2EXColor.colors.v2_backgroundColor
        
        self.backgroundImageView = UIImageView(image: UIImage(named: "12.jpg"))
        self.backgroundImageView!.frame = self.view.frame
        self.backgroundImageView!.contentMode = .ScaleToFill
        view.addSubview(self.backgroundImageView!)
        
        let frostedView = FXBlurView()
        frostedView.underlyingView = self.backgroundImageView!
        frostedView.dynamic = false
        frostedView.frame = self.view.frame
        frostedView.tintColor = UIColor.blackColor()
        self.view.addSubview(frostedView)
        

        self.view.addSubview(self.tableView);
        self.tableView.snp_makeConstraints{ (make) -> Void in
            make.top.right.bottom.left.equalTo(self.view);
        }
        
        self.titleView = UIView(frame: CGRectMake(0, 0, SCREEN_WIDTH, 64))
        self.navigationItem.titleView = self.titleView!
        
        
        let aloadView = UIActivityIndicatorView(activityIndicatorStyle: .White)
        self.view.addSubview(aloadView)
        aloadView.startAnimating()
        aloadView.snp_makeConstraints{ (make) -> Void in
            make.centerY.equalTo(self.view.snp_top).offset(20+44/2)
            make.right.equalTo(self.view).offset(-15)
        }
        self._loadView = aloadView
        
        self.refreshData()
        
        if V2EXColor.sharedInstance.style == V2EXColor.V2EXColorStyleDark {
            self.color = 100
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        (self.navigationController as? V2EXNavigationController)?.navigationBarAlpha = 0
        self.changeNavigationBarTintColor()
        (self.navigationController as? V2EXNavigationController)?.navigationBarAlpha = self.tableView.contentOffset.y / 100
    }
    override func viewWillDisappear(animated: Bool) {
        (self.navigationController as? V2EXNavigationController)?.navigationBarAlpha = 1
        self.navigationController?.navigationBar.tintColor = V2EXColor.colors.v2_navigationBarTintColor
    }
    override func viewDidDisappear(animated: Bool) {
        (self.navigationController as? V2EXNavigationController)?.navigationBarAlpha = 1
        self.navigationController?.navigationBar.tintColor = V2EXColor.colors.v2_navigationBarTintColor
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if self.titleLabel == nil {
            let frame = self.titleView!.frame

            let coverView = UIView(frame: CGRectMake(frame.origin.x * -1, frame.origin.y * -1 - 20, SCREEN_WIDTH, 64))
            coverView.clipsToBounds = true
            self.titleView!.addSubview(coverView)
            
            self.titleLabel = UILabel(frame: CGRectMake(0, 64, SCREEN_WIDTH, 64))
            self.titleLabel!.text = self.model != nil ? self.model!.userName! : "Hello"
            self.titleLabel!.font = v2Font(16)
            self.titleLabel!.textAlignment = .Center
            self.titleLabel!.textColor = V2EXColor.colors.v2_TopicListTitleColor
            coverView.addSubview(self.titleLabel!)
        }
        
    }
    
    func refreshData(){
        //根据 topicId 获取 帖子信息 、回复。
        MemberModel.getMemberInfo(self.username!, completionHandler: { (response) -> Void in
            if response.success {
                if let aModel = response.value{
                    self.getDataSuccessfully(aModel)
                }
                else{
                    self.tableView.fin_reloadData()
                }
            }
            if let view = self._loadView{
                view.removeFromSuperview()
            }
        })
    }
    func getDataSuccessfully(aModel:MemberModel){
        self.model = aModel
        self.titleLabel?.text = self.model?.userName
        setupBlockAndFollowButtons()
        self.tableView.fin_reloadData()
    }
    


   
// MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        
        //navigationBar 的透明度
        self.changeNavigationAlpha()
        
        //后退按钮颜色
        self.changeNavigationBarTintColor()
        
        //navigationBar title 显示
        var y:CGFloat = 0
        if offsetY <= 92 {
            y = 0
        }
        else if offsetY >= 122 {
            y = 30
        }
        else {
            y = offsetY - 92
        }
        self.titleLabel?.center = CGPointMake(SCREEN_WIDTH/2, 64 - y + 6.5)
    }
    
    func changeNavigationAlpha(){
        (self.navigationController as? V2EXNavigationController)?.navigationBarAlpha = self.tableView.contentOffset.y/100
    }
    
    func changeNavigationBarTintColor(){
        let offsetY = self.tableView.contentOffset.y
        var y = 100 - offsetY
        if offsetY < 0 {
            y = 100-0
        }
        else if offsetY > 100 {
            y = 100 - 100
        }
        //后退按钮颜色
        self.navigationController?.navigationBar.tintColor = colorWith255RGB(y*2.4+self.color, g: y*2.4+self.color, b: y*2.4+self.color)
    }
}

// MARK: - UITableViewDataSource
extension MemberViewController {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let rows = [1,self.model?.topics.count,self.model?.replies.count][section] {
            return rows
        }
        return 0
    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return [0,40,40][section]
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 240
        }
        else if indexPath.section == 1 {
            return tableView.fin_heightForCellWithIdentifier(MemberTopicCell.self, indexPath: indexPath) { (cell) -> Void in
                cell.bind(self.model!.topics[indexPath.row])
            }
        }
        else {
            return tableView.fin_heightForCellWithIdentifier(MemberReplyCell.self, indexPath: indexPath) { (cell) -> Void in
                cell.bind(self.model!.replies[indexPath.row])
            }
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableViewHeader.count > section - 1 {
            return tableViewHeader[section-1]
        }
        let view = UIView()
        view.backgroundColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
        
        let label = UILabel()
        label.text = ["创建的主题","创建的回复"][section - 1]
        view.addSubview(label)
        label.font = v2Font(15)
        label.textColor = V2EXColor.colors.v2_TopicListUserNameColor
        label.snp_makeConstraints{ (make) -> Void in
            make.centerY.equalTo(view)
            make.leading.equalTo(view).offset(12)
        }
        
        tableViewHeader.append(view)
        return view
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = getCell(tableView, cell: MemberHeaderCell.self, indexPath: indexPath);
            cell.bind(self.model)
            return cell ;
        }
        else if indexPath.section == 1 {
            let cell = getCell(tableView, cell: MemberTopicCell.self, indexPath: indexPath)
            cell.bind(self.model!.topics[indexPath.row])
            return cell
        }
        else {
            let cell = getCell(tableView, cell: MemberReplyCell.self, indexPath: indexPath)
            cell.bind(self.model!.replies[indexPath.row])
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var id:String?
        
        if indexPath.section == 1 {
            id = self.model?.topics[indexPath.row].topicId
        }
        else if indexPath.section == 2 {
            id = self.model?.replies[indexPath.row].topicId
        }
        
        if let id = id {
            let topicDetailController = TopicDetailViewController();
            topicDetailController.topicId = id ;
            self.navigationController?.pushViewController(topicDetailController, animated: true)
            tableView .deselectRowAtIndexPath(indexPath, animated: true);
        }
        
    }
}

//MARK: - Block and Follow
extension MemberViewController{
    func setupBlockAndFollowButtons(){
        if !self.isMemberOfClass(MemberViewController.self){
            return ;
        }
        
        let blockButton = UIButton(frame:CGRectMake(0, 0, 26, 26))
        blockButton.addTarget(self, action: #selector(toggleBlockState), forControlEvents: .TouchUpInside)
        let followButton = UIButton(frame:CGRectMake(0, 0, 26, 26))
        followButton.addTarget(self, action: #selector(toggleFollowState), forControlEvents: .TouchUpInside)
        
        let blockItem = UIBarButtonItem(customView: blockButton)
        let followItem = UIBarButtonItem(customView: followButton)
        
        //处理间距
        let fixedSpaceItem = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        fixedSpaceItem.width = -5
        self.navigationItem.rightBarButtonItems = [fixedSpaceItem,followItem,blockItem]
        
        self.blockButton = blockButton;
        self.followButton = followButton;
        
        refreshButtonImage()
    }
    
    func refreshButtonImage() {
        let blockImage = self.model?.blockState == .Blocked ? UIImage(named: "ic_visibility_off")! : UIImage(named: "ic_visibility")!
        let followImage = self.model?.followState == .Followed ? UIImage(named: "ic_favorite")! : UIImage(named: "ic_favorite_border")!
        self.blockButton?.setImage(blockImage.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        self.followButton?.setImage(followImage.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
    }
    
    func toggleFollowState(){
        if(self.model?.followState == .Followed){
            UnFollow()
        }
        else{
            Follow()
        }
        refreshButtonImage()
    }
    func Follow() {
        MemberModel.follow(self.model!.userId!, userToken: self.model!.userToken!, type: .Followed, completionHandler: nil)
        self.model?.followState = .Followed
        V2Success("关注成功")
    }
    func UnFollow() {
        MemberModel.follow(self.model!.userId!, userToken: self.model!.userToken!, type: .UnFollowed, completionHandler: nil)
        self.model?.followState = .UnFollowed
        V2Success("取消关注了~")
    }
    
    func toggleBlockState(){
        if(self.model?.blockState == .Blocked){
            UnBlock()
        }
        else{
            Block()
        }
        refreshButtonImage()
    }
    func Block() {
        MemberModel.block(self.model!.userId!, userToken: self.model!.userToken!, type: .Blocked, completionHandler: nil)
        self.model?.blockState = .Blocked
        V2Success("屏蔽成功")
    }
    func UnBlock() {
        MemberModel.block(self.model!.userId!, userToken: self.model!.userToken!, type: .UnBlocked, completionHandler: nil)
        self.model?.blockState = .UnBlocked
        V2Success("取消屏蔽了~")
    }
}

