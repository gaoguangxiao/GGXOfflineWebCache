//
//  GXHybridCacheManager.swift
//  RSBridgeNetCache
//
//  Created by 高广校 on 2024/1/2.
//  离线缓存管理类
//GXWebCache
import Foundation
import Combine
import GGXSwiftExtension
//import ZKBaseSwiftProject
import SSZipArchive
//import ZKBaseSwiftProject

public class GXHybridCacheManager: NSObject {
    
    public static let share = GXHybridCacheManager()
    
    var resourceCachePath: String = "/WebResource"
    
    public lazy var presetPath: String? = {
        guard let cache = FileManager.cachesPath else { return nil }
        let _path = cache + "\(resourceCachePath)"
        FileManager.createFolder(atPath: _path)
        return _path
    }()
    
    /// 预置资源包名字
    public var presetName: String?
    
    public var manifestPathName: String = "manifest"
    
    /// 配置文件存放目录
    public lazy var manifestPath: String = {
        guard let presetPath else { return "" }
        let _path = presetPath + "/\(manifestPathName)"
        FileManager.createFolder(atPath: _path)
        return _path
    }()
    
    /// 预置资源包指定目录
    var presetHostName: String? {
        guard let presetPath = presetPath else {
            print("未获取预置资源路径")
            return nil
        }
        
        // 获取预置资源名
        //        guard let presetName = presetName else {
        //            print("未获取到资源包名")
        //            return nil
        //        }
        return presetPath
    }
    
    public override init() {
        
    }
    
    /// 将预置离线包转移至目标目录
    /// - Parameters:
    ///   - path: 压缩包原路径
    ///   - configPath: 压缩包配置目录
    ///   - version: 版本
    ///   - block: <#block description#>
    public func moveOfflineWebResource(path: String,
                                       configPath: String, block: @escaping ((_ isSuccess: Bool) -> Void)) {
        
        guard let folderPath = presetPath else {
            print("预置路径不存在")
            block(false)
            return
        }
        
        let toPath = folderPath + "/\(path.lastPathComponent)"
        
        FileManager.moveFile(fromFilePath: path, toFilePath: toPath, fileType: .directory , moveType: .copy) { isSuccess in
            
            if isSuccess {
                //解压
                SSZipArchive.unzipFile(atPath: toPath, toDestination: folderPath, progressHandler: nil) { str, b, err in
                    //解压状态
                    if b == true {
                        //移除解压的文件
                        let isFileExists = FileManager.isFileExists(atPath: str)
                        if isFileExists {
                            FileManager.removefile(atPath: str)
                        }
                        
                        //保存版本json
                        self.savePresetConfig(presetConfigPath: configPath) { isSuccess in
                            block(isSuccess)
                        }
                    }
                }
                //解压状态
                //                print("解压状态:\(zipStatus)")
                
            } else {
                block(false)
            }
        }
        //
    }
    
    public func moveOfflineWebFile(urls: Array<GXWebOfflineAssetsModel?>,block: @escaping (_ isSuccess: Bool) -> Void)  {
        guard let presetName = presetName else {
            print("预置名称不存在")
            block(false)
            return
        }
        
        var index = 0

        for offlineAssets in urls {
            let url = offlineAssets?.src ?? ""
            let uurl = url.replace("/web/adventure", new: "")
            if let filePath = self.loadOfflineRelativePath(uurl, extendPath: "/\(presetName)") {
                self.moveOfflineWebFile(filePath: filePath, url: url,policy: offlineAssets?.policy ?? 0) { isSuccess in
                    index+=1
                    if index == urls.count {
                        block(true)
                    }
                }
            } else {
                index+=1
                if index == urls.count {
                    block(true)
                }
            }
        }
    }
    
