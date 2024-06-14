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

public protocol GXHybridCacheManagerDelegate: NSObject {
    
    /// 解压结束
    func unzipFinish()
    
    /// 配置开始
    func configStart()
    
    /// 配置结束
    func configFinish()
}


public class GXHybridCacheManager: NSObject {
    
    public static let share = GXHybridCacheManager()
    
    public var resourceCachePath: String = "/WebResource"
    
    public weak var delegate: GXHybridCacheManagerDelegate?
    
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
    var presetName: String?
    
    /// src配置服务器路径
    public var webFolderName: String = ""
    
    //manifest名字
    public var manifestPathName: String = "manifest"
    
    /// 0.1.6版本预置资源存放的文件夹
    public var presetFolder: String = "preset"
    
    /// 配置文件存放目录
    public lazy var manifestPath: String = {
        guard let presetPath else { return "" }
        let _path = presetPath + "/\(manifestPathName)"
        FileManager.createFolder(atPath: _path)
        return _path
    }()
    
    public override init() {
        
    }
    
//    public func movePresetPkg(block: @escaping (_ isSuccess: Bool) -> Void)  {
//        if let paths = getPresetManifestPaths() {
//            for name in paths {
//                let presetManifestModel = getPresetManifestModel(manifesetName: name)
//                guard let assets = presetManifestModel?.assets else {
//                    block(false)
//                    return
//                }
//                self.moveOfflineWebFile(urls: assets) { isSuccess in
//                    print("\(name)移动成功")
//                    
//                    //保存配置
//                    if let configFilePath = self.getPresetFilePath(fileName: name) , isSuccess == true {
//                        self.updateCurrentManifestUserPreset(manifestJSON: configFilePath) { b in
//
//                        }
//                    } else {
//                    }
//                }
//            }
//        }
//        block(true)
//    }
    
    public func movePresetPkg(block: @escaping (_ isSuccess: Bool,_ count: Int, _ total:Int) -> Void)  {
        var moveFinishCount = 0
        var totalCount = 0
        if let paths = getPresetManifestPaths() {
            for name in paths {
                let presetManifestModel = getPresetManifestModel(manifesetName: name)
                if let assets = presetManifestModel?.assets {
                    totalCount += assets.count
                }
            }
        }
        
        if let paths = getPresetManifestPaths() {
//            print("Manifest的数量：\(paths.count)")
            for name in paths {
                let presetManifestModel = getPresetManifestModel(manifesetName: name)
                guard let assets = presetManifestModel?.assets else {
                    block(false,0,0)
                    return
                }
                self.moveOfflineWebFile(urls: assets) { isSuccess, count, total in
//                }
                    if isSuccess {
                        //保存配置
                        if let configFilePath = self.getPresetFilePath(fileName: name) , isSuccess == true {
//                            print("manifest config: \(configFilePath)")
                            self.updateCurrentManifestUserPreset(manifestJSON: configFilePath) { b in

                            }
                        } else {
//                            print("manifest config error")
                        }
                    } else {
                        moveFinishCount+=1
//                        print("\(name)移动成功:\(moveFinishCount)、: \(totalCount)")
                    }
                    block(moveFinishCount >= totalCount,moveFinishCount,totalCount)
                }
            }
//            block(true,1,paths.count)
        }
        block(true,1,1)
    }
    
    public func moveOfflineWebFile(urls: Array<GXWebOfflineAssetsModel?>,block: @escaping (_ isSuccess: Bool) -> Void)  {
        for offlineAssets in urls {
            if let assets = offlineAssets {
                self.moveOfflineWebFile(asset: assets) { b in
//                    LogInfo("moveOfflineWebFile---当前线程:\(Thread.current)-移动成功: \(assets.src ?? "")")
                }
            }
        }
        block(true)
    }
    
