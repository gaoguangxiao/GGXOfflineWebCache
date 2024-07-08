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
    
    // 动态下载队列
    private var downloadingTasks: Dictionary<String, GXTaskDownloadDisk> = [:]
    
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
        
        let oneTaskDownload = GXTaskDownloadDisk()
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
    
    // 将下载中的文件记录，用于判断当处于下载中，直接return,下载完毕的可以对其进行更新。为下载的进行下载
    func asyncDownloadAndUpdate(urlModel: GXWebOfflineAssetsModel,
                           path: String,
                           block: @escaping GXTaskDownloadBlock) {
        
        guard let src = urlModel.src else {
            return
        }
        let md5 = src.md5Value
        
        let download = GXTaskDownloadDisk()
        downloadingTasks[md5] = download
        download.diskFile.taskDownloadPath = self.hyDownPath + "/\(path)"
        
        let downloadModel = GXDownloadURLModel()
        downloadModel.src    = src
        downloadModel.policy = urlModel.policy
        downloadModel.md5    = urlModel.md5
        downloadModel.match  = urlModel.match
        
        if let url = downloadModel.src {
            let isExist = download.diskFile.checkUrlTask(url: urlModel.src ?? "")
            if isExist == true {
                download.diskFile.clearFile(forUrl: url)
            }
            download.prepare(urlModel: downloadModel)
            download.start { progress, state in
                if state == .completed || state == .error {
                    self.downloadingTasks.removeValue(forKey: md5)
//                    LogInfo("剩余下载任务数量：\(self.downloadingTasks.count)，\(state)")
//                    for dow in self.downloadingTasks {
//                        LogInfo("剩余下载任务：\(dow.key)--\(src)")
//                    }
                    block(progress,state)
                } else {
                    block(progress,state)
                }
            }
        } else {
            block(0,.error)
        }
    }
}
