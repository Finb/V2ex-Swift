//
//  V2ActivityViewController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 3/7/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

@objc protocol V2ActivityViewDataSource {
    /**
     获取有几个 ，当前不考虑复用，最多仅支持4个，之后会考虑复用并可以返回Int.max多个。
     */
    func V2ActivityView(activityView:V2ActivityViewController ,numberOfCellsInSection section: Int) -> Int
    /**
     返回Activity ，主要是标题和图片
     */
    func V2ActivityView(activityView:V2ActivityViewController ,ActivityAtIndexPath indexPath:NSIndexPath) -> V2Activity
    
    /**
     有多少组 ,和UITableView 一样。
     */
    optional func numberOfSectionsInV2ActivityView(activityView:V2ActivityViewController) ->Int

    optional func V2ActivityView(activityView:V2ActivityViewController ,heightForHeaderInSection section: Int) -> CGFloat
    optional func V2ActivityView(activityView:V2ActivityViewController ,heightForFooterInSection section: Int) -> CGFloat
    optional func V2ActivityView(activityView:V2ActivityViewController ,viewForHeaderInSection section: Int) ->UIView?
    optional func V2ActivityView(activityView:V2ActivityViewController ,viewForFooterInSection section: Int) ->UIView?
    
    
    optional func V2ActivityView(activityView: V2ActivityViewController, didSelectRowAtIndexPath indexPath: NSIndexPath)
}

class V2Activity:NSObject {
    var title:String
    var image:UIImage
    init(title aTitle:String , image aImage:UIImage){
        title = aTitle
        image = aImage
    }
}

class V2ActivityButton: UIButton {
    var indexPath:NSIndexPath?
}


/// 一个和UIActivityViewController 一样的弹出框
class V2ActivityViewController: UIViewController ,UIViewControllerTransitioningDelegate {
    weak var dataSource:V2ActivityViewDataSource?
    
    var section:Int{
        get{
            if let _section = dataSource?.numberOfSectionsInV2ActivityView?(self) {
                return _section
            }
            else {
                return 1
            }
        }
    }
    
    var panel:UIToolbar = UIToolbar()
    
    /**
     当前不考虑复用，每一行最多支持4个cell
     */
    func numberOfCellsInSection(section:Int) -> Int{
        if var cells = dataSource?.V2ActivityView(self, numberOfCellsInSection: section) {
            if cells > 4 {
                cells = 4
            }
            return cells
        }
        else{
            return 0
        }
    }
    
    //MARK: - 页面生命周期事件
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(white: 0, alpha: 0)
        self.transitioningDelegate = self
        
        self.panel.barStyle = V2EXColor.sharedInstance.style == V2EXColor.V2EXColorStyleDefault ? .Default : .Black
        self.view.addSubview(self.panel)
        self.panel.snp_makeConstraints{ (make) -> Void in
            make.bottom.equalTo(self.view).offset(-90)
            make.left.equalTo(self.view).offset(10)
            make.right.equalTo(self.view).offset(-10)
        }
        self.panel.layer.cornerRadius = 6
        self.panel.layer.masksToBounds = true
        
        self.setupView()
        
        if let lastView = self.panel.subviews.last {
            self.panel.snp_makeConstraints{ (make) -> Void in
                make.bottom.equalTo(lastView)
            }
        }
        
        let cancelPanel = UIToolbar()
        cancelPanel.barStyle = self.panel.barStyle
        cancelPanel.layer.cornerRadius = self.panel.layer.cornerRadius
        cancelPanel.layer.masksToBounds = true
        self.view.addSubview(cancelPanel)
        cancelPanel.snp_makeConstraints{ (make) -> Void in
            make.top.equalTo(self.panel.snp_bottom).offset(10)
            make.left.right.equalTo(self.panel);
            make.height.equalTo(45)
        }
        
        let cancelButton = UIButton()
        cancelButton.setTitle("取  消", forState: .Normal)
        cancelButton.titleLabel?.font = v2Font(18)
        cancelButton.setTitleColor(V2EXColor.colors.v2_TopicListTitleColor, forState: .Normal)
        cancelPanel.addSubview(cancelButton)
        cancelButton.snp_makeConstraints{ (make) -> Void in
            make.left.top.right.bottom.equalTo(cancelPanel)
        }
        
