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

    var username:String?
    var model:MemberModel?
    
    var blockButton:UIButton?
    var followButton:UIButton?
    
    var color:CGFloat = 0
    private var headerHeight: CGFloat = 240
    private var navigationAppearanceActive = false
    
    
    let backgroundImageView:UIImageView = {
        let backgroundImageView = UIImageView(image: UIImage(named: "12.jpg"))
        backgroundImageView.contentMode = .scaleToFill
        return backgroundImageView
    }()
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = UIColor.clear
        tableView.estimatedRowHeight = 200
        tableView.separatorStyle = .none
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0.0
        }
        if #available(iOS 26.0, *) {
            // 导航栏背景由 navigationBarAlpha 控制，避免系统顶部滚动边缘效果叠加。
            tableView.topEdgeEffect.isHidden = true
        }
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        regClass(tableView, cell: MemberHeaderCell.self)
        regClass(tableView, cell: MemberTopicCell.self)
        regClass(tableView, cell: MemberReplyCell.self)
        
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    fileprivate weak var _loadView:UIActivityIndicatorView?
    
    var tableViewHeader:[UIView?] = []
    
    private let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 44))
    private let titleClipView = UIView()
    private let titleLabel = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.backgroundImageView.frame = self.view.bounds
        self.backgroundImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(self.backgroundImageView)
        
        let frostedView = FXBlurView()
        frostedView.underlyingView = self.backgroundImageView
        frostedView.isDynamic = false
        frostedView.frame = self.view.bounds
        frostedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        frostedView.tintColor = UIColor.black
        self.view.addSubview(frostedView)
        frostedView.updateAsynchronously(true, completion: nil)

        self.view.addSubview(self.tableView);
        self.tableView.snp.makeConstraints{ (make) -> Void in
            make.top.right.bottom.left.equalTo(self.view);
        }
        
        self.titleClipView.clipsToBounds = true
        self.titleClipView.isUserInteractionEnabled = false
        self.titleLabel.text = self.model?.userName ?? "Hello"
        self.titleLabel.font = v2Font(16)
        self.titleLabel.textAlignment = .center
        self.titleClipView.addSubview(self.titleLabel)
        self.navigationItem.titleView = self.titleView
        
        let aloadView = UIActivityIndicatorView(style: .white)
        self.view.addSubview(aloadView)
        aloadView.startAnimating()
        self._loadView = aloadView
        
        self.refreshData()
        
        self.themeChangedHandler = {[weak self] _ in
            self?.view.backgroundColor = V2EXColor.colors.v2_backgroundColor
            if V2EXColor.sharedInstance.style == V2EXColor.V2EXColorStyleDark {
                self?.color = 100
            }
            else{
                self?.color = 0
            }
            self?.titleLabel.textColor = V2EXColor.colors.v2_TopicListTitleColor
            if self?.navigationAppearanceActive == true {
                self?.changeNavigationBarTintColor()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let bar = self.navigationController?.navigationBar, let container = bar.superview {
            container.insertSubview(self.titleClipView, belowSubview: bar)
        }
        self.navigationAppearanceActive = true
        self.updateNavigationAppearance()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationAppearanceActive = false
        (self.navigationController as? V2EXNavigationController)?.navigationBarAlpha = 1
        self.navigationController?.navigationBar.tintColor = V2EXColor.colors.v2_navigationBarTintColor
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.titleClipView.removeFromSuperview()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let window = self.view.window {
            let safeTop = max(0, self.view.convert(CGPoint(x: 0, y: window.safeAreaInsets.top), from: window).y)
            let newHeight = 220 + safeTop
            if abs(self.headerHeight - newHeight) > 0.5 {
                self.headerHeight = newHeight
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }
        }
        if let bar = self.navigationController?.navigationBar, let loadView = self._loadView {
            let barFrame = bar.convert(bar.bounds, to: self.view)
            let size = loadView.intrinsicContentSize
            loadView.frame = CGRect(x: barFrame.maxX - 15 - size.width,
                                    y: barFrame.midY - size.height / 2,
                                    width: size.width, height: size.height)
        }
        self.updateTitlePosition()
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
        self.titleLabel.text = self.model?.userName ?? "Hello"
        if self.model?.userToken != nil {
            setupBlockAndFollowButtons()
        }
        self.tableView.fin_reloadData()
        self.view.setNeedsLayout()
    }

// MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.updateNavigationAppearance()
    }

    private func updateNavigationAppearance() {
        if self.navigationAppearanceActive {
            (self.navigationController as? V2EXNavigationController)?.navigationBarAlpha = self.tableView.contentOffset.y / 100
            self.changeNavigationBarTintColor()
        }
        self.updateTitlePosition()
    }

    private func updateTitlePosition() {
        guard let bar = self.navigationController?.navigationBar,
              let container = self.titleClipView.superview,
              self.titleView.window != nil, bar.window != nil else { return }
        let barFrame = bar.convert(bar.bounds, to: container)
        let titleFrame = self.titleView.convert(self.titleView.bounds, to: container)
        guard barFrame.height > 0, titleFrame.width > 0 else { return }
        self.titleClipView.frame = barFrame
        let indexPath = IndexPath(row: 0, section: 0)
        let y: CGFloat
        if let cell = self.tableView.cellForRow(at: indexPath) as? MemberHeaderCell,
           cell.window != nil {
            let label = cell.userNameLabel
            let center = label.convert(CGPoint(x: label.bounds.midX, y: label.bounds.midY), to: container)
            y = min(max(center.y - barFrame.height / 2, titleFrame.midY - barFrame.height / 2), barFrame.maxY)
        } else {
            let row = self.tableView.rectForRow(at: indexPath)
            let rowBottom = self.tableView.convert(CGPoint(x: row.midX, y: row.maxY), to: container).y
            y = rowBottom < barFrame.minY ? titleFrame.midY - barFrame.height / 2 : barFrame.maxY
        }
        self.titleLabel.frame = CGRect(x: titleFrame.minX - barFrame.minX, y: y - barFrame.minY,
                                       width: titleFrame.width, height: barFrame.height)
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

        let label = UILabel()
        label.text = [NSLocalizedString("posts"),NSLocalizedString("comments")][section - 1]
        view.addSubview(label)
        label.font = v2Font(15)
        label.snp.makeConstraints{ (make) -> Void in
            make.centerY.equalTo(view)
            make.leading.equalTo(view).offset(12)
        }
        
        weak var weakView = view
        view.themeChangedHandler = {_ in
            weakView?.backgroundColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
            label.textColor = V2EXColor.colors.v2_TopicListUserNameColor
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
        
        let blockItem = UIBarButtonItem(customView: blockButton).hidingGlassBackground()
        let followItem = UIBarButtonItem(customView: followButton).hidingGlassBackground()
        
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
        self.blockButton?.setImage(blockImage.withRenderingMode(.alwaysTemplate), for: .normal)
        self.followButton?.setImage(followImage.withRenderingMode(.alwaysTemplate), for: .normal)
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
