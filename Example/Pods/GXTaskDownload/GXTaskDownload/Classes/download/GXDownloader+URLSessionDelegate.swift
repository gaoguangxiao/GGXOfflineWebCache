//
//  GXDownloader+URLSessionDelegate.swift
//  GXTaskDownload
//
//  Created by 高广校 on 2023/12/5.
//

import Foundation
import os.log

extension GXDownloader: URLSessionDataDelegate {
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        os_log("%@ - %d", log: GXDownloader.logger, type: .debug, #function, #line)
        state = .downloading
        totalBytesCount = response.expectedContentLength
        completionHandler(.allow)
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
//        os_log("%@ - %d", log: GXDownloader.logger, type: .debug, #function, #line, data.count)
        totalBytesReceived += Int64(data.count)
        progress = Float(totalBytesReceived) / Float(totalBytesCount)
        delegate?.download(self, didReceiveData: data, progress: progress)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        os_log("%@ - %d", log: GXDownloader.logger, type: .debug, #function, #line)
        if error == nil {
            state = .completed
        } else {
            //有异常
            print("处理完毕异常\(String(describing: error))")
        }
        
        delegate?.download(self, completedWithError: error)
    }
}
