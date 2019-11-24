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
        self.title = NSLocalizedString("Navigation")
        self.view.backgroundColor = V2EXColor.colors.v2_backgroundColor
        
        let layout = V2LeftAlignedCollectionViewFlowLayout();
        layout.sectionInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15);
        self.collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        self.collectionView?.backgroundColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
        self.collectionView!.dataSource = self
        self.collectionView!.delegate = self
        self.view.addSubview(self.collectionView!)
        
        self.collectionView!.register(NodeTableViewCell.self, forCellWithReuseIdentifier: "cell")
        self.collectionView!.register(NodeCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "nodeGroupNameView")
    
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
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let count = self.nodeGroupArray?.count{
            return count
        }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.nodeGroupArray![section].children.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let nodeModel = self.nodeGroupArray![indexPath.section].children[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! NodeTableViewCell;
        cell.textLabel.text = nodeModel.nodeName
        return cell;
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let nodeGroupNameView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "nodeGroupNameView", for: indexPath)
        (nodeGroupNameView as! NodeCollectionReusableView).label.text = self.nodeGroupArray![indexPath.section].groupName
        return nodeGroupNameView
    }
}


//MARK: - UICollectionViewDelegateFlowLayout
extension NodesViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let nodeModel = self.nodeGroupArray![indexPath.section].children[indexPath.row]
        return CGSize(width: nodeModel.width, height: 25);
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat{
        return 15
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 35);
    }
}


//MARK: - UICollectionViewDelegate
extension NodesViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        let nodeModel = self.nodeGroupArray![indexPath.section].children[indexPath.row]
        let controller = NodeTopicListViewController()
        controller.node = nodeModel
        V2Client.sharedInstance.centerNavigation?.pushViewController(controller, animated: true)
    }
}
