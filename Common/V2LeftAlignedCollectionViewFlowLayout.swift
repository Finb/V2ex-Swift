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
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributesToReturn = super.layoutAttributesForElementsInRect(rect);
        guard attributesToReturn != nil else{
            return attributesToReturn;
        }
        
        for attributes in attributesToReturn! {
            if attributes.representedElementKind == nil {
                let indexPath = attributes.indexPath;
                attributes.frame = self.layoutAttributesForItemAtIndexPath(indexPath).frame;
            }
        }
        return attributesToReturn;
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath:NSIndexPath) -> UICollectionViewLayoutAttributes {
        let currentItemAttributes = super.layoutAttributesForItemAtIndexPath(indexPath)
        
        let sectionInset = self.sectionInset
        
        if indexPath.item == 0 {
            var frame = currentItemAttributes!.frame
            frame.origin.x = sectionInset.left
            currentItemAttributes!.frame = frame
            return currentItemAttributes!;
        }
        
        let previousIndexPath = NSIndexPath(forItem: indexPath.item - 1 , inSection: indexPath.section);
        let previousFrame = self.layoutAttributesForItemAtIndexPath(previousIndexPath).frame
        let previousFrameRightPoint =  previousFrame.origin.x + previousFrame.size.width + cellSpacing;
        let currentFrame = currentItemAttributes?.frame;
        let strecthedCurrentFrame = CGRectMake(0,
                                               currentFrame!.origin.y,
                                               self.collectionView!.frame.size.width,
                                               currentFrame!.size.height);
        if !CGRectIntersectsRect(previousFrame, strecthedCurrentFrame) {
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
