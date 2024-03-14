//
//  WebViewImageProtocol.swift
//  V2ex-Swift
//
//  Created by huangfeng on 16/10/25.
//  Copyright © 2016年 Fin. All rights reserved.
//

import Kingfisher
import UIKit
private let WebviewImageProtocolHandledKey = "WebviewImageProtocolHandledKey"

class WebViewImageProtocol: URLProtocol, URLSessionDataDelegate {
    var session: URLSession?
    var dataTask: URLSessionDataTask?
    var imageData: Data?

    override class func canInit(with request: URLRequest) -> Bool {
        guard let pathExtension = request.url?.pathExtension else {
            return false
        }
        if ["jpg", "jpeg", "png", "gif"].contains(pathExtension.lowercased()) {
            if let tag = self.property(forKey: WebviewImageProtocolHandledKey, in: request) as? Bool, tag == true {
                return false
            }
            return true
        }
        return false
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
        return super.requestIsCacheEquivalent(a, to: b)
    }

    override func startLoading() {
        let resource = KF.ImageResource(downloadURL: self.request.url!)
        let data = try? Data(contentsOf: URL(fileURLWithPath: KingfisherManager.shared.cache.cachePath(forKey: resource.cacheKey)))
        if let data = data {
            // 在磁盘上找到Kingfisher的缓存，则直接使用缓存
            var mimeType = data.contentTypeForImageData()
            mimeType.append(";charset=UTF-8")
            let header = ["Content-Type": mimeType,
                          "Content-Length": String(data.count)]
            let response = HTTPURLResponse(url: self.request.url!, statusCode: 200, httpVersion: "1.1", headerFields: header)!

            self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowed)
            self.client?.urlProtocol(self, didLoad: data)
            self.client?.urlProtocolDidFinishLoading(self)
        }
        else {
            // 没找到图片则下载
            guard let newRequest = (self.request as NSURLRequest).mutableCopy() as? NSMutableURLRequest else { return }
            newRequest.setValue(nil, forHTTPHeaderField: "Referer")
            WebViewImageProtocol.setProperty(true, forKey: WebviewImageProtocolHandledKey, in: newRequest)

            self.session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
            self.dataTask = self.session?.dataTask(with: newRequest as URLRequest)
            self.dataTask?.resume()
        }
    }

    override func stopLoading() {
        self.dataTask?.cancel()
        self.dataTask = nil
        self.imageData = nil
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowed)
        completionHandler(.allow)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.client?.urlProtocol(self, didLoad: data)
        if self.imageData == nil {
            self.imageData = data
        }
        else {
            self.imageData!.append(data)
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            self.client?.urlProtocol(self, didFailWithError: error)
        }
        else {
            self.client?.urlProtocolDidFinishLoading(self)

            let resource = KF.ImageResource(downloadURL: self.request.url!)
            guard let imageData = self.imageData else { return }
            // 保存图片到Kingfisher
            guard let image = DefaultCacheSerializer.default.image(with: imageData, options: KingfisherParsedOptionsInfo(nil)) else { return }
            KingfisherManager.shared.cache.store(image, original: imageData, forKey: resource.cacheKey, toDisk: true, completionHandler: nil)
        }
    }
}

private extension Data {
    func contentTypeForImageData() -> String {
        var c: UInt8 = 0
        self.copyBytes(to: &c, count: MemoryLayout<UInt8>.size * 1)
        switch c {
        case 0xff:
            return "image/jpeg"
        case 0x89:
            return "image/png"
        case 0x47:
            return "image/gif"
        default:
            return ""
        }
    }
}
