//
//  GXTaskDiskFile.swift
//  GXTaskDownload
//
//  Created by 高广校 on 2023/12/7.
//

import Foundation

//管理存储在磁盘的文件
public struct GXTaskDiskFile {
    
    //写入沙盒路径
    public var cachesPath: String? {
        NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
    }
    
    //写入的文件路径
    public var downloadPath: String {
        guard let cachesPath = cachesPath else {
            return ""
        }
        return cachesPath + "/gxdownload"
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
    
//MARK: 方法
    func getFilePath(url: String) -> String {
        //获取文件全路径
        guard let downloadUrl = URL(string: url) else {
            print("不合法的URL")
            return ""
        }
        return path + "/\(downloadUrl.lastPathComponent)"
    }
    
    mutating func createFilePath(forURL url: String) {
        let filePath = getFilePath(url: url)
        //创建文件
        fileManager.createFile(atPath: filePath, contents: nil)
        
        //赋予句柄对文件操作权限
        fileHandle = FileHandle(forWritingAtPath: filePath)
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
