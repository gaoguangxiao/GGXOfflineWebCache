//
//  GXHybridDownload.swift
//  RSBridgeNetCache
//
//  Created by 高广校 on 2024/1/2.
//  对下载库的封装，向上层离线业务提供下载某目录

import Foundation
import GXTaskDownload
import SSZipArchive

public class GXHybridDownload: NSObject {
    
    ///配置下载路径 /download/
    public var hyDownPath: String = ""
    
    /// 获取全部路径 cache/downloac/
    public var webDownloadPath: String?
    
//    var webOfflinePath: String? {
//        if let _cache = GXTaskDiskFile.share.cachesPath {
//            return _cache + hyDownPath
//        }
//        return hyDownPath
//    }
    
    public func downloadUrl(url: String, unzip: Bool, deleteZip: Bool,block: @escaping GXTaskDownloadBlock) {
        //一个URL对应一个任务
        let taskDownload = GXTaskDownloadDisk()
        taskDownload.diskFile.taskDownloadPath = hyDownPath
        //配置下载路径
        self.webDownloadPath = taskDownload.diskFile.downloadPath
        //开始下载
        taskDownload.start(forURL: url) { progress, state in
            if state == .completed {
                self.unzipFile(url: url,deleteZip: deleteZip)
            }
            block(progress,state)
        }
    }
    
    func unzipFile(url: String, deleteZip: Bool) {
        //获取上级
        let zipPath = self.webDownloadPath ?? ""
        let zipAllPath = zipPath + "/\(url.lastPathComponent)"
        //解压
        SSZipArchive.unzipFile(atPath: zipAllPath,
                               toDestination: zipPath) { str, fileInfo, i, j in
            print("str:\(str)、fileinfo:\(fileInfo),,,i=\(i),,,,j=\(j))")
        } completionHandler: { str, b, error in
            
            let isFileExists = FileManager.isFileExists(atPath: str)
            if isFileExists {
                FileManager.removefile(atPath: str)
            }
            //            print("str:\(str)、b:\(b),,,error=\(error)")
        }
        
    }
    //
}

public extension GXHybridDownload {
    
    /// 下载URL
    /// - Parameters:
    ///   - url: <#url description#>
    ///   - block: <#block description#>
    func download(url: String, block: @escaping GXTaskDownloadBlock) {
        self.download(url: url, path: "", block: block)
    }
    
    /// 下载URL
    /// - Parameters:
    ///   - url: <#url description#>
    ///   - path: <#path description#>
    ///   - block: <#block description#>
    func download(url: String,
                         path: String,
                         block: @escaping GXTaskDownloadBlock) {
        let taskDownload = GXTaskDownloadDisk()
        taskDownload.diskFile.taskDownloadPath = hyDownPath + "/\(path)"
        let isExist = taskDownload.diskFile.checkUrlTask(url: url)
        if isExist == true {
            taskDownload.diskFile.clearFile(forUrl: url)
        }
        //开始下载
        taskDownload.start(forURL: url, block: block)
    }
    
    /// 下载指定的URLS
    /// - Parameters:
    ///   - urls: URL路径
    ///   - block: <#block description#>
    func download(urls: Array<String>,
                         block: @escaping GXTaskDownloadBlock) {
        let taskDownload = GXDownloadManager()
        let downloadToPath = hyDownPath
        taskDownload.start(forURL: urls, path: downloadToPath, block: block)
    }
    
    func download(urls: Array<Dictionary<String,Any>>,
                         block: @escaping GXTaskDownloadBlock) {
        let taskDownload = GXDownloadManager()
        let downloadToPath = hyDownPath
        taskDownload.start(forURL: urls, path: downloadToPath, block: block)
    }
    
    /// 下载指定的URLS
    /// - Parameters:
    ///   - urls: URL路径
    ///   - path: 沙盒本地存储路径
    ///   - block: <#block description#>
    func download(urls: Array<String>,
                         path: String,
                         block: @escaping GXTaskDownloadBlock) {
        let taskDownload = GXDownloadManager()
        let downloadToPath = hyDownPath + "/\(path)"
        taskDownload.start(forURL: urls, path: downloadToPath, block: block)
    }
}