    public func moveOfflineWebFile(urls: Array<GXWebOfflineAssetsModel?>,block: @escaping (_ isSuccess: Bool,_ count: Int, _ total:Int) -> Void)  {
        var moveFinishCount = 0
        for offlineAssets in urls {
            if let assets = offlineAssets {
                self.moveOfflineWebFile(asset: assets) { b in
                    moveFinishCount+=1
//                    LogInfo("moveOfflineWebFile---当前线程:\(Thread.current)-移动成功: \(assets.src ?? "")")
                    block(false,1,urls.count)
                }
            }
        }
        block(true,urls.count,urls.count)
    }
    
    /// 移动特定的文件
    /// - Parameters:
    ///   - path: 文件路径
    ///   - policy： URL策略
    ///   - block: block description
    public func moveOfflineWebFile(asset: GXWebOfflineAssetsModel,
                                   block: @escaping (_ isSuccess: Bool) -> Void) {
        
        guard let presetName = presetName else {
            print("预置名称不存在")
            block(false)
            return
        }
        
        let url = asset.src ?? ""
        guard let filePath = self.getPresetOfflineFilePath(url, extendPath: "/\(presetName)") else {
            block(false)
            return
        }
        
        if let toFolderPath = self.getBoxURLFolderBy(remoteURL: url) {
            let toPath: String = toFolderPath + "/" + "\(url.lastPathComponent)"
//            LogInfo("moveOfflineWebFile---当前线程:\(Thread.current)")
            FileManager.moveFile(fromFilePath: filePath, toFilePath: toPath, fileType: .directory , moveType: .copy) { isSuccess in
                if isSuccess {
                    //保存配置信息
                    self.saveUrlInfo(asset: asset, folderPath: toFolderPath)
//                    LogInfo("moveOfflineWebFile---当前线程:\(Thread.current)-移动成功: \(filePath)")
                    block(true)
                } else {
                    block( false)
                }
            }
        } else {
            print("预置文件不存在")
            block(false)
        }
    }
    
