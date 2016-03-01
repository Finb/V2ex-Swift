//
//  V2RefreshFooter.swift
//  V2ex-Swift
//
//  Created by huangfeng on 3/1/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import MJRefresh

class V2RefreshFooter: MJRefreshAutoFooter {

    var loadingView:UIActivityIndicatorView?
    var stateLabel:UILabel?
    
    private var _noMoreDataStateString:String?
    var noMoreDataStateString:String? {
        get{
            return self._noMoreDataStateString
        }
        set{
            self._noMoreDataStateString = newValue
            self.stateLabel?.text = newValue
        }
    }
    
    override var state:MJRefreshState{
        didSet{
            switch state {
            case .Idle:
                self.stateLabel?.text = nil
                self.loadingView?.hidden = true
            case .Refreshing:
                self.stateLabel?.text = nil
                self.loadingView?.hidden = false
                self.loadingView?.startAnimating()
            case .NoMoreData:
                self.stateLabel?.text = self.noMoreDataStateString
                self.loadingView?.hidden = true
            default:break
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
        
        self.stateLabel = UILabel(frame: CGRectMake(0, 0, 300, 40))
        self.stateLabel?.textAlignment = .Center
        self.stateLabel!.font = v2Font(12)
        self.stateLabel!.textColor = UIColor(white: 0, alpha: 0.3)
        self.addSubview(self.stateLabel!)
        
        self.KVOController.observe(V2EXColor.sharedInstance, keyPath: "style", options: [.Initial,.New]) {[weak self] (nav, color, change) -> Void in
            if V2EXColor.sharedInstance.style == V2EXColor.V2EXColorStyleDefault {
                self?.loadingView?.activityIndicatorViewStyle = .Gray
            }
            else{
                self?.loadingView?.activityIndicatorViewStyle = .White
            }
        }
        
    }
    
    /**
     在这里设置子控件的位置和尺寸
     */
    override func placeSubviews(){
        super.placeSubviews()
        self.loadingView!.center = CGPointMake(self.mj_w/2, self.mj_h/2);
        self.stateLabel!.center = CGPointMake(self.mj_w/2, self.mj_h/2);
    }

}
