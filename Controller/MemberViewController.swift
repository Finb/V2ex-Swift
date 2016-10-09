//
//  MemberViewController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2/1/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import FXBlurView

class MemberViewController: UIViewController,UITableViewDelegate,UITableViewDataSource ,UIScrollViewDelegate {
    var color:CGFloat = 0
    
    var username:String?
    var blockButton:UIButton?
    var followButton:UIButton?
    var model:MemberModel?
    
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
        
        self.titleView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 64))
        self.navigationItem.titleView = self.titleView!
        
        
        let aloadView = UIActivityIndicatorView(activityIndicatorStyle: .white)
        self.view.addSubview(aloadView)
        aloadView.startAnimating()
        aloadView.snp.makeConstraints{ (make) -> Void in
            make.centerY.equalTo(self.view.snp.top).offset(20+44/2)
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
            let frame = self.titleView!.frame

            let coverView = UIView(frame: CGRect(x: frame.origin.x * -1, y: frame.origin.y * -1 - 20, width: SCREEN_WIDTH, height: 64))
            coverView.clipsToBounds = true
            self.titleView!.addSubview(coverView)
            
            self.titleLabel = UILabel(frame: CGRect(x: 0, y: 64, width: SCREEN_WIDTH, height: 64))
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
        self.titleLabel?.center = CGPoint(x: SCREEN_WIDTH/2, y: 64 - y + 6.5)
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
    
    func toggleFollowState(){
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
    
    func toggleBlockState(){
        if(self.model?.blockState == .blocked){
            UnBlock()
        }
        else{
            Block()
        }
        refreshButtonImage()
    }
    func Block() {
        if let userId = self.model!.userId, let userToken = self.model!.userToken {
        MemberModel.block(userId, userToken: userToken, type: .blocked, completionHandler: nil)
        self.model?.blockState = .blocked
        V2Success("屏蔽成功")
        }
    }
    func UnBlock() {
        if let userId = self.model!.userId, let userToken = self.model!.userToken {
            MemberModel.block(userId, userToken: userToken, type: .unBlocked, completionHandler: nil)
            self.model?.blockState = .unBlocked
            V2Success("取消屏蔽了~")
        }
    }
}

