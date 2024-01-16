//
//  GXTaskDiskFile.swift
//  GXTaskDownload
//
//  Created by 高广校 on 2023/12/7.
//

import Foundation

//管理存储在磁盘的文件
public class GXTaskDiskFile {
    
    public static var share = GXTaskDiskFile()
    
    //写入沙盒路径
//    public var cachesPath: String? {
//        NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
//    }
    
    lazy var cachesPath: String? = {
        return FileManager.cachesPath
    }()
    
    /// 位于缓存目录
    public var taskDownloadPath: String?
    
    /// 写入的全文件路径
    public var downloadPath: String {
        guard let cachesPath = self.cachesPath else {
            return ""
        }
        return cachesPath + "/\(taskDownloadPath ?? "")"
    }
    
    var fileManager = FileManager.default
    
    var fileHandle: FileHandle?
    //本地可以写入的路径
    var path: String {
        do {
            try fileManager.createDirectory(atPath: downloadPath, withIntermediateDirectories: true)
            return downloadPath
        } catch _ {
            return ""
        }
    }
    
    //下载的URL
    var url: URL?
    
    /// 下载文件路径
    var urlStr: String?
    
//MARK: 方法
    func getFilePath(url: String) -> String {
        //获取文件全路径
        return path + "/\(url.lastPathComponent)"
    }
    
    func createFilePath(forURL url: String) {
        let filePath = getFilePath(url: url)
        //创建文件
        fileManager.createFile(atPath: filePath, contents: nil)
        
        //赋予句柄对文件操作权限
        fileHandle = FileHandle(forWritingAtPath: filePath)
    }
    
    public func checkUrlTask() -> Bool {
        guard let urlStr = self.urlStr else {
            print("URL不可为空")
            return false
        }
        let filePath = getFilePath(url: urlStr)
        return fileManager.fileExists(atPath: filePath)
    }
    
    public func isExistDiskDataWith(url: String) -> Bool {
        let filePath = getFilePath(url: url)
        return fileManager.fileExists(atPath: filePath)
    }
    
    public func checkUrlTask(url: String) -> Bool {
        let filePath = getFilePath(url: url)
        return fileManager.fileExists(atPath: filePath)
    }
    
    public func clearFile(forUrl url: String) {
        let filePath = getFilePath(url: url)
        do {
            try fileManager.removeItem(atPath: filePath)
        } catch _ {
//            print("")
        }
    }
    
    public func clearAllFile() {
        let filePath = downloadPath
        do {
            try fileManager.removeItem(atPath: filePath)
        } catch _ {
//            print("")
        }
    }
}
