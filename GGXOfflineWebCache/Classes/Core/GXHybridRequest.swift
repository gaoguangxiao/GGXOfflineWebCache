//
//  GXHybridRequest.swift
//  GGXOfflineWebCache
//
//  Created by 高广校 on 2024/1/6.
//

import Foundation
import GGXSwiftExtension

public class GXHybridRequest: NSObject {
    
    private var dataTask: URLSessionDataTask?
    private static var session: URLSession?
    
    var cache: URLCache?
    
    public override init() {
        Self.updateSession()
    }
    
    private static func updateSession() {
        if Self.session != nil {
            return
        }
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        Self.session = URLSession(configuration: config)
    }
}

extension GXHybridRequest {
    
    public func sendHyUrl(url: URL, block: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let request = URLRequest(url: url)
//        LogInfo("开始请求")
        dataTask = Self.session?.dataTask(with: request) { data, response, error in
//            LogInfo("结束请求")
            block(data,response,error)
        }
        dataTask?.resume()
    }
    
    func sendHyRequest(request: URLRequest) {
        dataTask = Self.session?.dataTask(with: request) { data, response, error in
            LogInfo("结束请求")
//            guard let urlSchemeTask = urlSchemeTask else { return }
//            if let error = error, error._code != NSURLErrorCancelled {
//                urlSchemeTask.didFailWithError(error)
//            } else {
//                if let response = response {
//                    urlSchemeTask.didReceive(response)
//                }
//                if let data = data {
//                    urlSchemeTask.didReceive(data)
//                }
//                urlSchemeTask.didFinish()
//            }
        }
        dataTask?.resume()
    }
    
    func deleteCache() {
//        URLCache.shared.removeCachedResponse(for: <#T##URLRequest#>)
        
//        移除所有缓存
//        URLCache.shared.removeAllCachedResponses()
    }
}

