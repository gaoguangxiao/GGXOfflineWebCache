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
import SSZipArchive

public class GXHybridCacheManager: NSObject {
    
    public static let share = GXHybridCacheManager()
    
    var resourceCachePath: String = "/WebResource"
    
    public lazy var presetPath: String? = {
        guard let cache = FileManager.cachesPath else { return nil }
        let _path = cache + "\(resourceCachePath)"
        FileManager.createFolder(atPath: _path)
        return _path
    }()
    
    /// 离线下载
    public lazy var oflineDownload: GXHybridDownload = {
        let download = GXHybridDownload()
        download.hyDownPath = resourceCachePath
        return download
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
    
    public override init() {
        
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
    func saveManifestConfig(manifestPath: String,
                                   block: @escaping ((_ isSuccess: Bool) -> Void)) {
        
        guard let presetPath = presetPath else {
            print("未获取预置资源路径")
            block(false)
            return
        }
        
        let manifestFolder = self.getOfflineManifestFolder(url: manifestPath)
        //拼接要创建的路径
        let toFileManifestPath = presetPath + "/\(manifestFolder)" + "/" + manifestPath.lastPathComponent
        
        FileManager.moveFile(fromFilePath: manifestPath,
                             toFilePath: toFileManifestPath,
                             fileType: .directory,
                             moveType: .copy) { isSuccess in
            block(isSuccess)
        }
    }
    
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
    
    
}

//MARK: 通过URL获取离线资源
public extension GXHybridCacheManager {
    
    func loadOfflineData(_ url: String) -> Data?{
        // 资源全路径
        if let fileUrl = self.loadOfflinePath(url)?.toFileUrl , let anyData = try? Data(contentsOf: fileUrl) {
            LogInfo("\(fileUrl)找到磁盘缓存")
            return anyData
        }  else {
            return nil
        }
    }
    
    func loadOfflinePath(_ url: String) -> String?{
        guard let presetPath = presetPath else {
            print("未获取预置资源路径")
            return nil
        }
        
        // 资源ID
        guard let resourceID = self.resourceID(url) else {
            print("未获取到资源ID")
            return nil
        }
        
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
    /// 获取本地配置manifest
    /// - Parameter url: <#url description#>
    /// - Returns: <#description#>
    func getOfflineManifestPath(url: String) -> String? {
        let folderName = self.manifestPathName + "/" + url.lastPathComponent.removeMD5.stringByDeletingPathExtension
        return getOfflineLastPathComponent(url, extendPath: folderName)
    }
    
    /// 预置目录/扩展目录/URL文件名
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
    func getOldManifestData(url: String) -> Dictionary<String, Any>? {
        
        guard let manifestPath = self.getOldManifestPath(url: url) else {
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
}


//MARK: 路径匹配
extension GXHybridCacheManager {
    ///
    func getOfflineManifestFolder(url: String) -> String {
        let folderName = self.manifestPathName + "/" + url.lastPathComponent.removeMD5.stringByDeletingPathExtension
        return folderName
    }
    
    /// 根据URL匹配原有文件
    /// - Parameter url: url description
    /// - Returns: <#description#>
    func getOldManifestPath(url: String) -> String? {
        
        guard let presetPath else {
            print("预置路径不存在")
            return nil
        }
        
        let manifestFolderPath = presetPath + "/\(self.getOfflineManifestFolder(url: url))"
        
        let filePaths = FileManager.getAllFileNames(atPath:manifestFolderPath)
        
        guard let _filePath = filePaths?.first(where: { $0 != url.lastPathComponent
        }) else {
            print("没有此资源")
            return nil
        }
        let manifestPath = manifestFolderPath + "/" + _filePath
        
        let isFileExist = FileManager.isFileExists(atPath: manifestPath)
        if isFileExist == false {
            print("文件不存在")
            return nil
        }
        return manifestPath
    }
}

//MARK: 删除离线资源
public extension GXHybridCacheManager {
    
    /// 移除web离线资源
    /// - Returns: <#description#>
    func removeAll()-> Bool {
        guard let folderPath = presetPath else {
            print("路径不存在")
            return false
        }
        return FileManager.removefile(atPath: folderPath)
    }
    
    @discardableResult
    /// 根据assets集合删除URL中在本地的离线资源
    /// - Parameter assets: <#assets description#>
    /// - Returns: <#description#>
    func removeOffline(assets: Array<GXWebOfflineAssetsModel>) -> Bool {
        for asset in assets {
            let _ = self.removeOffline(asset: asset)
        }
        return true
    }
    
    func removeOffline(asset: GXWebOfflineAssetsModel) -> Bool {
        self.removeFileWith(url:asset.src ?? "")
    }
    
    
    @discardableResult
    /// 删除指定path下的文件
    /// - Parameter path: <#path description#>
    /// - Returns: <#description#>
    func removeFile(path: String)-> Bool {
        guard let folderPath = presetPath else {
            print("路径不存在")
            return false
        }
        let allPath = folderPath + "/\(path)"
        return FileManager.removefile(atPath: allPath)
    }
    
    /// 根据网络URL 移除离线包文件
    /// - Parameter URL: <#URL description#>
    /// - Returns: <#description#>
    @discardableResult
    func removeFileWith(url: String)-> Bool {
        guard let folderPath = loadOfflinePath(url) else {
            print("路径不存在")
            return false
        }
        return FileManager.removefile(atPath: folderPath)
    }
}

//MARK: 更新离线资源
public extension GXHybridCacheManager {
    
    /// 使用本地预置更新离线包manifest配置
    /// - Parameters:
    ///   - manifestJSON: <#manifestJSON description#>
    ///   - block: <#block description#>
    func updateCurrentManifestUserPreset(manifestJSON: String, block: @escaping (Bool) -> Void) {
        
        self.saveManifestConfig(manifestPath: manifestJSON) { isSuccess in
            
            if let currentManifestPath = self.getOldManifestPath(url: manifestJSON) {
                FileManager.removefile(atPath: currentManifestPath)
            }
            
            block(true)
        }
    }
    
    /// 更新当前离线包manifest配置
    /// - Parameters:
    ///   - manifestJSON: <#manifestJSON description#>
    ///   - block: <#block description#>
    func updateCurrentManifest(manifestJSON: String, block: @escaping (Bool) -> Void) {
        //下载新配置
        let manifestPath = self.getOfflineManifestFolder(url: manifestJSON)
        self.oflineDownload.download(url: manifestJSON,
                                     path: manifestPath) { progress, state in
            if state == .completed || state == .error {
                print("配置文件下载完毕")
                
                //获取当前预置目录下位置
                if let currentManifestPath = self.getOldManifestPath(url: manifestJSON) {
                    FileManager.removefile(atPath: currentManifestPath)
                }
                //移除旧配置
                block(true)
            }
        }
    }
}
