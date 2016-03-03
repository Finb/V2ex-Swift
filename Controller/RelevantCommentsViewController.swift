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
    override init(nibName : String?, bundle nibBundleOrNil: NSBundle?) {
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
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return RelevantCommentsViewControllerTransionPresent()
    }
}

class RelevantCommentsViewControllerTransionPresent:NSObject,UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3
    }
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! RelevantCommentsNav
        let container = transitionContext.containerView()
        container!.addSubview(toVC.view)
        toVC.view.alpha = 0
        
        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            
            toVC.view.alpha = 1
            
            }) { (finished: Bool) -> Void in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
}



class RelevantCommentsViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    var commentsArray:[TopicCommentModel] = []
    private var dismissing = false
    private var _tableView :UITableView!
    private var tableView: UITableView {
        get{
            if(_tableView != nil){
                return _tableView!;
            }
            _tableView = UITableView();
            _tableView.separatorStyle = UITableViewCellSeparatorStyle.None;
            
            _tableView.backgroundColor = UIColor.clearColor()
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
        frostedView.dynamic = false
        frostedView.blurRadius = 35
        frostedView.tintColor = UIColor.blackColor()
        frostedView.frame = self.view.frame
        self.view.addSubview(frostedView)
        

        let shimmeringView = FBShimmeringView()
        shimmeringView.shimmering = true
        shimmeringView.shimmeringOpacity = 0.3
        shimmeringView.shimmeringSpeed = 45
        shimmeringView.shimmeringHighlightLength = 0.6
        self.view.addSubview(shimmeringView)
        let label = UILabel(frame: shimmeringView.frame)
        label.text = "下拉关闭查看"
        label.font = UIFont(name: "HelveticaNeue-Light", size: 12)
        if V2EXColor.sharedInstance.style == V2EXColor.V2EXColorStyleDefault {
            label.textColor = UIColor.blackColor()
        }
        else{
            label.textColor = UIColor.whiteColor()
        }
        label.textAlignment = .Center
        label.backgroundColor = UIColor.clearColor()
        shimmeringView.contentView = label
        shimmeringView.frame = CGRectMake( (SCREEN_WIDTH-80) / 2 , 15, 80, 44)

        
        self.view.addSubview(self.tableView);
        self.tableView.snp_remakeConstraints{ (make) -> Void in
            make.left.right.equalTo(self.view);
            make.height.equalTo(self.view)
            make.top.equalTo(self.view.snp_bottom)
        }
        
    }
    override func viewDidAppear(animated: Bool) {
        self.tableView.snp_remakeConstraints{ (make) -> Void in
            make.left.right.equalTo(self.view);
            make.height.equalTo(self.view)
            make.top.equalTo(self.view)
        }
        
        UIView.animateWithDuration(0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 8, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        (self.navigationController as! V2EXNavigationController).navigationBarAlpha = 0
    }
    override func viewWillDisappear(animated: Bool) {
        if !self.dismissing{
            (self.navigationController as! V2EXNavigationController).navigationBarAlpha = 1
        }
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.commentsArray.count;
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let layout = self.commentsArray[indexPath.row].textLayout!
        return layout.textBoundingRect.size.height + 12 + 35 + 12 + 12 + 1
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = getCell(tableView, cell: TopicDetailCommentCell.self, indexPath: indexPath)
        cell.bind(self.commentsArray[indexPath.row])
        return cell
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //下拉关闭
        if scrollView.contentOffset.y <= -100 {
            //让scrollView 不弹跳回来
            scrollView.contentInset = UIEdgeInsetsMake(-1 * scrollView.contentOffset.y, 0, 0, 0)
            scrollView.scrollEnabled = false
            self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
            self.dismissing = true
        }
    }
}
