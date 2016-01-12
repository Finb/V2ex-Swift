//
//  HomeViewController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/8/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import SnapKit



class HomeViewController: UIViewController ,UITableViewDataSource,UITableViewDelegate{
    private var _tableView :UITableView!
    private var tableView: UITableView {
        get{
            if(_tableView != nil){
                return _tableView!;
            }
            _tableView = UITableView();
            _tableView.estimatedRowHeight=100;
            _tableView.separatorStyle = UITableViewCellSeparatorStyle.None;
            
            regClass(_tableView, cell: HomeTopicListTableViewCell.self);
            
            _tableView.registerClass(HomeTopicListTableViewCell.self , forCellReuseIdentifier: HomeTopicListTableViewCell.Identifier());
            
            _tableView.delegate = self;
            _tableView.dataSource = self;
            return _tableView!;
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true);
        
//        self.navigationController?.navigationBar .setBackgroundImage(createImageWithColor(UIColor.clearColor()), forBarMetrics: .Default)
//        let darkBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
//        self.navigationController?.navigationBar .insertSubview(darkBlurView, atIndex: 0);
//        darkBlurView.backgroundColor=UIColor(white: 0.4, alpha: 0.8)
//        darkBlurView.snp_makeConstraints{ (make) -> Void in
//            make.top.equalTo(darkBlurView.superview!).offset(-20);
//            make.right.leading.equalTo(darkBlurView.superview!);
//            make.height.equalTo(64);
//        }
//        let vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(forBlurEffect: UIBlurEffect(style: .Dark)))
//        vibrancyView.frame=CGRectMake(0, 0, 375, 64)
//        darkBlurView.contentView .addSubview(vibrancyView)
//        
//        let label = UILabel(frame: CGRectMake(0, 20, 375, 44))
//        label.text = "V2EX"
//        label.font = UIFont(name: "HelveticaNeue-Bold", size: 22)
//        label.textAlignment = .Center
//        label.textColor = UIColor.blackColor()
//        vibrancyView.contentView .addSubview(label);
        
        
        self.view.addSubview(self.tableView);
        self.tableView.snp_makeConstraints{ (make) -> Void in
            make.top.right.bottom.left.right.equalTo(self.view);
        }
        
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 60;
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let f = tableView.fin_heightForCellWithIdentifier(HomeTopicListTableViewCell.Identifier(), indexPath: indexPath) { (cell) -> Void in
        
        }
        NSLog("\(f)");
        return f
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return getCell(tableView, cell: HomeTopicListTableViewCell.self, indexPath: indexPath) ;
    }

}
