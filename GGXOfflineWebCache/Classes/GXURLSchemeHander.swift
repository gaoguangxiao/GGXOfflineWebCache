//
//  GXURLSchemeHander.swift
//  RSReading
//
//  Created by 高广校 on 2023/11/8.
//

import Foundation
import WebKit

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
//        print("ZK拦截请求")
        dataTask = Self.session?.dataTask(with: urlSchemeTask.request) { [weak urlSchemeTask] data, response, error in
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
    
    open func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        
        
    }
}