    /// 移动特定的文件
    /// - Parameters:
    ///   - path: 文件路径
    ///   - policy： URL策略
    ///   - block: <#block description#>
    public func moveOfflineWebFile(filePath: String,
                                   url: String,
                                   policy: Int?,
                                   block: @escaping (_ isSuccess: Bool) -> Void) {
        guard let folderPath = presetPath else {
            print("预置路径不存在")
            block(false)
            return
        }
        // 资源ID
        guard let resourceID = self.resourceID(url) else {
            print("未获取到资源ID")
            return
        }
        
        var toPath: String = ""
        
        if let policy {
            toPath = folderPath + resourceID.stringByDeletingLastPathComponent + "/\(policy)" + "/\(resourceID.lastPathComponent)"
        } else {
            toPath = folderPath + resourceID.stringByDeletingLastPathComponent + "/\(resourceID.lastPathComponent)"
        }
        FileManager.moveFile(fromFilePath: filePath, toFilePath: toPath, fileType: .directory , moveType: .copy) { isSuccess in
            if isSuccess {
                block(true)
            } else {
                block( false)
            }
        }
    }
    
    /// 移动压缩文件
    /// - Parameters:
    ///   - path: 文件路径
    ///   - unzipName: 解压之后名字
    ///   - block: <#block description#>
    public func moveOfflineWebZip(path: String,
                                  unzipName:String,
                                  block: @escaping ((_ progress: Float,_ isSuccess: Bool) -> Void)) {
        guard let folderPath = presetPath else {
            print("预置路径不存在")
            block(0, false)
            return
        }
        let toPath = folderPath + "/\(path.lastPathComponent)"
        FileManager.moveFile(fromFilePath: path, toFilePath: toPath, fileType: .directory , moveType: .copy) { isSuccess in
            if isSuccess {
                //移除解压的文件
                self.removeFile(path: unzipName)
                
                SSZipArchive.unzipFile(atPath: toPath, toDestination: folderPath, overwrite: true, password: nil) { str, fileInfo, count, total in
                    let progress = Float(count)/Float(total)
                    block(Float(progress),false)
                } completionHandler: { str, b, err in
                    if b == true {
                        //移除解压的文件
                        let isFileExists = FileManager.isFileExists(atPath: str)
                        if isFileExists {
                            FileManager.removefile(atPath: str)
                        }
                        block(1.0,b)
                    }
                }
            } else {
                block(0, false)
            }
        }
        //
    }
    /// 将离线包对应配置和离线包存储
    /// - Parameter presetConfigName: <#presetConfigName description#>
    /// - Returns: <#description#>
    public func savePresetConfig(presetConfigPath: String, block: @escaping ((_ isSuccess: Bool) -> Void)) {
        let toFilePath = "\(self.manifestPath)/\(presetConfigPath.lastPathComponent)"
        FileManager.moveFile(fromFilePath: presetConfigPath,
                             toFilePath: toFilePath,
                             moveType: .copy) { isSuccess in
            block(isSuccess)
        }
    }
    
    //根据URL 从本地获取缓存
    //    @available(iOS 13.0, *)
    //    public func loadCache(_ url: String) -> Future<Data?,Error>{
    //
    //        return Future <Data?, Error> { promise in
    //            // 获取到确切资源包路径
    //            guard let presetHostName = self.presetHostName else {
    //                promise(.failure(GXHybridCacheError.hostNameError))
    //                print("未获取到确切资源包路径")
    //                return
    //            }
    //            // 资源ID
    //            guard let resourceID = self.resourceID(url) else {
    //                promise(.failure(GXHybridCacheError.pathExtError))
    //                print("未获取到资源ID")
    //                //                block(nil)
    //                return
    //            }
    //
    //            let filePath = presetHostName + resourceID
    //            guard let fileUrl = filePath.toFileUrl else {
    //                promise(.failure(GXHybridCacheError.hostNameError))
    //                print("URL错误")
    //                //                block(nil)
    //                return
    //            }
    //            if let anyData = try? Data(contentsOf: fileUrl) {
    //                promise(.success(anyData))
    //            }
    //        }
    //
    //    }
    
    
    
    
    
