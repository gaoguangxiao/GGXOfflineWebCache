//
//  GXTaskDownloadDisk+DownloadingDelegate.swift
//  GXTaskDownload
//
//  Created by 高广校 on 2023/12/7.
//

import Foundation
import GGXSwiftExtension

extension GXTaskDownloadDisk: GXDownloadingDelegate {
    
    public func download(_ download: GXDownloading, startError error: GXDownloadingError?) {
        
    }
    
    public func download(_ download: GXDownloader, changedState state: GXDownloadingState) {
        if state == .completed {
            //判断文件完整性。文件长度比较
            if let urlPath = download.url?.absoluteString {
                let boxPath = diskFile.getFilePath(url: urlPath)
                
                let downloadedSize = FileManager.fileSize(path: boxPath)
                let downloadCount = downloadedSize * 1024 * 1024
                print("文件大小:\(downloadCount)")
                let totalBytesCount = Double(download.totalBytesCount)
                
                if totalBytesCount == downloadCount {
                    downloadBlock?(download.progress, state)
                } else {
                    print("文件有损:\(totalBytesCount)、urlPath：\(urlPath)")
                    downloadBlock?(download.progress, GXDownloadingState.error)
                }
            }
//            downloadBlock?(download.progress, state)
        } else {
            downloadBlock?(download.progress, state)
        }
    }
    
    //错误会触发
    public func download(_ download: GXDownloading, completedWithError error: Error?) {
        downloadBlock?(download.progress, download.state)
    }
    
    public func download(_ download: GXDownloading, didReceiveData data: Data, progress: Float) {
        //处理数据
        if #available(iOS 13.4, *) {
            _ = try? diskFile.fileHandle?.seekToEnd()
            try? diskFile.fileHandle?.write(contentsOf: data)
//            print("\(String(describing: errorValue))")
        } else {
            diskFile.fileHandle?.seekToEndOfFile()
            diskFile.fileHandle?.write(data)
//            Fallback on earlier versions
        }
//        print(data)
        downloadBlock?(progress, download.state)
    }
    
}
