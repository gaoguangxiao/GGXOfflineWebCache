//
//  GXURLSchemeHander.swift
//  RSReading
//
//  Created by 高广校 on 2023/11/8.
//

import Foundation
import WebKit
import GGXSwiftExtension

enum GXOfflineError: Error {
    case invalidServerResponse
}


open class GXURLSchemeHander: NSObject {
    private var dataTask: URLSessionDataTask?
    private static var session: URLSession?
    
    public override init() {
        Self.updateSession()
    }
    
    private static func updateSession() {
        if Self.session != nil {
            return
        }
        let config = URLSessionConfiguration.default
        Self.session = URLSession(configuration: config)
    }
}

@available(iOS 11.0, *)
extension GXURLSchemeHander: WKURLSchemeHandler{
    open func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        if #available(iOS 15.0, *) {
            Task {
                do {
                    let (data,response) = try await URLSession.shared.data(for: urlSchemeTask.request)
//                   代码后期需要异步方法的结果才使用async let
//                   代码后续行需要异步执行结果,需要用wait
//                    async let (data,response) = URLSession.shared.data(for: urlSchemeTask.request)
                    urlSchemeTask.didReceive(response)
                    urlSchemeTask.didReceive(data)
                    urlSchemeTask.didFinish()
                } catch let e {
                    urlSchemeTask.didFailWithError(e)
                }
            }
        } else {
            // Fallback on earlier versions
            dataTask = Self.session?.dataTask(with: urlSchemeTask.request) { [weak urlSchemeTask] data, response, error in
                //            LogInfo("结束请求")
                guard let urlSchemeTask = urlSchemeTask else { return }
                if let error = error, error._code != NSURLErrorCancelled {
                    urlSchemeTask.didFailWithError(error)
                } else {
                    if let response = response {
                        urlSchemeTask.didReceive(response)
                    }
                    if let data = data {
                        urlSchemeTask.didReceive(data)
                    }
                    urlSchemeTask.didFinish()
                }
            }
            dataTask?.resume()
        }
    }
    
    open func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        
        
    }
}
