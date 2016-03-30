//
//  V2ProgressHUD.swift
//  V2ex-Swift
//
//  Created by skyline on 16/3/29.
//  Copyright © 2016年 Fin. All rights reserved.
//

import UIKit
import SVProgressHUD

public class V2ProgressHUD: NSObject {
    public class func show() {
        SVProgressHUD.showWithMaskType(.None)
    }

    public class func showWithClearMask() {
        SVProgressHUD.showWithMaskType(.Clear)
    }

    public class func dismiss() {
        SVProgressHUD.dismiss()
    }

    public class func showWithStatus(status:String!) {
        SVProgressHUD.showWithStatus(status)
    }

    public class func success(status:String!) {
        SVProgressHUD.showSuccessWithStatus(status)
    }

    public class func error(status:String!) {
        SVProgressHUD.showErrorWithStatus(status)
    }

    public class func inform(status:String!) {
        SVProgressHUD.showInfoWithStatus(status)
    }
}

public func V2Success(status:String!) {
    V2ProgressHUD.success(status)
}

public func V2Error(status:String!) {
    V2ProgressHUD.error(status)
}

public func V2Inform(status:String!) {
    V2ProgressHUD.inform(status)
}

public func V2BeginLoading() {
    V2ProgressHUD.show()
}

public func V2BeginLoadingWithStatus(status:String!) {
    V2ProgressHUD.showWithStatus(status)
}

public func V2EndLoading() {
    V2ProgressHUD.dismiss()
}
