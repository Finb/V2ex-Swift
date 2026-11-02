//
//  TopicDetailViewController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/16/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

class TopicDetailViewController: BaseViewController {
    var topicId = "0"
    var currentPage = 1
    
    fileprivate var model: TopicDetailModel?
    fileprivate var commentsArray: [TopicCommentModel] = []
    fileprivate var webViewContentCell: TopicDetailWebViewContentCell?
    
    fileprivate enum Order {
        case asc
        case desc
    }
    
    // 评论排序
    fileprivate var commentSort = Order.asc
    
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.cancelEstimatedHeight()
        tableView.separatorStyle = .none
        
        regClass(tableView, cell: TopicDetailHeaderCell.self)
        regClass(tableView, cell: TopicDetailWebViewContentCell.self)
        regClass(tableView, cell: TopicDetailCommentCell.self)
        regClass(tableView, cell: BaseDetailTableViewCell.self)
        regClass(tableView, cell: TopicDetailToolCell.self)
        
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    // 忽略帖子成功后 ，调用的闭包
    var ignoreTopicHandler: ((String) -> Void)?
    // 点击右上角more按钮后，弹出的 activityView
    // 只在activityView 显示在屏幕上持有它，如果activityView释放了，这里也一起释放。
    fileprivate weak var activityView: V2ActivityViewController?
    
    // MARK: - 页面事件

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("postDetails")
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { make in
            make.top.right.bottom.left.equalTo(self.view)
        }
        
