//
//  RelevantCommentsViewController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 3/3/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import FXBlurView
import Shimmer

class RelevantCommentsNav:V2EXNavigationController , UIViewControllerTransitioningDelegate {
    override init(nibName : String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "", bundle: nil)
    }
    init(comments:[TopicCommentModel]) {
        let viewController = RelevantCommentsViewController()
        viewController.commentsArray = comments
        super.init(rootViewController: viewController)
        self.transitioningDelegate = self
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return RelevantCommentsViewControllerTransionPresent()
    }
}

class RelevantCommentsViewControllerTransionPresent:NSObject,UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! RelevantCommentsNav
        let container = transitionContext.containerView
        container.addSubview(toVC.view)
        toVC.view.alpha = 0
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
            
            toVC.view.alpha = 1
            
            }) { (finished: Bool) -> Void in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}



class RelevantCommentsViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    var commentsArray:[TopicCommentModel] = []
    fileprivate var dismissing = false
    fileprivate var _tableView :UITableView!
    fileprivate var tableView: UITableView {
        get{
            if(_tableView != nil){
                return _tableView!;
            }
            _tableView = UITableView();
            _tableView.separatorStyle = UITableViewCellSeparatorStyle.none;
            if #available(iOS 11.0, *) {
                _tableView.contentInsetAdjustmentBehavior = .never
            }
            _tableView.backgroundColor = UIColor.clear
            _tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0)
            regClass(_tableView, cell: TopicDetailCommentCell.self)
            
            _tableView.delegate = self
            _tableView.dataSource = self
            return _tableView!;
            
        }
    }
    
    var frostedView = FXBlurView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        frostedView.underlyingView = V2Client.sharedInstance.centerNavigation!.view
        frostedView.isDynamic = false
        frostedView.blurRadius = 35
        frostedView.tintColor = UIColor.black
        frostedView.frame = self.view.frame
        self.view.addSubview(frostedView)
        

        let shimmeringView = FBShimmeringView()
        shimmeringView.isShimmering = true
        shimmeringView.shimmeringOpacity = 0.3
        shimmeringView.shimmeringSpeed = 45
        shimmeringView.shimmeringHighlightLength = 0.6
        self.view.addSubview(shimmeringView)
        let label = UILabel(frame: shimmeringView.frame)
        label.text = "下拉关闭查看"
        label.font = UIFont(name: "HelveticaNeue-Light", size: 12)
        if V2EXColor.sharedInstance.style == V2EXColor.V2EXColorStyleDefault {
            label.textColor = UIColor.black
        }
        else{
            label.textColor = UIColor.white
        }
        label.textAlignment = .center
        label.backgroundColor = UIColor.clear
        shimmeringView.contentView = label
        var y:CGFloat = 15
        if UIDevice.current.isIphoneX {
            y = 24
        }
        shimmeringView.frame = CGRect( x: (SCREEN_WIDTH-80) / 2 , y: y, width: 80, height: 44)
        
        self.view.addSubview(self.tableView);
        self.tableView.snp.remakeConstraints{ (make) -> Void in
            make.left.right.equalTo(self.view);
            make.height.equalTo(self.view)
            make.top.equalTo(self.view.snp.bottom)
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.snp.remakeConstraints{ (make) -> Void in
            make.left.right.equalTo(self.view);
            make.height.equalTo(self.view)
            make.top.equalTo(self.view)
        }
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 8, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        (self.navigationController as! V2EXNavigationController).navigationBarAlpha = 0
    }
    override func viewWillDisappear(_ animated: Bool) {
        if !self.dismissing{
            (self.navigationController as! V2EXNavigationController).navigationBarAlpha = 1
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.commentsArray.count;
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let layout = self.commentsArray[indexPath.row].textLayout!
        return layout.textBoundingRect.size.height + 12 + 35 + 12 + 12 + 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getCell(tableView, cell: TopicDetailCommentCell.self, indexPath: indexPath)
        cell.bind(self.commentsArray[indexPath.row])
        return cell
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //下拉关闭
        if scrollView.contentOffset.y <= -100 {
            //让scrollView 不弹跳回来
            scrollView.contentInset = UIEdgeInsetsMake(-1 * scrollView.contentOffset.y, 0, 0, 0)
            scrollView.isScrollEnabled = false
            self.navigationController!.dismiss(animated: true, completion: nil)
            self.dismissing = true
        }
    }
}