        cancelButton.addTarget(self, action: #selector(V2ActivityViewController.dismiss), forControlEvents: .TouchUpInside)
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(V2ActivityViewController.dismiss)))
    }
    
    func dismiss(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //#MARK: - 配置视图
    private func setupView(){
        for i in 0..<section {
            
            //setupHeaderView
            //...
            
            
            //setupSectionView
            let sectionView = self.setupSectionView(i)
            self.panel.addSubview(sectionView)
            sectionView.snp_makeConstraints{ (make) -> Void in
                make.left.right.equalTo(self.panel)
                make.height.equalTo(110)
                if self.panel.subviews.count > 1 {
                    make.top.equalTo(self.panel.subviews[self.panel.subviews.count - 1 - 1].snp_bottom)
                }
                else {
                    make.top.equalTo(self.panel)
                }
            }
            
            //setupFoterView
            self.setupFooterView(i)
        }
    }
    //配置每组的cell
    private func setupSectionView(_section:Int) -> UIView {
        let sectionView = UIView()

        let margin = (SCREEN_WIDTH-20 - 60 * 4 )/5.0
        for i in 0..<self.numberOfCellsInSection(_section) {
            let cellView = self.setupCellView(i, currentSection: _section);
            sectionView.addSubview(cellView)
        
            cellView.snp_makeConstraints{ (make) -> Void in
                make.width.equalTo(60)
                make.height.equalTo(80)
                make.centerY.equalTo(sectionView)
                make.left.equalTo(sectionView).offset( CGFloat((i+1)) * margin + CGFloat(i * 60) )
            }
        }
        
        return sectionView
        
    }
    //配置每组的 footerView
    private func setupFooterView(_section:Int) {
        if let view = dataSource?.V2ActivityView?(self, viewForFooterInSection: _section) {
            var height = dataSource?.V2ActivityView?(self, heightForFooterInSection: _section)
            if height == nil {
                height = 40
            }
            
            self.panel.addSubview(view)
            view.snp_makeConstraints{ (make) -> Void in
                make.left.right.equalTo(self.panel)
                make.height.equalTo(height!)
                if self.panel.subviews.count > 1 {
                    make.top.equalTo(self.panel.subviews[self.panel.subviews.count - 1 - 1].snp_bottom)
                }
                else {
                    make.top.equalTo(self.panel)
                }
            }
        }
    }
    //配置每个cell
    private func setupCellView(index:Int , currentSection:Int) -> UIView {
        let cellView = UIView()
        
        let buttonBackgoundView = UIImageView()
        //用颜色生成图片 切成圆角 并拉伸显示
        buttonBackgoundView.image = createImageWithColor(V2EXColor.colors.v2_CellWhiteBackgroundColor, size: CGSizeMake(15, 15)).roundedCornerImageWithCornerRadius(5).stretchableImageWithLeftCapWidth(7, topCapHeight: 7)
        cellView.addSubview(buttonBackgoundView)
        buttonBackgoundView.snp_makeConstraints{ (make) -> Void in
            make.width.height.equalTo(60)
            make.top.left.equalTo(cellView)
        }
        
        let activity = dataSource?.V2ActivityView(self, ActivityAtIndexPath: NSIndexPath(forRow: index, inSection: currentSection))
        
        let button = V2ActivityButton()
        button.setImage(activity?.image.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        cellView.addSubview(button)
        button.tintColor = V2EXColor.colors.v2_TopicListUserNameColor
        button.snp_makeConstraints{ (make) -> Void in
            make.top.right.bottom.left.equalTo(buttonBackgoundView)
        }
        
        button.indexPath = NSIndexPath(forRow: index, inSection: currentSection)
        button.addTarget(self, action: #selector(V2ActivityViewController.cellDidSelected(_:)), forControlEvents: .TouchUpInside)
        
        
        let titleLabel = UILabel()
        titleLabel.textAlignment = .Center
        titleLabel.numberOfLines = 2
        titleLabel.text = activity?.title
        titleLabel.font = v2Font(12)
        titleLabel.textColor = V2EXColor.colors.v2_TopicListTitleColor
        cellView.addSubview(titleLabel)
        titleLabel.snp_makeConstraints{ (make) -> Void in
            make.centerX.equalTo(cellView)
            make.left.equalTo(cellView)
            make.right.equalTo(cellView)
            make.top.equalTo(buttonBackgoundView.snp_bottom).offset(5)
        }
        
        
        return cellView
    }
    
    func cellDidSelected(sender:V2ActivityButton){
        dataSource?.V2ActivityView?(self, didSelectRowAtIndexPath: sender.indexPath!)
    }
    
    //MARK: - 转场动画
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return V2ActivityTransionPresent()
    }
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return V2ActivityTransionDismiss()
    }
}

/// 显示转场动画
class V2ActivityTransionPresent:NSObject,UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.6
    }
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let container = transitionContext.containerView()

        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        fromVC?.view.hidden = true
        let tempView = fromVC?.view.snapshotViewAfterScreenUpdates(false)
        tempView?.tag = 9988
        container?.addSubview(tempView!)
        
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        container!.addSubview(toVC!.view)

        toVC?.view.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT)
        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 7, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
            toVC?.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
            tempView!.transform = CGAffineTransformMakeScale(0.98, 0.98);
            }) { (finished: Bool) -> Void in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
}

/// 隐藏转场动画
class V2ActivityTransionDismiss:NSObject,UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3
    }
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView()
        
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        container!.addSubview(toVC!.view)
        
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        container?.addSubview(fromVC!.view)
        
        let tempView = container?.viewWithTag(9988)
        
        UIView.animateWithDuration(transitionDuration(transitionContext), animations: { () -> Void in
            fromVC?.view.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT)
            tempView!.transform = CGAffineTransformMakeScale(1, 1);
            }) { (finished) -> Void in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
                toVC?.view.hidden = false
        }
    }
}