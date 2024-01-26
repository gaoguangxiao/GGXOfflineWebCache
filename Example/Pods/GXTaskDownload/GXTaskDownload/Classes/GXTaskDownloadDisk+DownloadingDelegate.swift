//
//  GXTaskDownloadDisk+DownloadingDelegate.swift
//  GXTaskDownload
//
//  Created by 高广校 on 2023/12/7.
//

import Foundation
import GGXSwiftExtension
import HandyJSON

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
                   let urlMD5 = diskFile.downloadURLModel?.md5 {
                    let r = boxFileMd5.has(urlMD5)
                    if r == true {
                        self.saveUrlInfo()
                        downloadBlock?(download.progress, state)
                    } else {
                        //下载之后的文件和文件URL的md5不一致，说明配置有问题
                        self.saveUrlInfo()
                        LogInfo("下载之后的文件和文件URL的md5不一致:\(urlPath)的MD5:\(urlMD5)，计算的为:\(boxFileMd5)")
                        downloadBlock?(download.progress, GXDownloadingState.error)
                    }
                } else {
                    //                    print("文件大小:\(downloadCount)")
                    if totalBytesCount == downloadCount {
                        self.saveUrlInfo()
                        downloadBlock?(download.progress, state)
                    } else {
                        LogInfo("文件有损:\(totalBytesCount)、urlPath：\(urlPath)")
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
