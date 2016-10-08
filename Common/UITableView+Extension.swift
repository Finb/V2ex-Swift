//
//  UITableView+Extension.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/8/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

extension NSObject {
    /**
     当前的类名字符串
     
     - returns: 当前类名的字符串
     */
    public class func Identifier() -> String {
        return "\(self)";
    }
}

extension String {
    public var Lenght:Int {
        get{
            return self.characters.count;
        }
    }
}


/**
 向tableView 注册 UITableViewCell
 
 - parameter tableView: tableView
 - parameter cell:      要注册的类名
 */
func regClass(_ tableView:UITableView , cell:AnyClass)->Void {
    tableView.register( cell, forCellReuseIdentifier: cell.Identifier());
}
/**
 从tableView缓存中取出对应类型的Cell
 如果缓存中没有，则重新创建一个
 
 - parameter tableView: tableView
 - parameter cell:      要返回的Cell类型
 - parameter indexPath: 位置
 
 - returns: 传入Cell类型的 实例对象
 */
func getCell<T: UITableViewCell>(_ tableView:UITableView ,cell: T.Type ,indexPath:IndexPath) -> T {
    return tableView.dequeueReusableCell(withIdentifier: "\(cell)", for: indexPath) as! T ;
}
