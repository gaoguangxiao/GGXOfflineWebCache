//
//  GXHybridDownload.swift
//  RSBridgeNetCache
//
//  Created by 高广校 on 2024/1/2.
//  对下载库的封装，向上层离线业务提供下载某目录

import Foundation
import GXTaskDownload
import SSZipArchive
import GGXSwiftExtension

public class GXHybridDownload: NSObject {
    
    ///配置下载路径 /download/
    public var hyDownPath: String = ""
    
    /// 获取全部路径 cache/downloac/
    public var webDownloadPath: String?
    
    /// 增加全局下载管理
    let taskDownload = GXDownloadManager()
    
    /// 单文件下载
    let oneTaskDownload = GXTaskDownloadDisk()
    
    //    public func downloadUrl(url: String, unzip: Bool, deleteZip: Bool,block: @escaping GXTaskDownloadBlock) {
    //        //一个URL对应一个任务
    //        let taskDownload = GXTaskDownloadDisk()
    //        taskDownload.diskFile.taskDownloadPath = hyDownPath
    //        //配置下载路径
    //        self.webDownloadPath = taskDownload.diskFile.downloadPath
    //        //开始下载
    //        taskDownload.start(forURL: url) { progress, state in
    //            if state == .completed {
    //                self.unzipFile(url: url,deleteZip: deleteZip)
    //            }
    //            block(progress,state)
    //        }
    //    }
    
    //    func unzipFile(url: String, deleteZip: Bool) {
    //        //获取上级
    //        let zipPath = self.webDownloadPath ?? ""
    //        let zipAllPath = zipPath + "/\(url.lastPathComponent)"
    //        //解压
    //        SSZipArchive.unzipFile(atPath: zipAllPath,
    //                               toDestination: zipPath) { str, fileInfo, i, j in
    //            print("str:\(str)、fileinfo:\(fileInfo),,,i=\(i),,,,j=\(j))")
    //        } completionHandler: { str, b, error in
    //
    //            let isFileExists = FileManager.isFileExists(atPath: str)
    //            if isFileExists {
    //                FileManager.removefile(atPath: str)
    //            }
    //            //            print("str:\(str)、b:\(b),,,error=\(error)")
    //        }
    //
    //    }
    
    deinit {
        LogInfo("\(self)-deinit")
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
                  priority: Int = 3,
                  block: @escaping GXTaskDownloadBlock) {
        oneTaskDownload.diskFile.taskDownloadPath = hyDownPath + "/\(path)"
        oneTaskDownload.taskPriority = priority
        let isExist = oneTaskDownload.diskFile.checkUrlTask(url: url)
        if isExist == true {
            oneTaskDownload.diskFile.clearFile(forUrl: url)
        }
        //开始下载
        oneTaskDownload.start(forURL: url, block: block)
    }
    
    /// 下载URL
    /// - Parameters:
    ///   - url: url description
    ///   - path: <#path description#>
    ///   - block: <#block description#>
    func download(urls: Array<String>,
                  path: String,
                  priority: Int,
                  block: @escaping GXTaskDownloadTotalBlock) {
        let ownloadToPath = hyDownPath + "/\(path)"
        var downloadUrls: Array<GXDownloadURLModel> = []
        for url in urls {
            let downloadModel = GXDownloadURLModel()
            downloadModel.src    = url
            downloadModel.priority = priority
            downloadUrls.append(downloadModel)
        }
        taskDownload.startByURL(forURL: downloadUrls, path: ownloadToPath, block: block)
    }
    
    /// 下载指定的URLS
    /// - Parameters:
    ///   - urls: <#urls description#>
    ///   - path: <#path description#>
    ///   - block: <#block description#>
    func download(urls: Array<GXWebOfflineAssetsModel>,
                  path: String?,
                  maxDownloadCount: Int = 9,
                  priority: Int = 3,
                  block: @escaping GXTaskDownloadTotalBlock) {
        var downloadToPath = hyDownPath
        if let path {
            downloadToPath = hyDownPath + "/\(path)"
        }
        var downloadUrls: Array<GXDownloadURLModel> = []
        for url in urls {
            let downloadModel = GXDownloadURLModel()
            downloadModel.src    = url.src
            downloadModel.policy = url.policy
            downloadModel.md5    = url.md5
            downloadModel.match  = url.match
            downloadModel.priority = priority
            downloadUrls.append(downloadModel)
        }
        taskDownload.start(forURL: downloadUrls,maxDownloadCount: maxDownloadCount, path: downloadToPath, block: block)
    }
    
    /// 下载URL-
    /// - Parameters:
    ///   - url: url description
    ///   - path: <#path description#>
    ///   - block: <#block description#>
    func downloadAndUpdate(urlModel: GXWebOfflineAssetsModel,
                           path: String,
                           block: @escaping GXTaskDownloadBlock) {
        
        oneTaskDownload.diskFile.taskDownloadPath = self.hyDownPath + "/\(path)"
        
        let downloadModel = GXDownloadURLModel()
        downloadModel.src    = urlModel.src
        downloadModel.policy = urlModel.policy
        downloadModel.md5    = urlModel.md5
        downloadModel.match  = urlModel.match
        
        if let url = downloadModel.src {
            let isExist = oneTaskDownload.diskFile.checkUrlTask(url: urlModel.src ?? "")
            if isExist == true {
                oneTaskDownload.diskFile.clearFile(forUrl: url)
            }
            oneTaskDownload.prepare(urlModel: downloadModel)
            oneTaskDownload.start(block: block)
        } else {
            block(0,.error)
        }
    }
}
