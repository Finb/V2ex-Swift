//
//  V2LeftAlignedCollectionViewFlowLayout.swift
//  V2ex-Swift
//
//  Created by huangfeng on 16/4/5.
//  Copyright © 2016年 Fin. All rights reserved.
//

import UIKit

class V2LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    var cellSpacing:CGFloat = 15
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributesToReturn = super.layoutAttributesForElements(in: rect);
        guard attributesToReturn != nil else{
            return attributesToReturn;
        }
        
        for attributes in attributesToReturn! {
            if attributes.representedElementKind == nil {
                let indexPath = attributes.indexPath;
                attributes.frame = self.layoutAttributesForItem(at: indexPath).frame;
            }
        }
        return attributesToReturn;
    }
    
    override func layoutAttributesForItem(at indexPath:IndexPath) -> UICollectionViewLayoutAttributes {
        let currentItemAttributes = super.layoutAttributesForItem(at: indexPath)
        
        let sectionInset = self.sectionInset
        
        if indexPath.item == 0 {
            var frame = currentItemAttributes!.frame
            frame.origin.x = sectionInset.left
            currentItemAttributes!.frame = frame
            return currentItemAttributes!;
        }
        
        let previousIndexPath = IndexPath(item: indexPath.item - 1 , section: indexPath.section);
        let previousFrame = self.layoutAttributesForItem(at: previousIndexPath).frame
        let previousFrameRightPoint =  previousFrame.origin.x + previousFrame.size.width + cellSpacing;
        let currentFrame = currentItemAttributes?.frame;
        let strecthedCurrentFrame = CGRect(x: 0,
                                               y: currentFrame!.origin.y,
                                               width: self.collectionView!.frame.size.width,
                                               height: currentFrame!.size.height);
        if !previousFrame.intersects(strecthedCurrentFrame) {
            var frame = currentItemAttributes!.frame;
            frame.origin.x = sectionInset.left; // first item on the line should always be left aligned
            currentItemAttributes!.frame = frame;
            return currentItemAttributes!;
        }
        
        var frame = currentItemAttributes!.frame;
        frame.origin.x = previousFrameRightPoint;
        currentItemAttributes!.frame = frame;
        return currentItemAttributes!;
    }

}