    /// 根目录/扩展目录/URL的path
    /// - Parameters:
    ///   - url: <#url description#>
    ///   - extendPath: <#extendPath description#>
    /// - Returns: <#description#>
    public func loadOfflineRelativePath(_ url: String, extendPath: String = "") -> String? {
        guard let presetPath = presetPath else {
            print("未获取预置资源路径")
            return nil
        }
        
        // 资源ID
        guard let resourceID = self.resourceID(url) else {
            print("未获取到资源ID")
            return nil
        }
        
        // 资源全路径
        let filePath = presetPath + extendPath + resourceID
        // 查看本地文件是否存在
        let isFileExist = FileManager.isFileExists(atPath: filePath)
        if isFileExist == false {
            print("文件不存在")
            return nil
        }
        return filePath
    }
    
    public func loadOfflineData(_ url: String) -> Data?{
        // 资源全路径
        if let fileUrl = self.loadOfflinePath(url)?.toFileUrl , let anyData = try? Data(contentsOf: fileUrl) {
            LogInfo("\(fileUrl)找到磁盘缓存")
            return anyData
        }  else {
            return nil
        }
    }
    
    public func loadOfflinePath(_ url: String) -> String?{
        guard let presetPath = presetPath else {
            print("未获取预置资源路径")
            return nil
        }
        

        // 资源ID
        guard let resourceID = self.resourceID(url) else {
            print("未获取到资源ID")
            return nil
        }
        
        //获取离线文件夹下的所有文件
//        let filePaths = FileManager.getAllFileNames(atPath: presetPath)
        
//        guard let _filePath = filePaths?.first(where: { $0.lastPathComponent == resourceID.lastPathComponent
//        }) else {
//            print("没有此资源")
//            return nil
//        }
        
        //改为通过遍历文件夹的形式获取资源
        //获取到确切资源包路径
        //        guard let presetHostName = self.presetHostName else {
        //            print("未获取到确切资源包路径")
        //            return nil
        //        }
        
        
        
//        //将资源ID 转变为本地
//        let filePath = presetPath + "/\(_filePath)"
//        guard let fileUrl = filePath.toFileUrl else {
//            print("URL错误")
//            return nil
//        }
        
        let _filePath_3 = presetPath + resourceID.stringByDeletingLastPathComponent + "/3" + "/\(resourceID.lastPathComponent)"
        if FileManager.isFileExists(atPath: _filePath_3) == true {
            return _filePath_3
        }
        
        let _filePath = presetPath + resourceID.stringByDeletingLastPathComponent + "/0" + "/\(resourceID.lastPathComponent)"
        if FileManager.isFileExists(atPath: _filePath) == true {
            return _filePath
        }
        
        // 资源全路径
        let filePath = presetPath + resourceID
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
        return filePath
    }
    
    ///请求资源并缓存
    public func loadRemoteResource(_ path: String) {
        let request = GXHybridRequest()
        guard let url = path.toUrl else { return }
        //        request.sendHyUrl(url: url) { data in
        //
        //        }
    }
    
    func loadResource(_ manifest: String) {
        print("manifest:\(manifest)")
    }
    
