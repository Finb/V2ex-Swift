//
//  Request+Extension.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2/2/16.
//  Copyright © 2016 Fin. All rights reserved.
//

//import UIKit
import Foundation
import Alamofire
import Ji
extension Error {
    var localizedFailureReason :String? {
        return (self as NSError).localizedFailureReason
    }
}
extension DataRequest {
    enum ErrorCode: Int {
        case noData = 1
        case dataSerializationFailed = 2
    }
    internal static func newError(_ code: ErrorCode, failureReason: String) -> NSError {
        let errorDomain = "me.fin.v2ex.error"
        let userInfo = [NSLocalizedFailureReasonErrorKey: failureReason]
        let returnError = NSError(domain: errorDomain, code: code.rawValue, userInfo: userInfo)
        return returnError
    }
    
    static func JIHTMLResponseSerializer() -> DataResponseSerializer<Ji> {
        return DataResponseSerializer { request, response, data, error in
            guard error == nil else { return .failure(error!) }
            
            if response?.url?.path == "/signin" && request?.url?.path != "/signin" {
                //跳转到登录页时，则证明请求的内容需要登录
                let failureReason = "查看的内容需要登录!"
                let error = newError(.dataSerializationFailed, failureReason: failureReason)
                return .failure(error)
            }
            guard let validData = data else {
                return .failure(AFError.responseSerializationFailed(reason: .inputDataNil))
            }
            
            if  let jiHtml = Ji(htmlData: validData){
                return .success(jiHtml)
            }
            
            let failureReason = "ObjectMapper failed to serialize response."
            let error = newError(.dataSerializationFailed, failureReason: failureReason)
            return .failure(error)
        }
    }
    
    @discardableResult
    public func responseJiHtml(queue: DispatchQueue? = nil,  completionHandler: @escaping (DataResponse<Ji>) -> Void) -> Self {
        return response(responseSerializer: Alamofire.DataRequest.JIHTMLResponseSerializer(), completionHandler: completionHandler);
    }
}


