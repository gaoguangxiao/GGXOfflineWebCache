//
//  GXTaskDownloadDisk.swift
//  GXTaskDownload
//
//  Created by 高广校 on 2023/12/7.
//

import Foundation

public typealias GXTaskDownloadBlock = (_ progress: Float ,_ state: GXDownloadingState)->Void

//任务下载器，负责将获取的data写入指定文件,单任务下载器
public class GXTaskDownloadDisk: NSObject {
    
    //
    public var diskFile = GXTaskDiskFile()

    
    var downloadBlock: GXTaskDownloadBlock?
    
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
        
        let isExist = diskFile.checkUrlTask(url: url)
        if isExist {
            block(0,.completed)
            return
        } else {
            diskFile.createFilePath(forURL: url)
        }
        
        diskFile.url = URL(string: url)
        //配置回调
        self.downloadBlock = block
        //指定文件URL
        downloader.url = diskFile.url
        //正式下载
        downloader.start()
        
    }
    
    public func pause() {
        downloader.pause()
    }
    
}
