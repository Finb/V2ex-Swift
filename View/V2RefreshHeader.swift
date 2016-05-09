//
//  V2RefreshHeader.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/27/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import MJRefresh

class V2RefreshHeader: MJRefreshHeader {
    var loadingView:UIActivityIndicatorView?
    var arrowImage:UIImageView?
    
    override var state:MJRefreshState{
        didSet{
            switch state {
            case .Idle:
                self.loadingView?.hidden = true
                self.arrowImage?.hidden = false
                self.loadingView?.stopAnimating()
            case .Pulling:
                self.loadingView?.hidden = false
                self.arrowImage?.hidden = true
                self.loadingView?.startAnimating()
                
            case .Refreshing:
                self.loadingView?.hidden = false
                self.arrowImage?.hidden = true
                self.loadingView?.startAnimating()
            default:
                NSLog("")
            }
        }
    }
    
    /**
     初始化工作
     */
    override func prepare() {
        super.prepare()
        self.mj_h = 50
        
        self.loadingView = UIActivityIndicatorView(activityIndicatorStyle: .White)
        self.addSubview(self.loadingView!)
        
        self.arrowImage = UIImageView(image: UIImage.imageUsedTemplateMode("ic_arrow_downward"))
        self.addSubview(self.arrowImage!)
        
        self.thmemChangedHandler = {[weak self] (style) -> Void in
            if V2EXColor.sharedInstance.style == V2EXColor.V2EXColorStyleDefault {
                self?.loadingView?.activityIndicatorViewStyle = .Gray
                self?.arrowImage?.tintColor = UIColor.grayColor()
            }
            else{
                self?.loadingView?.activityIndicatorViewStyle = .White
                self?.arrowImage?.tintColor = UIColor.grayColor()
            }
        }
    }
    
    /**
     在这里设置子控件的位置和尺寸
     */
    override func placeSubviews(){
        super.placeSubviews()
        self.loadingView!.center = CGPointMake(self.mj_w/2, self.mj_h/2);
        self.arrowImage!.frame = CGRectMake(0, 0, 24, 24)
        self.arrowImage!.center = self.loadingView!.center
    }
    
    override func scrollViewContentOffsetDidChange(change: [NSObject : AnyObject]!) {
        super.scrollViewContentOffsetDidChange(change)
    }
    
    override func scrollViewContentSizeDidChange(change: [NSObject : AnyObject]!) {
        super.scrollViewContentOffsetDidChange(change)
    }
    
    override func scrollViewPanStateDidChange(change: [NSObject : AnyObject]!) {
        super.scrollViewPanStateDidChange(change)
    }
    
}