        let rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        rightButton.contentMode = .center
        rightButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -15)
        rightButton.setImage(UIImage(named: "ic_more_horiz_36pt")!.withRenderingMode(.alwaysTemplate), for: .normal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton).hidingGlassBackground()
        rightButton.addTarget(self, action: #selector(TopicDetailViewController.rightClick), for: .touchUpInside)
        
        self.tableView.mj_header = V2RefreshHeader(refreshingBlock: { [weak self] in
            self?.getData()
        })
        self.tableView.mj_footer = V2RefreshFooter(refreshingBlock: { [weak self] in
            self?.getNextPage()
        })
        
        self.themeChangedHandler = { [weak self] _ in
            self?.tableView.backgroundColor = V2EXColor.colors.v2_backgroundColor
            self?.view.backgroundColor = V2EXColor.colors.v2_backgroundColor
            
            self?.tableView.v2_scrollToTop()
            self?.showLoadingView()
            self?.getData()
        }
    }
    
    func getData() {
        // 根据 topicId 获取 帖子信息 、回复。
        TopicDetailModel.getTopicDetailById(self.topicId) {
            (response: V2ValueResponse<(TopicDetailModel?, [TopicCommentModel])>) in
            if response.success {
                if let aModel = response.value!.0 {
                    self.model = aModel
                }
                self.commentSort = .asc
                
                self.commentsArray = response.value!.1
                
                self.currentPage = 1
                
                // 清除将帖子内容cell,因为这是个缓存，如果赋值后，就会cache到这个变量，之后直接读这个变量不重新赋值。
                // 这里刷新了，则可能需要更新帖子内容cell ,实际上只是重新调用了 cell.load(_:)方法
                self.webViewContentCell = nil
                
                self.tableView.reloadData()
            } else {
                V2Error(response.message)
            }
            if self.tableView.mj_header.isRefreshing {
                self.tableView.mj_header.endRefreshing()
            }
            self.tableView.mj_footer.resetNoMoreData()
            self.hideLoadingView()
        }
    }
    
    /**
     点击右上角 more 按钮
     */
    @objc func rightClick() {
        if self.model != nil {
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
    func getNextPage() {
        if self.model == nil {
            self.endRefreshingWithNoDataAtAll()
            return
        }
        if self.commentSort == .asc {
            self.currentPage += 1
        } else {
            self.currentPage -= 1
        }
        
        if self.model == nil
            || self.currentPage > self.model!.commentTotalPages
            || self.currentPage <= 0
        {
            self.endRefreshingWithNoMoreData()
            return
        }
        
        TopicDetailModel.getTopicCommentsById(self.topicId, page: self.currentPage) { response in
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
                } else {
                    if self.currentPage == self.model?.commentTotalPages {
                        self.endRefreshingWithNoMoreData()
                    }
                }
                self.commentsArray += arr
                self.tableView.reloadData()
                self.tableView.mj_footer.endRefreshing()
            } else {
                self.currentPage -= 1
            }
        }
    }
    
    var needsClearOldComments = false
    func toggleSoryType() {
        guard self.model != nil
            && !self.tableView.mj_footer.isRefreshing
            && !self.tableView.mj_header.isRefreshing
        else {
            return
        }
        self.commentSort = self.commentSort == .asc ? .desc : .asc
        if self.commentSort == .asc {
            self.currentPage = 0
        } else {
            self.currentPage = self.model!.commentTotalPages + 1
        }
        self.tableView.mj_footer.resetNoMoreData()
        needsClearOldComments = true
        self.getNextPage()
    }
    
    /**
     禁用上拉加载更多，并显示一个字符串提醒
     */
    func endRefreshingWithStateString(_ string: String) {
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

// MARK: - UITableView DataSource

enum TopicDetailTableViewSection: Int {
    case header = 0, comment, other
}

enum TopicDetailHeaderComponent: Int {
    case title = 0, webViewContent, other
}

extension TopicDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let _section = TopicDetailTableViewSection(rawValue: section)!
        switch _section {
        case .header:
            if self.model != nil {
                return 3
            } else {
                return 0
            }
        case .comment:
            return self.commentsArray.count
        case .other:
            return 0
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
                return UITableView.automaticDimension
            case .webViewContent:
                if let height = self.webViewContentCell?.contentHeight, height > 0 {
                    return self.webViewContentCell!.contentHeight
                } else {
                    return 1
                }
            case .other:
                return 45
            }
        case .comment:
            return UITableView.automaticDimension
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
                // 帖子标题
                let cell = getCell(tableView, cell: TopicDetailHeaderCell.self, indexPath: indexPath)
                if cell.nodeClickHandler == nil {
                    cell.nodeClickHandler = { [weak self] () in
                        self?.nodeClick()
                    }
                }
                cell.bind(self.model!)
                return cell
            case .webViewContent:
                // 帖子内容
                if self.webViewContentCell == nil {
                    self.webViewContentCell = getCell(tableView, cell: TopicDetailWebViewContentCell.self, indexPath: indexPath)
                    self.webViewContentCell?.parentScrollView = self.tableView
                } else {
                    return self.webViewContentCell!
                }
                self.webViewContentCell!.load(self.model!)
                if self.webViewContentCell!.contentHeightChanged == nil {
                    self.webViewContentCell!.contentHeightChanged = { [weak self] (height: CGFloat) in
                        if let weakSelf = self {
                            // 在cell显示在屏幕时更新，否则会崩溃会崩溃会崩溃
                            // 另外刷新清空旧cell,重新创建这个cell ,所以 contentHeightChanged 需要判断cell是否为nil
                            if let cell = weakSelf.webViewContentCell, weakSelf.tableView.visibleCells.contains(cell) {
                                if let height = weakSelf.webViewContentCell?.contentHeight, height > 1.5 * SCREEN_HEIGHT { // 太长了就别动画了。。
                                    UIView.animate(withDuration: 0, animations: { () in
                                        self?.tableView.beginUpdates()
                                        self?.tableView.endUpdates()
                                    })
                                } else {
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
                    cell.sortButtonClick = { [weak self] sender in
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
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            self.selectedRowWithActionSheet(indexPath)
        }
    }
}

// MARK: - actionSheet

extension TopicDetailViewController {
    func selectedRowWithActionSheet(_ indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let row = indexPath.row
        CommentActionSheetView.show(
            actions: [
                ("回复", { [weak self] in self?.replyComment(row as NSNumber) }),
                ("感谢", { [weak self] in self?.thankComment(row as NSNumber) }),
                ("查看对话", { [weak self] in self?.relevantComment(row as NSNumber) })
            ],
            in: self.view.window ?? self.view
        )
    }

    @objc func replyComment(_ row: NSNumber) {
        V2User.sharedInstance.ensureLoginWithHandler {
            let item = self.commentsArray[row as! Int]
            let replyViewController = ReplyingViewController()
            replyViewController.atSomeone = "@" + (item.userName ?? " ")
            replyViewController.topicModel = self.model!
            let nav = V2EXNavigationController(rootViewController: replyViewController)
            self.navigationController?.present(nav, animated: true, completion: nil)
        }
    }

    @objc func thankComment(_ row: NSNumber) {
        guard V2User.sharedInstance.isLogin else {
            V2Inform("请先登录")
            return
        }
        let item = self.commentsArray[row as! Int]
        if item.replyId == nil {
            V2Error("回复replyId为空")
            return
        }
        if self.model?.token == nil {
            V2Error("帖子token为空")
            return
        }
        item.favorites += 1
        self.tableView.reloadRows(at: [IndexPath(row: row as! Int, section: 1)], with: .none)
        V2User.sharedInstance.getOnce { response in
            if response.success, let once = V2User.sharedInstance.once {
                TopicCommentModel.replyThankWithReplyId(item.replyId!, token: once) {
                    [weak item, weak self] response in
                    if response.success {}
                    else {
                        V2Error("感谢失败了")
                        // 失败后 取消增加的数量
                        item?.favorites -= 1
                        self?.tableView.reloadRows(at: [IndexPath(row: row as! Int, section: 1)], with: .none)
                    }
                }
            } else {
                V2Error("获取 once 失败")
            }
        }
    }

    @objc func relevantComment(_ row: NSNumber) {
        let item = self.commentsArray[row as! Int]
        let sourceArr = self.commentSort == .asc ? self.commentsArray : self.commentsArray.reversed()
        let relevantComments = TopicCommentModel.getRelevantCommentsInArray(sourceArr, firstComment: item)
        if relevantComments.count <= 0 {
            return
        }
        let controller = RelevantCommentsNav(comments: relevantComments)
        self.present(controller, animated: true, completion: nil)
    }
}

// MARK: - V2ActivityView

enum V2ActivityViewTopicDetailAction: Int {
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
            "Safari"
        ][indexPath.row], image: UIImage(named: ["ic_block_48pt", "ic_grade_48pt", "ic_favorite_48pt", "ic_share_48pt", "ic_explore_48pt"][indexPath.row])!)
    }

    func V2ActivityView(_ activityView: V2ActivityViewController, heightForFooterInSection section: Int) -> CGFloat {
        return 45
    }

    func V2ActivityView(_ activityView: V2ActivityViewController, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = V2EXColor.colors.v2_ButtonBackgroundColor
        
        let label = UILabel()
        label.font = v2Font(18)
        label.text = NSLocalizedString("reply2")
        label.textAlignment = .center
        label.textColor = UIColor.white
        view.addSubview(label)
        label.snp.makeConstraints { make in
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
            || action == V2ActivityViewTopicDetailAction.share
        else {
            V2Inform("请先登录")
            return
        }
        switch action {
        case .block:
            V2BeginLoading()
            if let topicId = self.model?.topicId {
                TopicDetailModel.ignoreTopicWithTopicId(topicId, completionHandler: { [weak self] response in
                    if response.success {
                        V2Success("忽略成功")
                        self?.navigationController?.popViewController(animated: true)
                        self?.ignoreTopicHandler?(topicId)
                    } else {
                        V2Error("忽略失败")
                    }
                })
            }
        case .favorite:
            V2BeginLoading()
            if let topicId = self.model?.topicId, let token = self.model?.token {
                TopicDetailModel.favoriteTopicWithTopicId(topicId, token: token, completionHandler: { response in
                    if response.success {
                        V2Success("收藏成功")
                    } else {
                        V2Error("收藏失败")
                    }
                })
            }
        case .grade:
            V2BeginLoading()
            
            V2User.sharedInstance.getOnce { response in
                if response.success, let once = V2User.sharedInstance.once {
                    TopicDetailModel.topicThankWithTopicId(self.model?.topicId ?? "", token: once, completionHandler: { response in
                        if response.success {
                            V2Success("成功送了一波铜币")
                        } else {
                            V2Error(response.message)
                        }
                    })
                } else {
                    V2Error("获取 once 失败")
                }
            }
        case .share:
            let shareUrl = NSURL(string: V2EXURL + "t/" + self.model!.topicId!)
            let shareArr: NSArray = [shareUrl!]
            let activityController = UIActivityViewController(activityItems: shareArr as [AnyObject], applicationActivities: nil)
            activityController.excludedActivityTypes = [UIActivity.ActivityType.airDrop]
            self.navigationController?.present(activityController, animated: true, completion: nil)
        case .explore:
            UIApplication.shared.open(URL(string: V2EXURL + "t/" + self.model!.topicId!)!)
        }
    }
    
    @objc func reply() {
        self.activityView?.dismiss()
        V2User.sharedInstance.ensureLoginWithHandler {
            let replyViewController = ReplyingViewController()
            replyViewController.topicModel = self.model!
            let nav = V2EXNavigationController(rootViewController: replyViewController)
            self.navigationController?.present(nav, animated: true, completion: nil)
        }
    }
}

// MARK: - 评论操作菜单

/// 纯 UIView 实现的底部操作菜单。
/// 不使用 modal 呈现，点击操作后同步移除视图再执行回调，
/// 这样后续的 present 不会被 UIAlertController 自身的消失转场排队。
private final class CommentActionSheetView: UIView {
    private let actions: [(title: String, handler: () -> Void)]
    private let dimmingView = UIControl()
    private let panelContainer = UIView()
    private var isDismissing = false

    static func show(actions: [(title: String, handler: () -> Void)], in container: UIView) {
        let sheet = CommentActionSheetView(actions: actions)
        container.addSubview(sheet)
        sheet.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        sheet.layoutIfNeeded()
        sheet.playShowAnimation()
    }

    private init(actions: [(title: String, handler: () -> Void)]) {
        self.actions = actions
        super.init(frame: .zero)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        dimmingView.backgroundColor = UIColor(white: 0, alpha: 0.4)
        dimmingView.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        addSubview(dimmingView)
        dimmingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        addSubview(panelContainer)
        panelContainer.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(min(SCREEN_WIDTH - 16, 400))
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-8)
        }

        var actionViews: [UIView] = []
        for (index, action) in actions.enumerated() {
            if index > 0 {
                actionViews.append(makeSeparator())
            }
            actionViews.append(makeButton(title: action.title, tag: index))
        }

        let actionsPanel = makePanel(views: actionViews)
        panelContainer.addSubview(actionsPanel)
        actionsPanel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        let cancelButton = makeButton(title: "取消", tag: nil)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        let cancelPanel = makePanel(views: [cancelButton])
        panelContainer.addSubview(cancelPanel)
        cancelPanel.snp.makeConstraints { make in
            make.top.equalTo(actionsPanel.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    private func makePanel(views: [UIView]) -> UIView {
        let panel = UIView()
        panel.layer.cornerRadius = 13
        panel.layer.masksToBounds = true

        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        blurView.overrideUserInterfaceStyle = V2EXColor.sharedInstance.style == V2EXColor.V2EXColorStyleDefault ? .light : .dark
        blurView.layer.cornerRadius = 13
        blurView.layer.masksToBounds = true
        panel.addSubview(blurView)
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let stackView = UIStackView(arrangedSubviews: views)
        stackView.axis = .vertical
        panel.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return panel
    }

    private func makeButton(title: String, tag: Int?) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = v2Font(18)
        button.setTitleColor(V2EXColor.colors.v2_TopicListTitleColor, for: .normal)
        if let tag = tag {
            button.tag = tag
            button.addTarget(self, action: #selector(actionTapped(_:)), for: .touchUpInside)
        }
        button.snp.makeConstraints { make in
            make.height.equalTo(52)
        }
        return button
    }

    private func makeSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = V2EXColor.colors.v2_SeparatorColor.withAlphaComponent(0.4)
        separator.snp.makeConstraints { make in
            make.height.equalTo(0.5)
        }
        return separator
    }

    private func playShowAnimation() {
        dimmingView.alpha = 0
        panelContainer.transform = CGAffineTransform(translationX: 0, y: panelContainer.bounds.height + 16)
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 6,
            options: [.allowUserInteraction, .beginFromCurrentState],
            animations: {
                self.dimmingView.alpha = 1
                self.panelContainer.transform = .identity
            },
            completion: nil
        )
    }

    @objc private func cancelTapped() {
        guard !isDismissing else { return }
        isDismissing = true
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 6,
            options: [.beginFromCurrentState],
            animations: {
                self.dimmingView.alpha = 0
                self.panelContainer.transform = CGAffineTransform(translationX: 0, y: self.panelContainer.bounds.height + 16)
            },
            completion: { _ in
                self.removeFromSuperview()
            }
        )
    }

    @objc private func actionTapped(_ sender: UIButton) {
        let handler = actions[sender.tag].handler
        isDismissing = true
        removeFromSuperview()
        handler()
    }
}
