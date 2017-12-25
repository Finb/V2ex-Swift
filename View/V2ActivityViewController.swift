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
    func V2ActivityView(_ activityView:V2ActivityViewController ,numberOfCellsInSection section: Int) -> Int
    /**
     返回Activity ，主要是标题和图片
     */
    func V2ActivityView(_ activityView:V2ActivityViewController ,ActivityAtIndexPath indexPath:IndexPath) -> V2Activity
    
    /**
     有多少组 ,和UITableView 一样。
     */
    @objc optional func numberOfSectionsInV2ActivityView(_ activityView:V2ActivityViewController) ->Int

    @objc optional func V2ActivityView(_ activityView:V2ActivityViewController ,heightForHeaderInSection section: Int) -> CGFloat
    @objc optional func V2ActivityView(_ activityView:V2ActivityViewController ,heightForFooterInSection section: Int) -> CGFloat
    @objc optional func V2ActivityView(_ activityView:V2ActivityViewController ,viewForHeaderInSection section: Int) ->UIView?
    @objc optional func V2ActivityView(_ activityView:V2ActivityViewController ,viewForFooterInSection section: Int) ->UIView?
    
    
    @objc optional func V2ActivityView(_ activityView: V2ActivityViewController, didSelectRowAtIndexPath indexPath: IndexPath)
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
    var indexPath:IndexPath?
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
    
    var panel:UIToolbar = CTToolBar()
    
    /**
     当前不考虑复用，每一行最多支持4个cell
     */
    func numberOfCellsInSection(_ section:Int) -> Int{
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
        
        self.panel.barStyle = V2EXColor.sharedInstance.style == V2EXColor.V2EXColorStyleDefault ? .default : .black
        self.view.addSubview(self.panel)
        self.panel.snp.makeConstraints{ (make) -> Void in
            make.bottom.equalTo(self.view).offset(-90)
            make.left.equalTo(self.view).offset(10)
            make.right.equalTo(self.view).offset(-10)
        }
        self.panel.layer.cornerRadius = 6
        self.panel.layer.masksToBounds = true
        
        self.setupView()
        
        if let lastView = self.panel.subviews.last {
            self.panel.snp.makeConstraints{ (make) -> Void in
                make.bottom.equalTo(lastView)
            }
        }
        
        let cancelPanel = UIToolbar()
        cancelPanel.barStyle = self.panel.barStyle
        cancelPanel.layer.cornerRadius = self.panel.layer.cornerRadius
        cancelPanel.layer.masksToBounds = true
        self.view.addSubview(cancelPanel)
        cancelPanel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(self.panel.snp.bottom).offset(10)
            make.left.right.equalTo(self.panel);
            make.height.equalTo(45)
        }
        
        let cancelButton = UIButton()
        cancelButton.setTitle(NSLocalizedString("cancel2"), for: UIControlState())
        cancelButton.titleLabel?.font = v2Font(18)
        cancelButton.setTitleColor(V2EXColor.colors.v2_TopicListTitleColor, for: UIControlState())
        cancelPanel.addSubview(cancelButton)
        cancelButton.snp.makeConstraints{ (make) -> Void in
            make.left.top.right.bottom.equalTo(cancelPanel)
        }

        cancelButton.addTarget(self, action: #selector(dismiss as () -> Void), for: .touchUpInside)

        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss as () -> Void)))
    }
    
    @objc func dismiss(){
        self.dismiss(animated: true, completion: nil)
    }
    
    //#MARK: - 配置视图
    fileprivate func setupView(){
        for i in 0..<section {
            
            //setupHeaderView
            //...
            
            
            //setupSectionView
            let sectionView = self.setupSectionView(i)
            self.panel.addSubview(sectionView)
            sectionView.snp.makeConstraints{ (make) -> Void in
                make.left.right.equalTo(self.panel)
                make.height.equalTo(110)
                if self.panel.subviews.count > 1 {
                    make.top.equalTo(self.panel.subviews[self.panel.subviews.count - 1 - 1].snp.bottom)
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
    fileprivate func setupSectionView(_ _section:Int) -> UIView {
        let sectionView = UIView()

        let margin = (SCREEN_WIDTH-20 - 60 * 4 )/5.0
        for i in 0..<self.numberOfCellsInSection(_section) {
            let cellView = self.setupCellView(i, currentSection: _section);
            sectionView.addSubview(cellView)
        
            cellView.snp.makeConstraints{ (make) -> Void in
                make.width.equalTo(60)
                make.height.equalTo(80)
                make.centerY.equalTo(sectionView)
                make.left.equalTo(sectionView).offset( CGFloat((i+1)) * margin + CGFloat(i * 60) )
            }
        }
        
        return sectionView
        
    }
    //配置每组的 footerView
    fileprivate func setupFooterView(_ _section:Int) {
        if let view = dataSource?.V2ActivityView?(self, viewForFooterInSection: _section) {
            var height = dataSource?.V2ActivityView?(self, heightForFooterInSection: _section)
            if height == nil {
                height = 40
            }
            
            self.panel.addSubview(view)
            view.snp.makeConstraints{ (make) -> Void in
                make.left.right.equalTo(self.panel)
                make.height.equalTo(height!)
                if self.panel.subviews.count > 1 {
                    make.top.equalTo(self.panel.subviews[self.panel.subviews.count - 1 - 1].snp.bottom)
                }
                else {
                    make.top.equalTo(self.panel)
                }
            }
        }
    }
    //配置每个cell
    fileprivate func setupCellView(_ index:Int , currentSection:Int) -> UIView {
        let cellView = UIView()
        
        let buttonBackgoundView = UIImageView()
        //用颜色生成图片 切成圆角 并拉伸显示
        buttonBackgoundView.image = createImageWithColor(V2EXColor.colors.v2_CellWhiteBackgroundColor, size: CGSize(width: 15, height: 15)).roundedCornerImageWithCornerRadius(5).stretchableImage(withLeftCapWidth: 7, topCapHeight: 7)
        cellView.addSubview(buttonBackgoundView)
        buttonBackgoundView.snp.makeConstraints{ (make) -> Void in
            make.width.height.equalTo(60)
            make.top.left.equalTo(cellView)
        }
        
        let activity = dataSource?.V2ActivityView(self, ActivityAtIndexPath: IndexPath(row: index, section: currentSection))
        
        let button = V2ActivityButton()
        button.setImage(activity?.image.withRenderingMode(.alwaysTemplate), for: UIControlState())
        cellView.addSubview(button)
        button.tintColor = V2EXColor.colors.v2_TopicListUserNameColor
        button.snp.makeConstraints{ (make) -> Void in
            make.top.right.bottom.left.equalTo(buttonBackgoundView)
        }
        
        button.indexPath = IndexPath(row: index, section: currentSection)
        button.addTarget(self, action: #selector(V2ActivityViewController.cellDidSelected(_:)), for: .touchUpInside)
        
        
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.text = activity?.title
        titleLabel.font = v2Font(12)
        titleLabel.textColor = V2EXColor.colors.v2_TopicListTitleColor
        cellView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints{ (make) -> Void in
            make.centerX.equalTo(cellView)
            make.left.equalTo(cellView)
            make.right.equalTo(cellView)
            make.top.equalTo(buttonBackgoundView.snp.bottom).offset(5)
        }
        
        
        return cellView
    }
    
    @objc func cellDidSelected(_ sender:V2ActivityButton){
        dataSource?.V2ActivityView?(self, didSelectRowAtIndexPath: sender.indexPath!)
    }
    
    //MARK: - 转场动画
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return V2ActivityTransionPresent()
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return V2ActivityTransionDismiss()
    }
}

/// 显示转场动画
class V2ActivityTransionPresent:NSObject,UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let container = transitionContext.containerView

        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        fromVC?.view.isHidden = true
        let screenshotImage = fromVC?.view.screenshot()
        let tempView = UIImageView(image: screenshotImage)
        tempView.tag = 9988
        container.addSubview(tempView)
        
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        container.addSubview(toVC!.view)

        toVC?.view.frame = CGRect(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 7, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
            toVC?.view.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
            tempView.transform = CGAffineTransform(scaleX: 0.98, y: 0.98);
            }) { (finished: Bool) -> Void in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

/// 隐藏转场动画
class V2ActivityTransionDismiss:NSObject,UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        container.addSubview(toVC!.view)
        
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        container.addSubview(fromVC!.view)
        
        let tempView = container.viewWithTag(9988)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: { () -> Void in
            fromVC?.view.frame = CGRect(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
            tempView!.transform = CGAffineTransform(scaleX: 1, y: 1);
            }, completion: { (finished) -> Void in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                toVC?.view.isHidden = false
        })
    }
}

class CTToolBar: UIToolbar {
    override func layoutSubviews() {
        super.layoutSubviews()
        //Fix iOS11 种 UIToolBar的子View 都不响应点击事件
        for view in self.subviews {
            print("\(NSStringFromClass(view.classForCoder))")
            if NSStringFromClass(view.classForCoder) == "_UIToolbarContentView" {
                view.isUserInteractionEnabled = false
            }
        }
    }
}
