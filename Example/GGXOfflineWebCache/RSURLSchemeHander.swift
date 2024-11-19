//
//  RSURLSchemeHander.swift
//  RSReading
//
//  Created by 高广校 on 2023/11/8.
//

import Foundation
import WebKit
import GGXOfflineWebCache
import GGXSwiftExtension

public class RSURLSchemeHander: GXURLSchemeHander {
    
    public static let share = RSURLSchemeHander()
    
    /// loadpkg目录/pkg/
    var webPkgName: String {
        return "pkg"
    }
    
    // 缓存目录
    var webTempName: String {
        return "webTemp"
    }
    
    //离线包开关-控制
    public var enable_cache = false
    
    func requestOfflineDataWith(url: String) -> Data? {
        if let filePath = GXHybridCacheManager.share.loadTempOfflineData(url, extensionFolder: self.webTempName){
//            PTDebugView.addLog("离线策略：\(url)")
            return filePath
        }
        guard self.enable_cache == true else {
            GXHybridCacheManager.share.asyncDownloadfflineWithURL(forURL: url, extensionFolder: webTempName)
//            PTDebugView.addLog("网络策略：\(url)")
            return nil
        }
        if let fileData = GXHybridCacheManager.share.loadOfflineData(url,extensionFolder: self.webPkgName){
//            PTDebugView.addLog("离线策略：\(url)")
            return fileData
        }
        //本地没有此文件，需要下载至缓存目录
//        PTDebugView.addLog("网络策略：\(url)")
        GXHybridCacheManager.share.asyncDownloadfflineWithURL(forURL: url, extensionFolder: webTempName)
        return nil
    }
}

//@available(iOS 11.0, *)
extension RSURLSchemeHander {
    
    public override func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        //1、URL
        guard let url = urlSchemeTask.request.url else {
            return
        }
        
//        PTDebugView.addLog("拦截的URL:\(url.absoluteString)")
        if let data = requestOfflineDataWith(url: url.absoluteString){
            let MIMEType = url.absoluteString.getMIMETypeFromPathExtension()
            if let response = HTTPURLResponse(url: url, statusCode: 200,
                                              httpVersion: "http:1.1", headerFields: ["Content-Type":MIMEType,"Access-Control-Allow-Origin":"*"]) {
                urlSchemeTask.didReceive(response)
                urlSchemeTask.didReceive(data)
                urlSchemeTask.didFinish()
            }
            
        } else {
//            PTDebugView.addLog("网络策略：\(url)")
            super.webView(webView, start: urlSchemeTask)
        }

    }
    
    public override func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        super.webView(webView, stop: urlSchemeTask)
    }
    
}
