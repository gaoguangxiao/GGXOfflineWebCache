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
                guard let boxFileMd5 = boxPath.toFileUrl?.toMD5() else {
                    downloadBlock?(download.progress, GXDownloadingState.error)
                    return
                }
                LogInfo("The boxPath \(boxPath) md5 is \(boxFileMd5)")
                let downloadedSize = FileManager.fileSize(path: boxPath)
                let downloadCount = downloadedSize * 1024 * 1024
                let totalBytesCount = Double(download.totalBytesCount)
                //对比文件的MD5和模型是否一致
                if let urlMD5 = diskFile.remoteDownloadURLModel?.md5, !urlMD5.isEmpty {
                    //`boxPath`不携带md5，但模型数据具备
                    let r = boxFileMd5.has(urlMD5,option: .caseInsensitive)
                    if r == true {
                        self.saveUrlInfo()
                        downloadBlock?(download.progress, state)
                    } else {
                        handleMD5Mismatch(urlPath: urlPath, boxFileMd5: boxFileMd5, expectedMD5: urlMD5, boxPath: boxPath)
                    }
                }
                else if boxPath.isDownloadSuccess() { //`boxPath`携带md5的情况
                    LogInfo("The \(urlPath) has md5 check is Success")
                    self.saveUrlInfo()
                    downloadBlock?(download.progress, state)
                }
                else {
                    LogInfo("可下载\(totalBytesCount)、已下载：\(downloadCount)、urlPath：\(urlPath), 本地存储路径: \(boxPath)")
                    if totalBytesCount == downloadCount {
                        self.saveUrlInfo()
                        downloadBlock?(download.progress, state)
                    } else {
                        LogInfo("no save \(urlPath) info and clearFile \(urlPath)")
                        diskFile.clearFile(forUrl: urlPath)
                        downloadBlock?(download.progress, GXDownloadingState.error)
                    }
                }
            }
        }
    }
    
    // 处理 MD5 不一致的情况
    private func handleMD5Mismatch(urlPath: String, boxFileMd5: String, expectedMD5: String, boxPath: String) {
        LogInfo("File MD5 mismatch: \(urlPath)'s expected MD5: \(expectedMD5), local MD5: \(boxFileMd5), Local file path: \(boxPath)")
        diskFile.clearFile(forUrl: urlPath)
        downloadBlock?(0, GXDownloadingState.error) // 进度为 0，因为下载失败
    }
    
    //错误会触发
    public func download(_ download: GXDownloading, completedWithError error: Error?) {
        if let urlPath = download.url?.absoluteString {
            let urlInfoPath = "\(urlPath.md5Value).json"
            LogInfo("文件下载错误：urlPath：\(download.url?.absoluteString ?? "") and clearFile_info \(urlInfoPath)")
            diskFile.clearFile(forUrl: urlInfoPath)
            diskFile.clearFile(forUrl: urlPath)
        }
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
