//
//  PodsTableViewController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2/23/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

struct PodModel {
    var name:String?
    var description:String?
    var URL:String?
}

class PodsTableViewController: UITableViewController {
    //                   name   version url
    fileprivate let pods:[PodModel] = [
        PodModel(name: "SnapKit", description: "A Swift Autolayout DSL for iOS & OS X",URL:"https://github.com/SnapKit/SnapKit"),
        
        PodModel(name: "Alamofire", description: "Elegant HTTP Networking in Swift",URL:"https://github.com/Alamofire/Alamofire"),
        
        PodModel(name: "Moya", description: "Network abstraction layer written in Swift",URL:"https://github.com/Moya/Moya"),
        
        PodModel(name: "RxSwift", description: "Reactive Programming in Swift",URL:"https://github.com/ReactiveX/RxSwift"),

        PodModel(name: "Ji", description: "Ji (戟) is an XML/HTML parser for Swift",URL: "https://github.com/honghaoz/Ji"),
        
        PodModel(name: "KVOController", description: "Simple, modern, thread-safe key-value observing for iOS and OS X.",URL: "https://github.com/facebook/KVOController"),
        
        PodModel(name: "ObjectMapper", description: "Simple JSON Object mapping written in Swift",URL: "https://github.com/Hearst-DD/ObjectMapper"),
        
        PodModel(name: "AlamofireObjectMapper", description: "An Alamofire extension which converts JSON response data into swift objects using ObjectMapper",URL: "https://github.com/tristanhimmelman/AlamofireObjectMapper"),
        
        PodModel(name: "DrawerController", description: "A lightweight, easy to use, Side Drawer Navigation Controller in Swift (based on MMDrawerController)",URL: "https://github.com/sascha/DrawerController"),
        
        PodModel(name: "Kingfisher", description: "A lightweight and pure Swift implemented library for downloading and caching image from the web.",URL: "https://github.com/onevcat/Kingfisher"),
        
        PodModel(name: "YYText", description: "Powerful text framework for iOS to display and edit rich text.",URL: "https://github.com/ibireme/YYText"),
        
        PodModel(name: "FXBlurView", description: "UIView subclass that replicates the iOS 7 realtime background blur effect, but works on iOS 5 and above.",URL: "https://github.com/nicklockwood/FXBlurView"),
        
        PodModel(name: "SVProgressHUD", description: "A clean and lightweight progress HUD for your iOS and tvOS app. ",URL: "https://github.com/SVProgressHUD/SVProgressHUD"),
        
        PodModel(name: "MJRefresh", description: "An easy way to use pull-to-refresh.",URL: "https://github.com/CoderMJLee/MJRefresh"),
        
        PodModel(name: "KeychainSwiftAPI", description: "This Keychain Swift API library is a wrapper of iOS C Keychain Framework.",URL: "https://github.com/deniskr/KeychainSwiftAPI"),
        
        PodModel(name: "INSImageView", description: "A UIImageView that allows for animations between UIViewContentModes.",URL: "https://github.com/instilio/INSImageView"),
        
        PodModel(name: "CXSwipeGestureRecognizer", description: "UIPanGestureRecognizer subclass that takes much of the effort out of recognizing directional swipes.",URL: "https://github.com/dclelland/CXSwipeGestureRecognizer"),
        
        PodModel(name: "Shimmer", description: "An easy way to add a simple, shimmering effect to any view in an iOS app.",URL: "https://github.com/facebook/Shimmer"),
        
        PodModel(name: "OnePasswordExtension", description: "1Password Extension for iOS Apps",URL: "https://github.com/AgileBits/onepassword-app-extension"),
        
        PodModel(name: "FDFullscreenPopGesture", description: "A UINavigationController's category to enable fullscreen pop gesture with iOS7+ system style.",URL: "https://github.com/forkingdog/FDFullscreenPopGesture"),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = V2EXColor.colors.v2_backgroundColor
        self.title = NSLocalizedString("open-SourceLibraries")
        self.tableView.separatorStyle = .none
        regClass(self.tableView, cell: PodCellTableViewCell.self)
    }


    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pods.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.fin_heightForCellWithIdentifier(PodCellTableViewCell.self, indexPath: indexPath) { (cell) -> Void in
            let model = self.pods[indexPath.row]
            cell.titleLabel.text = model.name
            cell.descriptionLabel.text = model.description
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = getCell(tableView, cell: PodCellTableViewCell.self, indexPath: indexPath)
        let model = self.pods[indexPath.row]
        cell.titleLabel.text = model.name
        cell.descriptionLabel.text = model.description
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = self.pods[indexPath.row]
        if let URL = model.URL, let url = Foundation.URL(string:URL ) {
            UIApplication.shared.open(url)
        }
    }
}
