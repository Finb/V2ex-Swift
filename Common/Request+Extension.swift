//
//  Request+Extension.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2/2/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import Ji
extension Request {
    public static func JIHTMLResponseSerializer() -> ResponseSerializer<Ji, NSError> {
        return ResponseSerializer { request, response, data, error in
            guard error == nil else { return .Failure(error!) }
            
            guard let validData = data else {
                let failureReason = "Data could not be serialized. Input data was nil."
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            
            if  let jiHtml = Ji(htmlData: validData){
                return .Success(jiHtml)
            }
            
            let failureReason = "HTML 转换失败"
            let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
            return .Failure(error)
        }
    }
    public func responseJiHtml(completionHandler: Response<Ji, NSError> -> Void) -> Self {
        return response(responseSerializer: Request.JIHTMLResponseSerializer(), completionHandler: completionHandler)
    }
}
