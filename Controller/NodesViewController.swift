//
//  NodesViewController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2/2/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

class testModel {
    var name:String
    var array:[String]
    init () {
        name = "test"
        array = ["发送款到","发送款","发款到","发送款到","发送款款到到","发送款到"]
    }
}

class NodesViewController: UIViewController {

    var testArray:[testModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for i in 1...10 {
            testArray.append(testModel())
        }
    }
    
}
