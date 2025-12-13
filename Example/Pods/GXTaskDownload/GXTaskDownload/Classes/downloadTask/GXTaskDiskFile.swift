//
//  GXTaskDiskFile.swift
//  GXTaskDownload
//
//  Created by 高广校 on 2023/12/7.
//

import Foundation
import GGXSwiftExtension

//管理存储在磁盘的文件
public class GXTaskDiskFile: NSObject {
    
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
//    var url: URL?
    
    /// 下载文件路径
    //    var urlStr: String?
    
    /// URL下载信息
    public var remoteDownloadURLModel: GXDownloadURLModel?
    
    /// 是否进行md5校验 下载文件对比
    public var isUserMD5CheckFile = true
    
    func getUrlInfoLaseComponent(_ url: String) -> String {
        return url.md5Value + ".json"
    }
    
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
        guard let urlStr = self.remoteDownloadURLModel?.src else {
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
    
    public func isExistDiskAndMD5Update(url: String) -> Bool {
        let isExist = isExistDiskDataWith(url: url)
        if isExist, self.isUserMD5CheckFile {
            let filePath = getFilePath(url: url)
//            LogInfo("文件地址：\(filePath)")
            //获取其URL信息的MD5信息和磁盘的是否一致。
            if let urlInfoModel = getURLFileInfoModel(url: url),
               let loaclUrlMD5 = urlInfoModel.md5,
               let urlMD5 = remoteDownloadURLModel?.md5 {
//                print("loaclUrl:\(url) \n 本地\(loaclUrlMD5)--远端：\(urlMD5)")
                if !loaclUrlMD5.has(urlMD5,option: .caseInsensitive) {
                    clearFileAndInfo(forUrl: url)
                    return false
                }
            }
            //改为获取本地文件md5
            if let loaclUrlMD5 = self.getFileMD5ByUrl(url: url) ,
               let urlMD5 = remoteDownloadURLModel?.md5 {
//                print("loaclUrl:\(url) \n \(loaclUrlMD5)--\(urlMD5)")
                if !loaclUrlMD5.has(urlMD5,option: .caseInsensitive) {
                    clearFileAndInfo(forUrl: url)
                    return false
                }
            }
        }
        return isExist
    }
}

public extension GXTaskDiskFile {
    
    func getFileInfoPath(url: String) -> String? {
        //获取文件信息
        let filePath = path + "/\(self.getUrlInfoLaseComponent(url))"
        if fileManager.fileExists(atPath: filePath) == true {
            return filePath
        }
        return nil
    }
    
    
    /// 获取文件的Md5
    /// - Parameter url: <#url description#>
    /// - Returns: <#description#>
    func getFileMD5ByUrl(url: String) -> String? {
        return getFilePath(url: url).toFileUrl?.toMD5()
    }
        
    /// 获取其URL存储信息
    /// - Parameter url: <#url description#>
    /// - Returns: <#description#>
    func getURLFileInfoModel(url: String) -> GXDownloadURLModel? {
        //获取文件信息
        if let infofilePath = self.getFileInfoPath(url: url),
           let localPresetConfigData = infofilePath.toFileUrl?.filejsonData{
            guard let localJsonDict = localPresetConfigData as? Dictionary<String, Any> else {
                print("JSON格式有问题")
                return nil
            }
            let model = GXDownloadURLModel()
            model.src = localJsonDict["src"] as? String
            model.md5 = localJsonDict["md5"] as? String
            model.policy = localJsonDict["policy"] as? Int
            model.priority = localJsonDict["priority"] as? Int ?? 0
            model.info     = localJsonDict["info"] as? String
            model.match    = localJsonDict["match"] as? String
//            return GXDownloadURLModel.deserialize(from: localJsonDict)
            return model
            
            
        }
        return nil
    }
    
}

//MARK: 移除文件
public extension GXTaskDiskFile {
    
    func clearFile(forUrl url: String) {
        let filePath = getFilePath(url: url)
        do {
            try fileManager.removeItem(atPath: filePath)
        } catch _ {
            
        }
    }
    
    /// 移除URL以及对应信息
    /// - Parameter url: <#url description#>
    func clearFileAndInfo(forUrl url: String) {
        let filePath = getFilePath(url: url)
        do {
            try fileManager.removeItem(atPath: filePath)
        } catch _ {
            
        }
        
        if let fileInfoPath = getFileInfoPath(url: url) {
            do {
                try fileManager.removeItem(atPath: fileInfoPath)
            } catch _ {
                
            }
        }
    }
    
    func clearAllFile() {
        let filePath = downloadPath
        do {
            try fileManager.removeItem(atPath: filePath)
        } catch _ {
            //            print("")
        }
    }
}