    func saveUrlInfo(asset: GXWebOfflineAssetsModel, folderPath: String) {
        
        if let url = asset.src {
            //文件信息以 文件名-info.json结尾
            let urlInfoPath = folderPath + "/" + "\(url.md5Value).json"
            
            let isexist = FileManager.isFileExists(atPath: urlInfoPath)
            if isexist == true {
                FileManager.removefile(atPath: urlInfoPath)
            }
            
            FileManager.createFile(atPath: urlInfoPath)
            if let jsonData = asset.toJSONString(), let pkgPath = urlInfoPath.toFileUrl {
                try? jsonData.write(to: pkgPath, atomically: true, encoding: .utf8)
            }
        }
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
    
    func resourceInfoPath(_ url: String) -> String? {
        return url.md5Value + ".json"
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
    
    /// 预置目录/扩展目录/URL文件名
    /// - Parameters:
    ///   - url: url description
    ///   - extendPath: <#extendPath description#>
    /// - Returns: <#description#>
    func getBoxLastPathComponentPath(_ lastPathComponent: String, extendPath: String = "") -> String? {
        guard let presetPath = presetPath else {
            print("未获取预置资源路径")
            return nil
        }
        
        // 资源全路径
        let filePath = presetPath + "/\(extendPath)" + "/\(lastPathComponent)"
        // 查看本地文件是否存在
        let isFileExist = FileManager.isFileExists(atPath: filePath)
        if isFileExist == false {
            print("文件不存在")
            return nil
        }
        return filePath
    }
}

//MARK: 通过URL获取本地文件路径【私有】
extension GXHybridCacheManager {
    
    /// 获取文件信息所在的地址
    /// - Parameters:
    ///   - url: url description
    ///   - extensionFolder: <#extensionFolder description#>
    /// - Returns: <#description#>
    func getBoxURLInfoFilePathBy(remoteURL url: String, extensionFolder: String) -> String? {
        if let folderPath = self.getBoxURLFolderBy(remoteURL: url, extensionFolder: extensionFolder),
           let urlName = self.resourceInfoPath(url){
            let filePath = folderPath + "/\(urlName)"
            if FileManager.isFileExists(atPath: filePath) == true {
                return filePath
            }
            return nil
        }
        
        return nil
    }
    
    /// 获取文件所在的地址
    /// - Parameters:
    ///   - url: <#url description#>
    ///   - extensionFolder: <#extensionFolder description#>
    /// - Returns: <#description#>
    func getBoxURLFilePathBy(remoteURL url: String, extensionFolder: String) -> String? {
        
        if let folderPath = self.getBoxURLFolderBy(remoteURL: url, extensionFolder: extensionFolder) {
            let filePath = folderPath + "/\(url.lastPathComponent)"
            if FileManager.isFileExists(atPath: filePath) == true {
                return filePath
            }
            return nil
        }
        
        return nil
    }
    
    /// 获取文件所在目录
    /// - Parameters:
    ///   - url: <#url description#>
    ///   - extensionFolder: <#extensionFolder description#>
    /// - Returns: <#description#>
    func getBoxURLFolderBy(remoteURL url: String, extensionFolder: String = "") -> String? {
        //根目录
        guard let presetPath = presetPath else {
            print("未获取预置资源路径")
            return nil
        }
        
        if extensionFolder.length > 0 {
            return presetPath + "/\(extensionFolder)" + url.toPath.stringByDeletingLastPathComponent
        } else {
            return presetPath + "/" + url.toPath.stringByDeletingLastPathComponent
        }
    }
}

//MARK: 通过URL获取离线资源
public extension GXHybridCacheManager {
    
    func loadOfflineData(_ url: String) -> Data?{
        // 资源全路径
        if let fileUrl = self.loadOfflinePath(url)?.toFileUrl , let data = try? Data(contentsOf: fileUrl) {
            //            let fh = try? FileHandle.init(forReadingFrom: fileUrl)
            //            var data : Data?
            //            if #available(iOS 13.4, *) {
            //                data = try? fh?.readToEnd()
            //            } else {
            //                // Fallback on earlier versions
            //                data = fh?.readDataToEndOfFile()
            //            }
            LogInfo("\(fileUrl)找到磁盘缓存")
            return data
        }  else {
            return nil
        }
    }
    
    func loadOfflineData(_ url: String, extensionFolder: String) -> Data?{
        // 资源全路径
        if let fileUrl = self.loadOfflinePath(url,extensionFolder: extensionFolder)?.toFileUrl , let anyData = try? Data(contentsOf: fileUrl) {
            LogInfo("\(fileUrl)找到磁盘缓存")
            return anyData.count != 0 ? anyData : nil
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
        guard filePath.toFileUrl != nil else {
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
    
    /// 增加动态离线包目录
    /// - Parameters:
    ///   - url: <#url description#>
    ///   - extensionFolder: <#extensionFolder description#>
    /// - Returns: <#description#>
    func loadOfflinePath(_ url: String, extensionFolder: String) -> String? {
        
        //        let b = url.has("umi.574b22ed.js")
        //        if b == true {
        //            print(b)
        //        }
        
        //获取此URL的策略
        if let assetModel = self.getBoxOfflineAssetModel(url: url,extensionFolder: extensionFolder) {
            
            guard let presetPath = presetPath else {
                print("未获取预置资源路径")
                return nil
            }
            
            // 资源ID
            guard let resourceID = self.resourceID(url) else {
                print("未获取到资源ID")
                return nil
            }
            
            let folderPath = presetPath + "/\(extensionFolder)"
            
            if assetModel.policy == 0 {
                
                return nil
                
            } else if assetModel.policy == 1 {
                
                return nil
            } else if assetModel.policy == 2 {
                //优先使用缓存
                let resfolderPath = folderPath + resourceID.stringByDeletingLastPathComponent
                let _filePath_3 = resfolderPath + "/\(resourceID.lastPathComponent)"
                
                //更新缓存
                let cachePath = extensionFolder + resourceID.stringByDeletingLastPathComponent
                self.asyncUpdateOfflineWithURL(assetModel, path: cachePath)
                
                //检测本地是否存在
                if FileManager.isFileExists(atPath: _filePath_3) == true {
                    return _filePath_3
                }
            } else if assetModel.policy == 3 {
                //获取
                if let _filePath_3 = assetModel.localFullFilePath {
                    return _filePath_3
                }
            }
        }
        return self.loadOfflinePath(url)
    }
    
    /// 通过URL的json获取离线包ManifestModel
    /// - Parameter url: url description
    /// - Returns: description
    func getOfflineManifestModel(url: String, extendPath: String) -> GXWebOfflineManifestModel? {
        if let manifestPath = self.getOfflineLastPathComponent(url,extendPath: extendPath),
           let localPresetConfigData = manifestPath.toFileUrl?.filejsonData{
            guard let localJsonDict = localPresetConfigData as? Dictionary<String, Any> else {
                print("JSON格式有问题")
                return nil
            }
            let baseModel = GXWebOfflineManifestModel.deserialize(from: localJsonDict)
            return baseModel
        }
        return nil
    }

    /// 模糊匹配
    func getOfflineManifestPathName(url: String) -> String? {
        guard let presetPath = presetPath else {
            print("未获取预置资源路径")
            return nil
        }
        //获取文件夹名
        let manifestfoldName = self.getOfflineManifestFolderName(url: url)
        //获取路径
        let manifestFolderPath = presetPath + "/" + self.manifestPathName + "/" + "\(manifestfoldName)"
        
        let filePaths = FileManager.getAllFileNames(atPath:manifestFolderPath)
        //filePaths中唯一的
        guard let _filePath = filePaths?.first(where: { $0.contains(manifestfoldName)
        }) else {
            print("没有此资源:\(url)")
            return nil
        }
        return _filePath
    }
    
    func getOfflineManifestfoldName(manifestfoldName: String) -> String? {
        guard let presetPath = presetPath else {
            print("未获取预置资源路径")
            return nil
        }
        //获取文件夹名
//        let manifestfoldName = self.getOfflineManifestFolderName(url: url)
        //获取路径
        let manifestFolderPath = presetPath + "/" + self.manifestPathName + "/" + "\(manifestfoldName)"
        
        let filePaths = FileManager.getAllFileNames(atPath:manifestFolderPath)
        //filePaths中唯一的
        guard let _filePath = filePaths?.first(where: { $0.contains(manifestfoldName)
        }) else {
            print("没有此资源:\(manifestfoldName)")
            return nil
        }
        return _filePath
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
        
        guard let oldManifestPath = self.getOldManifestPath(url: url) else {
            print("文件不存在")
            return nil
        }
        
        if let localPresetConfigData = oldManifestPath.toFileUrl?.filejsonData{
            guard let localJsonDict = localPresetConfigData as? Dictionary<String, Any> else {
                print("JSON格式有问题")
                return nil
            }
            return localJsonDict
        }
        return nil
    }
    
    /// 整合下面两个
    func getBoxOfflineAssetModel(url: String,extensionFolder: String?) -> GXWebOfflineAssetsModel?{
        guard let assetModel = self.getOfflineAssetModel(url: url,extensionFolder: extensionFolder) else {
            return getOfflineAssetModel(url: url, extensionFolder: nil)
        }
        return assetModel
        
    }
    
    /// 获取URL的离线配置信息
    /// - Parameter url: <#url description#>
    /// - Returns: <#description#>
    func getOfflineAssetModel(url: String) -> GXWebOfflineAssetsModel?{
        
        return getOfflineAssetModel(url: url, extensionFolder: nil)
        
    }
    
    /// 获取URL的离线配置信息
    /// - Parameter url: <#url description#>
    /// - Returns: <#description#>
    func getOfflineAssetModel(url: String, extensionFolder: String?) -> GXWebOfflineAssetsModel?{
        guard let presetPath = presetPath else {
            print("未获取预置资源路径")
            return nil
        }
        
        // 资源ID
        guard var resourceID = self.resourceName(url) else {
            print("未获取到资源信息路径")
            return nil
        }
        //将sr目录按照配置目录移除
        
        guard let resourceInfo = self.resourceInfoPath(url) else {
            print("未获取到资源信息路径")
            return nil
        }
        
        var folderPath = presetPath
        if let extensionFolder {
            folderPath = presetPath + "/\(extensionFolder)"
        }
        
        ///匹配文件目录
        var fileFolderPath = folderPath + resourceID.stringByDeletingLastPathComponent
        // 匹配文件路径
        var infofilePath = fileFolderPath + "/\(resourceInfo)"
                
        if FileManager.isFileExists(atPath: infofilePath) == false {
            //查预置路径
            fileFolderPath = folderPath + "/\(self.presetFolder)" + resourceID.stringByDeletingLastPathComponent

            infofilePath = fileFolderPath + "/\(resourceInfo)"
            if FileManager.isFileExists(atPath: infofilePath) == false {
                return nil
            }
        }

        if let localPresetConfigData = infofilePath.toFileUrl?.filejsonData {
            guard let localJsonDict = localPresetConfigData as? Dictionary<String, Any> else {
                print("JSON格式有问题")
                return nil
            }
            let assetsModel = GXWebOfflineAssetsModel.deserialize(from: localJsonDict)
            //查具体文件位置
            let localFullFilePath = fileFolderPath.stringByAppendingPathComponent(path: url.lastPathComponent)
            if FileManager.isFileExists(atPath: localFullFilePath) == true {
                assetsModel?.localFullFilePath = localFullFilePath
            }
            return assetsModel
        }
        
        return nil
    }
}


//MARK: 路径匹配
extension GXHybridCacheManager {
    
    /// 获取manifest的文件夹名
    func getOfflineManifestFolderName(url: String) -> String {
        return url.lastPathComponent.removeMD5.stringByDeletingPathExtension
    }
    
    ///
    func getOfflineManifestFolder(url: String) -> String {
        let manifestfoldName = self.getOfflineManifestFolderName(url: url)
        let folderName = self.manifestPathName + "/" + manifestfoldName
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
            print("没有此资源:\(url)")
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

//MARK: 预置资源操作
extension GXHybridCacheManager {
    
    /// 移动压缩文件
    /// - Parameters:
    ///   - path: 文件路径
    ///   - unzipName: 解压之后名字
    ///   - block: block description
    public func moveOfflineWebZip(path: String,
                                  unzipName:String,
                                  block: @escaping ((_ progress: Float,_ isUnZipSuccess: Bool,_ isMoveSuccess: Bool) -> Void)) {
        //将离线资源移除-重新新建
        if let presetPath {
            FileManager.removefile(atPath: presetPath)
            print("app更新移除本地离线资源")
//            self.removeFileWith(url: presetPath)
//            self.removeFile(path: presetPath)
        }

        guard let folderPath = presetPath else {
            print("预置路径不存在")
            block(0, false,false)
            return
        }
        let toPath = folderPath + "/\(path.lastPathComponent)"
        FileManager.moveFile(fromFilePath: path, toFilePath: toPath, fileType: .directory , moveType: .copy) { isSuccess in
            if isSuccess {
                //移除压缩包
                self.removeFile(path: unzipName)
                
                SSZipArchive.unzipFile(atPath: toPath, toDestination: folderPath, overwrite: true, password: nil) { str, fileInfo, count, total in
//                    LogInfo("当前线程:\(Thread.current)")
                    let progress = Float(count)/Float(total)
                    block(Float(progress),false,false)
                } completionHandler: { str, b, err in
                    if b == true {
                        //解压完成-移除压缩包
                        let isFileExists = FileManager.isFileExists(atPath: str)
                        if isFileExists {
                            FileManager.removefile(atPath: str)
                        }
                        
                        //移动内部静态资源
                        let fromPresetPath = folderPath + "/\(unzipName)" + "/\(self.presetFolder)"
                        let toPresetPath = folderPath.stringByAppendingPathComponent(path: "\(self.presetFolder)")
                        let filemanager = FileManager.default
                        do {
                            try filemanager.copyItem(atPath: fromPresetPath, toPath: toPresetPath)
                        } catch let e {
                            print(e)
                        }
                        
                        /// 配置开始
                        self.delegate?.configStart()
                        
                        //移动进度
                        self.movePresetPkg { isSuccess, count, total in
                            let progress = Float(count)/Float(total)
//                            print("移动进度:\(progress)")
                            block(Float(progress),b,false)
                            if isSuccess {
                                self.delegate?.configFinish()
                            }
                        }
                        //移动成功之后删除解压之后的备用文件
                        self.removeFile(path: unzipName)
                        
                        self.delegate?.unzipFinish()
                        block(1.0,b,true)
                    }
                }
            } else {
                block(0, false,false)
            }
        }
        //
    }
    /// 获取预置文件夹中预置文件
    /// - Parameter url: url description
    /// - Returns: <#description#>
    public func getPresetManifestPaths() -> Array<String>? {
        
        guard let presetPath , let presetName else {
            print("预置路径不存在")
            return nil
        }
        
        let presetManifestFolderPath = presetPath + "/" + "/\(presetName)" + "/\(self.manifestPathName)"
        
        let filePaths = FileManager.getAllFileNames(atPath:presetManifestFolderPath)
        return filePaths
    }
    
    /// 获取本地预置离线包版本数据
    /// - Parameter url: <#url description#>
    /// - Returns: <#description#>
    func getPresetManifestModel(manifesetName: String) -> GXWebOfflineManifestModel? {
        if let localPresetConfigPath = self.getPresetFilePath(fileName:manifesetName) ,
           let localPresetConfigData = localPresetConfigPath.toFileUrl?.filejsonData{
            guard let localJsonDict = localPresetConfigData as? Dictionary<String, Any> else {
                print("JSON格式有问题")
                return nil
            }
            return GXWebOfflineManifestModel.deserialize(from: localJsonDict)
        }
        return nil
    }
    
    /// 根据URL名字换取预置离线包下资源
    /// - Parameter url: url description
    /// - Returns: <#description#>
    func getPresetFilePath(fileName: String) -> String? {
        return self.getBoxLastPathComponentPath(fileName, extendPath: "/\(self.presetName ?? "")/\(self.manifestPathName)")
    }
    
    /// 根据配置的URL获取预置离线资源
    /// - Parameters:
    ///   - url:
    ///   - extendPath: <#extendPath description#>
    /// - Returns: <#description#>
    public func getPresetOfflineFilePath(_ url: String, extendPath: String = "") -> String? {
        guard let presetPath = presetPath else {
            print("未获取预置资源路径")
            return nil
        }

        // 资源ID
        guard var resourceID = self.resourceID(url) else {
            print("未获取到资源ID")
            return nil
        }
        
        resourceID = resourceID.replace("/\(webFolderName)", new: "")
        
        // 资源全路径
        let filePath = presetPath + extendPath + resourceID
        // 查看本地文件是否存在
        let isFileExist = FileManager.isFileExists(atPath: filePath)
        if isFileExist == false {
//            print("文件不存在:\(filePath)")
            return nil
        }
        return filePath
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
    /// 根据assets集合删除URL中在本地的离线资源
    /// - Parameter assets: <#assets description#>
    /// - Returns: <#description#>
    func removeOffline(assets: Array<GXWebOfflineAssetsModel>, folder: String) -> Bool {
        for asset in assets {
            let _ = self.removeOffline(asset: asset, folder: folder)
        }
        return true
    }
    
    func removeOffline(asset: GXWebOfflineAssetsModel, folder: String) -> Bool {
        
        if let str = asset.src,
           let srcBoxPath = getBoxURLFilePathBy(remoteURL: str, extensionFolder: folder),
           let srcURLInfoPath = getBoxURLFilePathBy(remoteURL: str, extensionFolder: folder)
        {
            
            FileManager.removefile(atPath: srcBoxPath)
            
            FileManager.removefile(atPath: srcURLInfoPath)
        }
        return true
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
    
    @discardableResult
    func removeFileByURL(remoteURL url: String, extensionFolder: String)-> Bool {
        if let filePath = self.getBoxURLFilePathBy(remoteURL: url, extensionFolder: extensionFolder) {
            return FileManager.removefile(atPath: filePath)
        }
        return false
    }
    
    
    @discardableResult
    func removeManifestFileByURL(remoteURL url: String, extensionFolder: String)-> Bool {
        guard let presetPath = presetPath else {
            print("未获取预置资源路径")
            return false
        }
        let filePath = presetPath + "/\(extensionFolder)" + "/\(url.lastPathComponent)"
        
        return FileManager.removefile(atPath: filePath)
        
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
    
    func asyncUpdateOfflineWithURL(_ assets: GXWebOfflineAssetsModel, path: String) {
        
        self.oflineDownload.downloadAndUpdate(urlModel: assets, path: path) { progress, state in
            
            if state == .completed {
                LogInfo("\(assets.src ?? "")异步更新成功")
            }
        }
        
    }
    
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
    ///   - manifestJSON: manifestJSON description
    ///   - block: <#block description#>
    func updateCurrentManifest(manifestJSONs: Array<String>, block: @escaping (Bool) -> Void) {
  
        //删除旧
        for manifestJSON in manifestJSONs {
            //获取当前预置目录下位置
            if let currentManifestPath = self.getOldManifestPath(url: manifestJSON) {
                FileManager.removefile(atPath: currentManifestPath)
            }
        }
        
        /// 以文件后缀存储json
        self.oflineDownload.download(urls: manifestJSONs,path: self.manifestPathName,priority: 3) { total, loaded, state in
            //移除md5，并删除
            if state == .completed || state == .error {
                //移除旧配置,manifest不需要保存json
                block(true)
            }
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
                                     path: manifestPath) { [weak self] progress, state in
            if state == .completed || state == .error {
                print("配置文件下载完毕:\(manifestJSON)")
                
                //获取当前预置目录下位置
                if let currentManifestPath = self?.getOldManifestPath(url: manifestJSON) {
                    FileManager.removefile(atPath: currentManifestPath)
                }
                //移除旧配置
                block(true)
            }
        }
    }
    
    func updatePkgManifest(maniModel: GXWebOfflineManifestModel, maniPath: String, block: @escaping (Bool) -> Void) {
        //保存配置
        guard let maniStr = maniModel.toJSONString() else {
            return
        }
        let jsonData = maniStr.data(using: .utf8)
        //
        guard let presetPath = self.presetPath else {
            print("未获取预置资源路径")
            return
        }
        
        let pkgManifestPath = presetPath + "/\(maniPath)"
        
        let isexist = FileManager.isFileExists(atPath: pkgManifestPath)
        if isexist == true {
            FileManager.removefile(atPath: pkgManifestPath)
        }
        //
        FileManager.createFile(atPath: pkgManifestPath)
        
        if let pkgPath = pkgManifestPath.toFileUrl {
            try? jsonData?.write(to: pkgPath)
        }
        
        block(true)
    }
}
