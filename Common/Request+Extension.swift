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
private struct JiHTMLResponseSerializer: DataResponseSerializerProtocol {
    func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) throws -> Ji {
        if let error = error { throw error }
        if response?.url?.path == "/signin" && request?.url?.path != "/signin" {
            throw DataRequest.newError(.dataSerializationFailed, failureReason: "查看的内容需要登录!")
        }
        guard let data = data else {
            throw AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)
        }
        guard let html = Ji(htmlData: data) else {
            throw DataRequest.newError(.dataSerializationFailed, failureReason: "HTML 解析失败")
        }
        return html
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
    
    @discardableResult
    public func responseJiHtml(queue: DispatchQueue = .main, completionHandler: @escaping (AFDataResponse<Ji>) -> Void) -> Self {
        return response(queue: queue, responseSerializer: JiHTMLResponseSerializer(), completionHandler: completionHandler)
    }
}
