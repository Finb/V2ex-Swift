//
//  UITableView+FINAutomaticHeightCell.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/12/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
extension UITableView {

    public func fin_heightForCellWithIdentifier<T>(identifier: String, configuration: ((cell: T) -> Void)?) -> CGFloat {
        if identifier.characters.count <= 0 {
            return 0
        }
        
        let cell = self.fin_templateCellForReuseIdentifier(identifier)
        cell.prepareForReuse()
        
        if configuration != nil {
            configuration!(cell: cell as! T)
        }
        
//        cell.setNeedsUpdateConstraints();
//        cell.updateConstraintsIfNeeded();
//        self.setNeedsLayout();
//        self.layoutIfNeeded();
        
        var fittingSize = cell.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        if self.separatorStyle != .None {
            fittingSize.height += 1.0 / UIScreen.mainScreen().scale
        }
        return fittingSize.height
    }
    
    
    private func fin_templateCellForReuseIdentifier(identifier: String) -> UITableViewCell {
        assert(identifier.characters.count > 0, "Expect a valid identifier - \(identifier)")
        if self.fin_templateCellsByIdentifiers == nil {
            self.fin_templateCellsByIdentifiers = [:]
        }
        var templateCell = self.fin_templateCellsByIdentifiers?[identifier] as? UITableViewCell
        if templateCell == nil {
            templateCell = self.dequeueReusableCellWithIdentifier(identifier)
            assert(templateCell != nil, "Cell must be registered to table view for identifier - \(identifier)")
            templateCell?.contentView.translatesAutoresizingMaskIntoConstraints = false
            self.fin_templateCellsByIdentifiers?[identifier] = templateCell
        }
        
        return templateCell!
    }
    
    public func fin_heightForCellWithIdentifier<T>(identifier: T.Type, indexPath: NSIndexPath, configuration: ((cell: T) -> Void)?) -> CGFloat {
        let identifierStr = "\(identifier)";
        if identifierStr.characters.count == 0 {
            return 0
        }
        
//         Hit cache
        if self.fin_hasCachedHeightAtIndexPath(indexPath) {
            let height: CGFloat = self.fin_indexPathHeightCache![indexPath.section][indexPath.row]
//            NSLog("hit cache by indexPath:[\(indexPath.section),\(indexPath.row)] -> \(height)");
            return height
        }
        
        let height = self.fin_heightForCellWithIdentifier(identifierStr, configuration: configuration)
        self.fin_indexPathHeightCache![indexPath.section][indexPath.row] = height
//        NSLog("cached by indexPath:[\(indexPath.section),\(indexPath.row)] --> \(height)")
        
        return height
    }
    
    
    private struct AssociatedKey {
        static var CellsIdentifier = "me.fin.cellsIdentifier"
        static var HeightsCacheIdentifier = "me.fin.heightsCacheIdentifier"
        static var finHeightCacheAbsendValue = CGFloat(-1);
    }

    private func fin_hasCachedHeightAtIndexPath(indexPath:NSIndexPath) -> Bool {
        self.fin_buildHeightCachesAtIndexPathsIfNeeded([indexPath]);
        let height = self.fin_indexPathHeightCache![indexPath.section][indexPath.row];
        return height >= 0;
    }
    
    private func fin_buildHeightCachesAtIndexPathsIfNeeded(indexPaths:Array<NSIndexPath>) -> Void {
        if indexPaths.count <= 0 {
            return ;
        }
        
        if self.fin_indexPathHeightCache == nil {
            self.fin_indexPathHeightCache = [];
        }
        
        for indexPath in indexPaths {
            let cacheSectionCount = self.fin_indexPathHeightCache!.count;
            if  indexPath.section >= cacheSectionCount {
                for i in cacheSectionCount...indexPath.section {
                    if i >= self.fin_indexPathHeightCache?.count {
                        self.fin_indexPathHeightCache!.append([])
                    }
                }
            }
            
            let cacheCount = self.fin_indexPathHeightCache![indexPath.section].count;
            if indexPath.row >= cacheCount {
                for i in cacheCount...indexPath.row {
                    if i >= self.fin_indexPathHeightCache![indexPath.section].count {
                        self.fin_indexPathHeightCache![indexPath.section].append(AssociatedKey.finHeightCacheAbsendValue);
                    }
                }
            }
        }
        
    }
    
    private var fin_templateCellsByIdentifiers: [String : AnyObject]? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.CellsIdentifier) as? [String : AnyObject]
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.CellsIdentifier, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    private var fin_indexPathHeightCache: [ [CGFloat] ]? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.HeightsCacheIdentifier) as? [[CGFloat]]
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.HeightsCacheIdentifier, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

}
