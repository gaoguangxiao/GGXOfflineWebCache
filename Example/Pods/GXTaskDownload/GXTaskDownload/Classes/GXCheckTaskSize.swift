//
//  GXCheckTaskSize.swift
//  GXTaskDownload
//
//  Created by 高广校 on 2024/1/9.
//  校验单个URL文件大小
import Foundation
import GGXSwiftExtension

public class GXCheckTaskSize: NSObject {
    
    /// 单个文件校验回调
    var fileTotalBytesCount: GXTaskCheckBlock?

    
    public func checkUrlTask(url: URL, complete:@escaping GXTaskCheckBlock){
        LogInfo("次数")
        //设置回调
        self.fileTotalBytesCount = complete
        //
        let downloader = GXDownloader()
        downloader.delegate = self
        //
        var urlrequest = URLRequest(url: url)
        urlrequest.httpMethod = "HEAD"
        downloader.request = urlrequest
        downloader.start()
    }
}

extension GXCheckTaskSize: GXDownloadingDelegate {
    public func download(_ download: GXDownloader, changedState state: GXDownloadingState) {
        if state == .downloading {
            self.fileTotalBytesCount?(download.totalBytesCount)
        }
    }
    public func download(_ download: GXDownloading, completedWithError error: Error?) {}
    public func download(_ download: GXDownloading, startError error: GXDownloadingError?) {}
    public func download(_ download: GXDownloading, didReceiveData data: Data, progress: Float) {}
    
}
