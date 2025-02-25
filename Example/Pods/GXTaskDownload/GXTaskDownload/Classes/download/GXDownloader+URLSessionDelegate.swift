//
//  GXDownloader+URLSessionDelegate.swift
//  GXTaskDownload
//
//  Created by 高广校 on 2023/12/5.
//

import Foundation
import os.log
import GGXSwiftExtension

extension GXDownloader: URLSessionDataDelegate {
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        //        os_log("%@ - %d", log: GXDownloader.logger, type: .debug, #function, #line)
        let httpURLResponse = response as? HTTPURLResponse
        //当服务端没有设置`Content-Length`或某些文件获取不到大小，如svg，那么客户端获取时是-1，
        totalBytesCount = httpURLResponse?.expectedContentLength ?? 0
        if totalBytesCount == -1 {
            if let contentLengthString = httpURLResponse?.allHeaderFields["Content-Length"] as? String,
            let contentLengthValue = Int(contentLengthString) {
//                LogInfo("The \(response.url?.absoluteString ?? "nil") Content-Length: \(contentLengthValue)")
                totalBytesCount = Int64(contentLengthValue)
            } else {
                LogInfo("The \(response.url?.absoluteString ?? "nil") Content-Length is nil")
            }
        } else {
//            LogInfo("The \(response.url?.absoluteString ?? "nil") expectedContentLength: \(totalBytesCount)")
        }
        state = .downloading
        completionHandler(.allow)
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        //        os_log("%@ - %d", log: GXDownloader.logger, type: .debug, #function, #line, data.count)
        totalBytesReceived += Int64(data.count)
        progress = Float(totalBytesReceived) / Float(totalBytesCount)
        delegate?.download(self, didReceiveData: data, progress: progress)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        //        os_log("%@ - %d", log: GXDownloader.logger, type: .debug, #function, #line)
        if error == nil {
            state = .completed
        } else {
            //有异常
            //            state = .error
            print("处理完毕异常\(String(describing: error))")
            delegate?.download(self, completedWithError: error)
        }
    }
}
