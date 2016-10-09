//
//  UITableView+FINAutomaticHeightCell.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/12/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

extension UITableView {

    public func fin_heightForCellWithIdentifier<T: UITableViewCell>(_ identifier: String, configuration: ((_ cell: T) -> Void)?) -> CGFloat {
        if identifier.characters.count <= 0 {
            return 0
        }
        
        let cell = self.fin_templateCellForReuseIdentifier(identifier)
        cell.prepareForReuse()
        
        if configuration != nil {
            configuration!(cell as! T)
        }
        
//        cell.setNeedsUpdateConstraints();
//        cell.updateConstraintsIfNeeded();
//        self.setNeedsLayout();
//        self.layoutIfNeeded();
        
        var fittingSize = cell.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        if self.separatorStyle != .none {
            fittingSize.height += 1.0 / UIScreen.main.scale
        }
        return fittingSize.height
    }
    
    
    fileprivate func fin_templateCellForReuseIdentifier(_ identifier: String) -> UITableViewCell {
        assert(identifier.characters.count > 0, "Expect a valid identifier - \(identifier)")
        if self.fin_templateCellsByIdentifiers == nil {
            self.fin_templateCellsByIdentifiers = [:]
        }
        var templateCell = self.fin_templateCellsByIdentifiers?[identifier] as? UITableViewCell
        if templateCell == nil {
            templateCell = self.dequeueReusableCell(withIdentifier: identifier)
            assert(templateCell != nil, "Cell must be registered to table view for identifier - \(identifier)")
            templateCell?.contentView.translatesAutoresizingMaskIntoConstraints = false
            self.fin_templateCellsByIdentifiers?[identifier] = templateCell
        }
        
        return templateCell!
    }
    
    public func fin_heightForCellWithIdentifier<T: UITableViewCell>(_ identifier: T.Type, indexPath: IndexPath, configuration: ((_ cell: T) -> Void)?) -> CGFloat {
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
    
    fileprivate struct AssociatedKey {
        static var CellsIdentifier = "me.fin.cellsIdentifier"
        static var HeightsCacheIdentifier = "me.fin.heightsCacheIdentifier"
        static var finHeightCacheAbsendValue = CGFloat(-1);
    }

    fileprivate func fin_hasCachedHeightAtIndexPath(_ indexPath:IndexPath) -> Bool {
        self.fin_buildHeightCachesAtIndexPathsIfNeeded([indexPath]);
        let height = self.fin_indexPathHeightCache![indexPath.section][indexPath.row];
        return height >= 0;
    }
    
    fileprivate func fin_buildHeightCachesAtIndexPathsIfNeeded(_ indexPaths:Array<IndexPath>) -> Void {
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
                    if i >= self.fin_indexPathHeightCache!.count{
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
    
    fileprivate var fin_templateCellsByIdentifiers: [String : AnyObject]? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.CellsIdentifier) as? [String : AnyObject]
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.CellsIdentifier, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    fileprivate var fin_indexPathHeightCache: [ [CGFloat] ]? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.HeightsCacheIdentifier) as? [[CGFloat]]
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.HeightsCacheIdentifier, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func fin_reloadData(){
        self.fin_indexPathHeightCache = [[]];
        self.reloadData();
    }

}
