//
//  GXTaskDownloadDisk+DownloadingDelegate.swift
//  GXTaskDownload
//
//  Created by 高广校 on 2023/12/7.
//

import Foundation
import GGXSwiftExtension
//import HandyJSON

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
                
                let totalBytesCount = Double(download.totalBytesCount)
                //对比文件的MD5和模型是否一致
                if let boxFileMd5 = boxPath.toFileUrl?.toMD5(),
                   let urlMD5 = diskFile.remoteDownloadURLModel?.md5, urlMD5.length > 0 {
                    let r = boxFileMd5.has(urlMD5,option: .caseInsensitive)
                    if r == true {
                        self.saveUrlInfo()
                        downloadBlock?(download.progress, state)
                    } else {
                        //下载之后的文件和文件URL的md5不一致，说明配置有问题
//                        self.saveUrlInfo()
                        //v2 删除下载失败的文件。
                        LogInfo("下载之后的文件和文件URL的md5不一致:\(urlPath)的MD5:\(urlMD5)\n本地计算为:\(boxFileMd5)\n文件的沙盒路径: \(boxPath)")
                        diskFile.clearFile(forUrl: urlPath)
                        downloadBlock?(download.progress, GXDownloadingState.error)
                    }
                } 
                else {
                    //                    print("文件大小:\(downloadCount)")
                    if totalBytesCount == downloadCount {
                        self.saveUrlInfo()
                        downloadBlock?(download.progress, state)
                    } else {
                        LogInfo("可下载\(totalBytesCount)、已下载：\(downloadCount)、urlPath：\(urlPath), 本地存储路径: \(boxPath)")
                        downloadBlock?(download.progress, GXDownloadingState.error)
                    }
                }
            }
        }
    }
    
    //错误会触发
    public func download(_ download: GXDownloading, completedWithError error: Error?) {
        LogInfo("文件下载错误：urlPath：\(download.url?.absoluteString ?? "")")
        downloadBlock?(download.progress, .error)
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
