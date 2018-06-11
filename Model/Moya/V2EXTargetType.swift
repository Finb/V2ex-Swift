//
//  V2EXTargetType.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2017/5/24.
//  Copyright © 2017年 Fin. All rights reserved.
//

import UIKit
import Moya

protocol V2EXTargetType: TargetType {

}

extension V2EXTargetType {
    var baseURL: URL {
        return URL(string: "https://www.v2ex.com")!
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        return .request
    }
    
    static var networkActivityPlugin: PluginType {
        return NetworkActivityPlugin(networkActivityClosure: {(change: NetworkActivityChangeType) in
            switch change {
            case .began:
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            case .ended:
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        })
    }
    
    static func endpointClosure<T:TargetType>(_ target: T) -> Endpoint<T>{
        let defaultEndpoint = MoyaProvider<T>.defaultEndpointMapping(for: target)
        
        //API请求 默认携带的参数
        let defaultParameters: [String : Any] = [:]
        return defaultEndpoint.adding(newParameters: defaultParameters)
    }
    
    
    /// 实现此协议的类，将自动获得用该类实例化的 provider 对象
    static var provider: RxMoyaProvider<Self> {
        return RxMoyaProvider<Self>(endpointClosure: endpointClosure , plugins: [networkActivityPlugin])
    }

}
