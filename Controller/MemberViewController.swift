//
//  MemberViewController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2/1/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import FXBlurView
import DeviceKit

class MemberViewController: UIViewController,UITableViewDelegate,UITableViewDataSource ,UIScrollViewDelegate {
    var color:CGFloat = 0
    
    var username:String?
    var blockButton:UIButton?
    var followButton:UIButton?
    var model:MemberModel?
    
    
    var headerHeight: CGFloat = {
        let device = Device()
        if device.isOneOf([.iPhoneX, Device.simulator(.iPhoneX)]) {
            return 240 + 24
        }
        return 240
    }()
    
    //昵称相对于整个屏幕时的 y 值
    var nickLabelTop: CGFloat = {
        let device = Device()
        if device.isOneOf([.iPhoneX, Device.simulator(.iPhoneX)]) {
            return 156 + 24/2
        }
        return 156
    }()
    
    
    var backgroundImageView:UIImageView?
    fileprivate var _tableView :UITableView!
    fileprivate var tableView: UITableView {
        get{
            if(_tableView != nil){
                return _tableView!;
            }
            _tableView = UITableView();
            _tableView.backgroundColor = UIColor.clear
            _tableView.estimatedRowHeight=200;
            _tableView.separatorStyle = UITableViewCellSeparatorStyle.none;
            
            if #available(iOS 11.0, *) {
                _tableView.contentInsetAdjustmentBehavior = .never
            }
            regClass(_tableView, cell: MemberHeaderCell.self)
            regClass(_tableView, cell: MemberTopicCell.self)
            regClass(_tableView, cell: MemberReplyCell.self)
            
            _tableView.delegate = self
            _tableView.dataSource = self
            return _tableView!;
            
        }
    }
    
    fileprivate weak var _loadView:UIActivityIndicatorView?
    
    var tableViewHeader:[UIView?] = []
    
    var titleView:UIView?
    var titleLabel:UILabel?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = V2EXColor.colors.v2_backgroundColor
        
        self.backgroundImageView = UIImageView(image: UIImage(named: "12.jpg"))
        self.backgroundImageView!.frame = self.view.frame
        self.backgroundImageView!.contentMode = .scaleToFill
        view.addSubview(self.backgroundImageView!)
        
        let frostedView = FXBlurView()
        frostedView.underlyingView = self.backgroundImageView!
        frostedView.isDynamic = false
        frostedView.frame = self.view.frame
        frostedView.tintColor = UIColor.black
        self.view.addSubview(frostedView)
        

        self.view.addSubview(self.tableView);
        self.tableView.snp.makeConstraints{ (make) -> Void in
            make.top.right.bottom.left.equalTo(self.view);
        }
        
        self.titleView = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 44))
        self.navigationItem.titleView = self.titleView!
        
        
        let aloadView = UIActivityIndicatorView(activityIndicatorStyle: .white)
        self.view.addSubview(aloadView)
        aloadView.startAnimating()
        aloadView.snp.makeConstraints{ (make) -> Void in
            make.centerY.equalTo(self.view.snp.top).offset( (NavigationBarHeight - 44 ) + 44 / 2 )
            make.right.equalTo(self.view).offset(-15)
        }
        self._loadView = aloadView
        
        self.refreshData()
        
        if V2EXColor.sharedInstance.style == V2EXColor.V2EXColorStyleDark {
            self.color = 100
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        (self.navigationController as? V2EXNavigationController)?.navigationBarAlpha = 0
        self.changeNavigationBarTintColor()
        (self.navigationController as? V2EXNavigationController)?.navigationBarAlpha = self.tableView.contentOffset.y / 100
    }
    override func viewWillDisappear(_ animated: Bool) {
        (self.navigationController as? V2EXNavigationController)?.navigationBarAlpha = 1
        self.navigationController?.navigationBar.tintColor = V2EXColor.colors.v2_navigationBarTintColor
    }
    override func viewDidDisappear(_ animated: Bool) {
        (self.navigationController as? V2EXNavigationController)?.navigationBarAlpha = 1
        self.navigationController?.navigationBar.tintColor = V2EXColor.colors.v2_navigationBarTintColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if self.titleLabel == nil {
            var frame = self.titleView!.frame
            frame.origin.x = (frame.size.width - SCREEN_WIDTH)/2
            frame.size.width = SCREEN_WIDTH
            
            let coverView = UIView(frame: frame)
            coverView.clipsToBounds = true
            self.titleView!.addSubview(coverView)
            
            self.titleLabel = UILabel(frame: CGRect(x: 0, y: 44, width: SCREEN_WIDTH, height: 44))
            self.titleLabel!.text = self.model != nil ? self.model!.userName! : "Hello"
            self.titleLabel!.font = v2Font(16)
            self.titleLabel!.textAlignment = .center
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
    func getDataSuccessfully(_ aModel:MemberModel){
        self.model = aModel
        self.titleLabel?.text = self.model?.userName
        if self.model?.userToken != nil {
            setupBlockAndFollowButtons()
        }
        self.tableView.fin_reloadData()
    }
    


   
// MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var offsetY = scrollView.contentOffset.y
        
        //navigationBar 的透明度
        self.changeNavigationAlpha()
        
        //后退按钮颜色
        self.changeNavigationBarTintColor()
        
        //navigationBar title 显示
        let navigationBarHeight = NavigationBarHeight
        
        //昵称距离NavigationBar 底部的距离
        let nickLabelDistanceToNavigationBarBottom = nickLabelTop - navigationBarHeight

        //因为titleLabel的高度是44 ，文字是居中的，而Header里的昵称不是相同高度，所以需要增加一点高度弥补一下 （不要问我怎么得来的，玄学数字
        offsetY += (44-13)/2
        
        var y:CGFloat = 0
        if offsetY <= nickLabelDistanceToNavigationBarBottom {
            y = 44
        }
        else if offsetY >= nickLabelDistanceToNavigationBarBottom + 44 {
            y = 0
        }
        else {
            y = 44 - (offsetY - nickLabelDistanceToNavigationBarBottom)
        }
        
        var frame = self.titleLabel!.frame
        frame.origin.y = y
        self.titleLabel?.frame = frame
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let rows = [1,self.model?.topics.count,self.model?.replies.count][section] {
            return rows
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return [0,40,40][section]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return headerHeight
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableViewHeader.count > section - 1 {
            return tableViewHeader[section-1]
        }
        let view = UIView()
        view.backgroundColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
        
        let label = UILabel()
        label.text = [NSLocalizedString("posts"),NSLocalizedString("comments")][section - 1]
        view.addSubview(label)
        label.font = v2Font(15)
        label.textColor = V2EXColor.colors.v2_TopicListUserNameColor
        label.snp.makeConstraints{ (make) -> Void in
            make.centerY.equalTo(view)
            make.leading.equalTo(view).offset(12)
        }
        
        tableViewHeader.append(view)
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
            tableView .deselectRow(at: indexPath, animated: true);
        }
        
    }

}