    /// 从URL获取资源ID 减去前面域名
    /// - Parameter url: nawei/nawei.json
    /// - Returns: <#description#>
    public func resourceID(_ url: String) -> String? {
        guard let url = url.toUrl else { return nil }
        if #available(iOS 16.0, *) {
            return url.path()
        } else {
            // Fallback on earlier versions
            return url.path
        }
    }
    
    /// 从URL获取资源名字，
    /// - Parameter url: 一段网络URL
    /// - Returns: URL最后一段 减去扩展
    public func resourceName(_ url: String) -> String? {
        guard let url = url.toUrl else { return nil }
        if #available(iOS 16.0, *) {
            return url.path().stringByDeletingPathExtension
        } else {
            // Fallback on earlier versions
            return url.path.stringByDeletingPathExtension
        }
    }
    
    @discardableResult
    public func removeFile(path: String)-> Bool {
        guard let folderPath = presetPath else {
            print("路径不存在")
            return false
        }
        let allPath = folderPath + "/\(path)"
        return FileManager.removefile(atPath: allPath)
    }
    
    @discardableResult
    
    /// 根据网络URL 移除离线包文件
    /// - Parameter URL: <#URL description#>
    /// - Returns: <#description#>
    public func removeFileWith(url: String)-> Bool {
                
        guard let folderPath = loadOfflinePath(url) else {
            print("路径不存在")
            return false
        }
        return FileManager.removefile(atPath: folderPath)
    }
    
    public func removeAll()-> Bool {
        guard let folderPath = presetPath else {
            print("路径不存在")
            return false
        }
        return FileManager.removefile(atPath: folderPath)
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

//MARK: 通过URL操作本地离线资源
public extension GXHybridCacheManager {
    
    /// 获取本地配置manifest
    /// - Parameter url: <#url description#>
    /// - Returns: <#description#>
    func getOfflineManifestPath(url: String) -> String? {
        
        return getOfflineLastPathComponent(url, extendPath: self.manifestPathName)
    }
    
    /// 根目录/扩展目录/URL文件名
    /// - Parameters:
    ///   - url: url description
    ///   - extendPath: <#extendPath description#>
    /// - Returns: <#description#>
    func getOfflineLastPathComponent(_ url: String, extendPath: String = "") -> String? {
        guard let presetPath = presetPath else {
            print("未获取预置资源路径")
            return nil
        }
        
        // 资源全路径
        let filePath = presetPath + "/\(extendPath)" + "/\(url.lastPathComponent)"
        // 查看本地文件是否存在
        let isFileExist = FileManager.isFileExists(atPath: filePath)
        if isFileExist == false {
            print("文件不存在")
            return nil
        }
        return filePath
    }
    
    /// 通过URL的json获取离线包 ManifestModel-本地资源目录
    /// - Parameter url: <#url description#>
    /// - Returns: description
     func getSandboxManifestModel(url: String) -> Dictionary<String, Any>? {
        
        //匹配目录
        //获取离线文件夹下的所有文件
        guard let presetPath else {
            print("预置路径不存在")
            return nil
        }
        
        let filePaths = FileManager.getAllFileNames(atPath: presetPath + "/manifest")
        
        guard let _filePath = filePaths?.first(where: { $0.removeMD5 == url.lastPathComponent
        }) else {
            print("没有此资源")
            return nil
        }
        let manifestPath = presetPath + "/manifest/" + _filePath
        
        let isFileExist = FileManager.isFileExists(atPath: manifestPath)
        if isFileExist == false {
            print("文件不存在")
            return nil
        }
        
        if let localPresetConfigData = manifestPath.toFileUrl?.filejsonData{
            guard let localJsonDict = localPresetConfigData as? Dictionary<String, Any> else {
                print("JSON格式有问题")
                return nil
            }
            return localJsonDict
        }
        return nil
    }
    
    func removeAr(Arr: Array<String>) {
        
        //保留
        let assets = ["A","B","C"]
        
        //待删除的元素
        let oldManifestAssets = ["A","C","D",]
        
        //旧元素json不包含在assest中元素
        let deletes = oldManifestAssets.filter { !assets.contains($0)}
        print(deletes)
 
//        print(nre)
    }
}

//MARK: 删除离线资源
public extension GXHybridCacheManager {
    
    @discardableResult
    func removeOffline(assets: Array<GXWebOfflineAssetsModel>) -> Bool {
        for asset in assets {
            let _ = self.removeOffline(asset: asset)
        }
        
        return true
    }
    
    func removeOffline(asset: GXWebOfflineAssetsModel) -> Bool {
        
        self.removeFileWith(url:asset.src ?? "")
    }
}
