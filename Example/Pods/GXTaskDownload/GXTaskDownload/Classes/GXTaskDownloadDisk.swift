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
    
    //定义优先级
    ///1 ~ 5 优先级、默认为3
    public var taskPriority: Int = 3
    
    //MARK: 属性
    lazy var downloader: GXDownloader = {
        let downloader = GXDownloader()
        downloader.priority = taskPriority
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
    
    deinit {
//        print("\(self)-deinit")
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
            let downloadURLModel = GXDownloadURLModel()
            downloadURLModel.src = url
            diskFile.downloadURLModel = downloadURLModel
            diskFile.createFilePath(forURL: url)
        }
        //配置回调
        self.downloadBlock = block
        //指定文件URL
        downloader.url = uurl
        //正式下载
        downloader.start()
    }
    
    public func prepare(urlModel: GXDownloadURLModel) {
        guard let uurl = urlModel.src?.toUrl else {
            return
        }
        diskFile.downloadURLModel = urlModel
        
        ///更改downloader的优先级从
        taskPriority = urlModel.priority
        
        //指定文件URL
        downloader.url = uurl
    }
    
    public func start(block: @escaping GXTaskDownloadBlock) {
        //        LogInfo("调用次数------瞬间")
        guard let urlPath = diskFile.downloadURLModel?.src else {
            return
        }
        //        print("路径：\(urlPath)")
        let isExist = diskFile.isExistDiskAndMD5Update(url: urlPath)
        //disk
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

//MARK: URL下载完毕
extension GXTaskDownloadDisk {
    public func saveUrlInfo() {
        
        if let url = diskFile.downloadURLModel?.src {
            //文件信息以 文件名-info.json结尾
            let urlInfoPath = diskFile.path + "/" + "\(url.md5Value).json"
            
            let isexist = FileManager.isFileExists(atPath: urlInfoPath)
            if isexist == true {
                FileManager.removefile(atPath: urlInfoPath)
            }
            
            FileManager.createFile(atPath: urlInfoPath)
            if let jsonData = diskFile.downloadURLModel?.toJSONString(), let pkgPath = urlInfoPath.toFileUrl {
                try? jsonData.write(to: pkgPath, atomically: true, encoding: .utf8)
            }
            
        }
    }
}