//MARK: - Block and Follow
extension MemberViewController{
    func setupBlockAndFollowButtons(){
        if !self.isMember(of: MemberViewController.self){
            return ;
        }
        
        let blockButton = UIButton(frame:CGRect(x: 0, y: 0, width: 26, height: 26))
        blockButton.addTarget(self, action: #selector(toggleBlockState), for: .touchUpInside)
        let followButton = UIButton(frame:CGRect(x: 0, y: 0, width: 26, height: 26))
        followButton.addTarget(self, action: #selector(toggleFollowState), for: .touchUpInside)
        
        let blockItem = UIBarButtonItem(customView: blockButton)
        let followItem = UIBarButtonItem(customView: followButton)
        
        //处理间距
        let fixedSpaceItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpaceItem.width = -5
        self.navigationItem.rightBarButtonItems = [fixedSpaceItem,followItem,blockItem]
        
        self.blockButton = blockButton;
        self.followButton = followButton;
        
        refreshButtonImage()
    }
    
    func refreshButtonImage() {
        let blockImage = self.model?.blockState == .blocked ? UIImage(named: "ic_visibility_off")! : UIImage(named: "ic_visibility")!
        let followImage = self.model?.followState == .followed ? UIImage(named: "ic_favorite")! : UIImage(named: "ic_favorite_border")!
        self.blockButton?.setImage(blockImage.withRenderingMode(.alwaysTemplate), for: UIControlState())
        self.followButton?.setImage(followImage.withRenderingMode(.alwaysTemplate), for: UIControlState())
    }
    
    @objc func toggleFollowState(){
        if(self.model?.followState == .followed){
            UnFollow()
        }
        else{
            Follow()
        }
        refreshButtonImage()
    }
    func Follow() {
        if let userId = self.model!.userId, let userToken = self.model!.userToken {
            MemberModel.follow(userId, userToken: userToken, type: .followed, completionHandler: nil)
            self.model?.followState = .followed
            V2Success("关注成功")
        }
    }
    func UnFollow() {
        if let userId = self.model!.userId, let userToken = self.model!.userToken {
            MemberModel.follow(userId, userToken: userToken, type: .unFollowed, completionHandler: nil)
            self.model?.followState = .unFollowed
            V2Success("取消关注了~")
        }
    }
    
    @objc func toggleBlockState(){
        if(self.model?.blockState == .blocked){
            UnBlock()
        }
        else{
            Block()
        }
        refreshButtonImage()
    }
    func Block() {
        if let userId = self.model!.userId, let userToken = self.model!.blockToken {
        MemberModel.block(userId, userToken: userToken, type: .blocked, completionHandler: nil)
        self.model?.blockState = .blocked
        V2Success("屏蔽成功")
        }
    }
    func UnBlock() {
        if let userId = self.model!.userId, let userToken = self.model!.blockToken {
            MemberModel.block(userId, userToken: userToken, type: .unBlocked, completionHandler: nil)
            self.model?.blockState = .unBlocked
            V2Success("取消屏蔽了~")
        }
    }
}

