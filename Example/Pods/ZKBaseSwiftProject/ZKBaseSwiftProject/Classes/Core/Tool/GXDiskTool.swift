//
//  ZKDiskTool.swift
//  ZKBaseSwiftProject
//
//  Created by 高广校 on 2024/1/3.
//

import Foundation
import GGXSwiftExtension

public class ZKDiskTool: NSObject{
    
    
    public static let shared = ZKDiskTool()
    
    var audiosCachePath: String {
        return (FileManager.cachesPath ?? "") + "/record/"
    }
    
    //在Caches文件下创建指定文件夹
    public func createFolder(name: String) -> String? {
        guard let cache = FileManager.cachesPath else { return nil }
        let folderPath = cache + "/\(name)"
        let status = FileManager.createFolder(atPath: folderPath)
        return status ? folderPath : nil
    }
    
    public func createAudioRecordpath(path:String ,fileExt: String) -> String {
        
        let filePath = audiosCachePath + path.stringByDeletingLastPathComponent
        
        FileManager.createFolder(atPath:filePath)
        
        return filePath + "/" + "\(getAudioName(path))" + "." + "\(fileExt)"
    }
}

/// 音频文件
extension ZKDiskTool {
    
    public func createRecordAudioPathAndRemoveOldPath(path:String ,fileExt: String) -> String {
        let recordPath = self.createAudioRecordpath(path: path, fileExt: fileExt)
        //判断音频文件是否存在，移除旧音频文件
        if FileManager.isFileExists(atPath: recordPath) {
            FileManager.removefile(atPath: recordPath)
        }
        return recordPath
    }
    
    func getAudioCachePath(_ path:String) -> String {
        return audiosCachePath + path + "\(getAudioName(path))"
    }
    
    func getAudioName(_ path:String) -> String {
        return path.lastPathComponent
    }
    
    /// 带文件类型
    public func getAudioCacheLocalPath(_ path:String) -> String? {
        //判断是否存在此文件
        var filePath = "\(audiosCachePath)\(path)"
        if FileManager.isFileExists(atPath: filePath) {
            return filePath
        }
        
        guard let caches = FileManager.cachesPath else { return nil }
        filePath = "\(caches)\(path)"
        if FileManager.isFileExists(atPath: filePath) {
            return filePath
        }
        
        return nil
    }
    
    public func clearAudiosCache(path: String) -> Bool{
        //对某条音频文件进行清理
        if let filePath = getAudioCacheLocalPath(path) {
            return FileManager.removefile(atPath: filePath)
        }
        //对音频目录进行清理
        return false
    }
    
    public func clearAudiosCache(folder: String? = nil) -> Bool {
        guard let folder  else { 
            return clearAudiosCache()
        }
        //对文件目录进行清理`synthesizer`、`Record` 两个目录
        guard let caches = FileManager.cachesPath else { return false }
        
        let folderPath = "\(caches)/\(folder)"
        
        FileManager.removefolder(atPath: folderPath)

        return false
    }
    
    public func clearAudiosCache() -> Bool {
        
        return FileManager.removefolder(atPath: audiosCachePath)
    }
}
