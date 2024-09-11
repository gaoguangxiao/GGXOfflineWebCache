//
//  GXCheckTaskSize.swift
//  GXTaskDownload
//
//  Created by 高广校 on 2024/1/9.
//  校验单个URL文件大小
import Foundation
import GGXSwiftExtension

//SVG格式图片通过其获取大小
//let task = URLSession.shared.dataTask(with: urlrequest) { data, response, error in
//    let httpURLResponse = response as? HTTPURLResponse
//    var totalBytesCount = httpURLResponse?.expectedContentLength ?? 0
//    if totalBytesCount == -1 {
//        if let contentLengthString = httpURLResponse?.allHeaderFields["Content-Length"] as? String,
//        let contentLengthValue = Int(contentLengthString) {
//            LogInfo("Content-Length: \(contentLengthValue)")
//            totalBytesCount = Int64(contentLengthValue)
//        } else {
//            LogInfo("The \(response?.url?.absoluteString) Content-Length is nil")
//        }
//        
//    }
//    self.fileTotalBytesCount?(totalBytesCount)
////                print(data,response,error)
//}
//task.resume()

public class GXCheckTaskSize: NSObject {
    
    /// 单个文件校验回调
    var fileTotalBytesCount: GXTaskCheckBlock?

    lazy var downloader: GXDownloader = {
        let downloader = GXDownloader()
        downloader.delegate = self
        return downloader
    }()
    
    public func checkUrlTask(url: URL, complete:@escaping GXTaskCheckBlock){
        //设置回调
        self.fileTotalBytesCount = complete
        var urlrequest = URLRequest(url: url)
        if url.pathExtension == "svg" || url.pathExtension == "js" {
            //SVG格式图片通过其获取大小，"GET"方式很关键
            urlrequest.httpMethod = "GET"
//            downloader.request = urlrequest
//            downloader.url = url
        } else {
            //其他
            urlrequest.httpMethod = "HEAD"
        }
        downloader.request = urlrequest
        downloader.start()
    }
    
    deinit {
        LogInfo("\(self)-deinit")
    }
}

extension GXCheckTaskSize: GXDownloadingDelegate {
    public func download(_ download: GXDownloader, changedState state: GXDownloadingState) {
        if(state == .completed) {
//            LogInfo("totalBytesCount：\(download.totalBytesCount)")
//            LogInfo("totalBytesReceived：\(download.totalBytesReceived)")
            var totalBytes: Int64 = 0
            if download.totalBytesReceived != 0 {
                totalBytes = download.totalBytesReceived
            } else if download.totalBytesCount != 0 {
                totalBytes = download.totalBytesCount
            }
            if totalBytes == 0 {
                LogInfo("totalBytes is zero")
            }
            self.fileTotalBytesCount?(totalBytes)
        }
    }
    public func download(_ download: GXDownloading, completedWithError error: Error?) {
        if error != nil {
            LogInfo("The download \(download) eror is \(String(describing: error))")
            self.fileTotalBytesCount?(0)
        }
    }
    public func download(_ download: GXDownloading, startError error: GXDownloadingError?) {}
    public func download(_ download: GXDownloading, didReceiveData data: Data, progress: Float) {}
    
}
