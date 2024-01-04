//
//  GXHybridCache.swift
//  RSBridgeNetCache
//
//  Created by 高广校 on 2024/1/2.
//
//GXWebCache
import Foundation
import Combine
//import GGXSwiftExtension
//import ZKBaseSwiftProject
import SSZipArchive

public class GXHybridCache: NSObject {
    public static let share = GXHybridCache()
    
    lazy var presetPath: String? = {
        guard let cache = FileManager.cachesPath else { return nil }
        return cache + "/WebResource/Preset"
    }()
    
    /// 预置资源包名字
    var presetName: String? {
        get {
            UserDefaults.presetDataNameKey
        }
        set {
            UserDefaults.presetDataNameKey = newValue
        }
    }
    /// 预置资源包指定目录
    var presetHostName: String? {
        guard let presetPath = presetPath else {
            print("未获取预置资源路径")
            return nil
        }
        
        // 获取预置资源名
        guard let presetName = presetName else {
            print("未获取到资源包名")
            return nil
        }
        return presetPath + "/\(presetName)"
    }
    
    public override init() {
        
    }
    
    public func initLocalWebResource(name: String?, type: String?, version: String?, block: @escaping ((_ isSuccess: Bool) -> Void)) {
        //判断预置版本和传入是否一致
        let presetVersion = UserDefaults.presetDataVersionKey
        if presetVersion != version {
            if let path = Bundle.main.path(forResource: name, ofType: type) {
                if let folderPath = presetPath {
                    let toPath = folderPath + "/\(path.lastPathComponent)"
                    print("预置离线包路径:\(toPath)")
                    FileManager.moveFile(fromFilePath: path, toFilePath: toPath, fileType: .directory , moveType: .copy) { isSuccess in
                        block(isSuccess)
                        //解压
                        SSZipArchive.unzipFile(atPath: toPath, toDestination: folderPath)
                        //保存版本
                        UserDefaults.presetDataVersionKey = version
                        //获取预置资源包名字
                        self.presetName = path.lastPathComponent.stringByDeletingPathExtension
                    }
                    
                } else {
                    //构建路径失败
                    block(false)
                }
            }
            //2、解压预置资源
        } else {
            //相等
            print("预置版本和当前版本一致")
            
            //读取path路径
            
            
            //            self.presetName = UserDefaults.presetDataNameKey
            block(true)
        }
    }
    
    public func loadPresetConfig() {
        // 获取到确切资源包路径
        guard let presetHostName = self.presetHostName else {
            print("未获取到确切资源包路径")
            return
        }
        
        // 获取JSON数据
        
    }
    
    //根据URL 从本地获取缓存
    @available(iOS 13.0, *)
    public func loadCache(_ url: String) -> Future<Data?,Error>{
        
        return Future <Data?, Error> { promise in
            // 获取到确切资源包路径
            guard let presetHostName = self.presetHostName else {
                promise(.failure(GXHybridCacheError.hostNameError))
                print("未获取到确切资源包路径")
                return
            }
            // 资源ID
            guard let resourceID = self.resourceID(url) else {
                promise(.failure(GXHybridCacheError.pathExtError))
                print("未获取到资源ID")
                //                block(nil)
                return
            }
            
            let filePath = presetHostName + resourceID
            guard let fileUrl = filePath.toFileUrl else {
                promise(.failure(GXHybridCacheError.hostNameError))
                print("URL错误")
                //                block(nil)
                return
            }
            if let anyData = try? Data(contentsOf: fileUrl) {
                promise(.success(anyData))
            }
        }
        
    }
    
    public func loadOfflineCache(_ url: String) -> Data?{
        // 查找资源缓存策略 默认可查本地
//        return nil
        // 获取到确切资源包路径
        guard let presetHostName = self.presetHostName else {
            print("未获取到确切资源包路径")
            return nil
        }
        // 资源ID
        guard let resourceID = self.resourceID(url) else {
            print("未获取到资源ID")
            return nil
        }
        // 资源全路径
        let filePath = presetHostName + resourceID
        guard let fileUrl = filePath.toFileUrl else {
            print("URL错误")
            return nil
        }
        
        // 查看本地文件是否存在
        let isFileExist = FileManager.isFileExists(atPath: filePath)
        if isFileExist == false {
            print("文件不存在")
            return nil
        }
        
        if let anyData = try? Data(contentsOf: fileUrl) {
            print("找到磁盘缓存:\(fileUrl)")
            return anyData
        } else {
            return nil
        }
        
    }
    
    public func unzip(atPath: String,toDestination: String) {
        //        SSZipArchive.unzipFile(atPath: folderPath, toDestination: toDestination)
    }
    
    func loadResource(_ manifest: String) {
        
        //下载.内容容器
        //    http:192.168.50.165:8081static/json/1.manifest.json
        //    http://192.168.50.165:8081/static/json/1.manifest
        //        1、解析需要下载的json
        
        //读取文件
        //        String(s)
        //        ManiFestApiSeivice.requestManifest(url: manifest) { apiModel in
        //
        //            //
        //            print("内容版本：\(apiModel?.version)")
        ////            apiModel?.version
        //            guard let assets = apiModel?.assets else {
        //                return
        //            }
        //
        //            //2、依次下载
        //            for asset in assets {
        //                let download = GXHybridDownload()
        //                if let url = asset.src {
        //                    download.downloadUrl(url: url)
        //                }
        //            }
        //        }
        
        print("manifest:\(manifest)")
    }
    
    /// 从URL获取资源ID 减去前面域名
    /// - Parameter url: nawei/nawei.json
    /// - Returns: <#description#>
    func resourceID(_ url: String) -> String? {
        guard let url = url.toUrl else { return nil }
        if #available(iOS 16.0, *) {
            return url.path()
        } else {
            // Fallback on earlier versions
            return url.path
        }
    }
    
    func containResource(_ url: String) -> Bool {
        
        var result = false
        
        result = true
        
        return result
    }
    
    func readResourceData(_ url: String) -> Data? {
        
        var data: Data?
        
        return data
    }
    
    func readResourceResponseHeaders(_ url: String) -> Dictionary<String, Any>? {
        return [:]
    }
}
