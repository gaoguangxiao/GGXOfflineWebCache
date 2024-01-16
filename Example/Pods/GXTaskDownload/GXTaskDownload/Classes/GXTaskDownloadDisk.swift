//
//  GXTaskDownloadDisk.swift
//  GXTaskDownload
//
//  Created by 高广校 on 2023/12/7.
//

import Foundation
import GGXSwiftExtension

//任务下载器，负责将获取的data写入指定文件,单任务下载器
public class GXTaskDownloadDisk: NSObject {
    
    /// 磁盘管理类
    public var diskFile = GXTaskDiskFile()

    /// 回调block
    public var downloadBlock: GXTaskDownloadBlock?
    
//MARK: 属性
    lazy var downloader: GXDownloading = {
       let downloader = GXDownloader()
       downloader.delegate = self
       return downloader
   }()
    
    //虚拟
    var downloadPath: String {
        return diskFile.downloadPath
    }
    
    //本地可使用存储路径
    var path: String {
        return diskFile.path
    }
    
    
    public override init() {
//        fileHandle = FileManager.default
        //初始化下载路径
    }
    
    //
    public func start(forURL url: String,block: @escaping GXTaskDownloadBlock) {
//        LogInfo("调用次数------瞬间")
        guard let uurl = url.toUrl else {
            block(0,.error)
            return
        }
        
        let isExist = diskFile.checkUrlTask(url: url)
        if isExist {
            block(0,.completed)
            return
        } else {
            diskFile.createFilePath(forURL: url)
        }
        //配置回调
        self.downloadBlock = block
        //指定文件URL
        downloader.url = uurl
        //正式下载
        downloader.start()
    }
    
    public func prepare(forURL url: String) {
        guard let uurl = url.toUrl else {
            return
        }
        diskFile.urlStr = url
        //指定文件URL
        downloader.url = uurl
    }
    
    public func start(block: @escaping GXTaskDownloadBlock) {
//        LogInfo("调用次数------瞬间")
        guard let urlPath = diskFile.urlStr else {
            return
        }
//        print("路径：\(urlPath)")
        let isExist = diskFile.isExistDiskDataWith(url: urlPath)
//        let isExist = true
        if isExist {
            block(0,.completed)
            return
        } else {
            diskFile.createFilePath(forURL: urlPath)
        }
        //配置回调
        self.downloadBlock = block
        downloader.start()
    }
    
    public func pause() {
        downloader.pause()
    }
    
}
