//
//  NodesViewController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2/2/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
class NodesViewController: BaseViewController {
    var nodeGroupArray:[NodeGroupModel]?
    var collectionView:UICollectionView?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "节点导航"
        self.view.backgroundColor = V2EXColor.colors.v2_backgroundColor
        
        let layout = V2LeftAlignedCollectionViewFlowLayout();
        layout.sectionInset = UIEdgeInsetsMake(10, 15, 10, 15);
        self.collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        self.collectionView?.backgroundColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
        self.collectionView!.dataSource = self
        self.collectionView!.delegate = self
        self.view.addSubview(self.collectionView!)
        
        self.collectionView!.registerClass(NodeTableViewCell.self, forCellWithReuseIdentifier: "cell")
        self.collectionView!.registerClass(NodeCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "nodeGroupNameView")
    
        NodeGroupModel.getNodes { (response) -> Void in
            if response.success {
                self.nodeGroupArray = response.value
                self.collectionView?.reloadData()
            }
            self.hideLoadingView()
        }
        self.showLoadingView()
    }
}


//MARK: - UICollectionViewDataSource
extension NodesViewController : UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if let count = self.nodeGroupArray?.count{
            return count
        }
        return 0
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.nodeGroupArray![section].children.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let nodeModel = self.nodeGroupArray![indexPath.section].children[indexPath.row]
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! NodeTableViewCell;
        cell.textLabel.text = nodeModel.nodeName
        return cell;
    }
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let nodeGroupNameView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "nodeGroupNameView", forIndexPath: indexPath)
        (nodeGroupNameView as! NodeCollectionReusableView).label.text = self.nodeGroupArray![indexPath.section].groupName
        return nodeGroupNameView
    }
}


//MARK: - UICollectionViewDelegateFlowLayout
extension NodesViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let nodeModel = self.nodeGroupArray![indexPath.section].children[indexPath.row]
        return CGSizeMake(nodeModel.width, 25);
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 15
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSizeMake(collectionView.bounds.size.width, 35);
    }
}


//MARK: - UICollectionViewDelegate
extension NodesViewController : UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        let nodeModel = self.nodeGroupArray![indexPath.section].children[indexPath.row]
        let controller = NodeTopicListViewController()
        controller.node = nodeModel
        V2Client.sharedInstance.centerNavigation?.pushViewController(controller, animated: true)
    }
}
