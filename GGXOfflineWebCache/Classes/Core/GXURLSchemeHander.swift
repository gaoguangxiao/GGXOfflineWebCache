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
    //This task has already been stopped处理
    private var holdUrlSchemeTasks: Dictionary<String, Bool> = [:]
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
    
    func transformUrlSchemeTasks(urlSchemeTask: WKURLSchemeTask) -> String {
        return urlSchemeTask.request.url?.absoluteString.md5Value ?? ""
    }
    
    func isExistUrlSchemeTasks(urlSchemeTask: WKURLSchemeTask) -> Bool {
        return holdUrlSchemeTasks[transformUrlSchemeTasks(urlSchemeTask: urlSchemeTask)] ?? false
    }
    
    func addUrlSchemeTasks(urlSchemeTask: WKURLSchemeTask) {
        if !isExistUrlSchemeTasks(urlSchemeTask: urlSchemeTask) {
            holdUrlSchemeTasks[transformUrlSchemeTasks(urlSchemeTask: urlSchemeTask)] = true
        }
    }
    
    func removeUrlSchemeTasks(urlSchemeTask: WKURLSchemeTask) {
        if isExistUrlSchemeTasks(urlSchemeTask: urlSchemeTask) {
            holdUrlSchemeTasks.removeValue(forKey: transformUrlSchemeTasks(urlSchemeTask: urlSchemeTask))
        }
    }
}

@available(iOS 11.0, *)
extension GXURLSchemeHander: WKURLSchemeHandler{
    open func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        dataTask = Self.session?.dataTask(with: urlSchemeTask.request) { data, response, error in
            if let error = error, error._code != NSURLErrorCancelled {
                LogInfo("webView(start urlSchemeTask:) - NSURLErrorCancelled")
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
        //2、标记网络处理任务
        //self.addUrlSchemeTasks(urlSchemeTask: urlSchemeTask)
    }
    
    open func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        //3、处理标记的网络任务
        //        self.removeUrlSchemeTasks(urlSchemeTask: urlSchemeTask)
    }
}
