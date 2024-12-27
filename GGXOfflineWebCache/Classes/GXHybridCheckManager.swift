//
//  GXHybridCheckManager.swift
//  RSBridgeOfflineWeb
//
//  Created by 高广校 on 2024/1/30.
//  比对所有预置资源待更新的URL

import Foundation
import GXTaskDownload
import GGXSwiftExtension

public protocol GXHybridCheckManagerDelegate: NSObject {
    
    /// 开始比对文件
    func checkStart()
    
    /// 校验完毕
    func finishCheck(urls: Array<GXWebOfflineAssetsModel>, manifestUrls: Array<String>)
}


public class GXHybridCheckManager: NSObject {
    
    public weak var delegate: GXHybridCheckManagerDelegate?
    
    private var waitingUrlTasks: Array<String> = []
    
    /// 任务总量
    private var tasksCount: Int = 0
    
    /// 已经完成的任务数量
    private var finishTasksCount: Int = 0
    
    /// 待更新的URLS
    var canDownloadUrls: Array<GXWebOfflineAssetsModel> = []
    
    /// 待更新的配置
    var canUpdateManifestUrls: Array<String> = []
    
    /// 队列
    private let executeQueue = DispatchQueue(label:"asyncCheclQueue",
                                             qos: .default,
                                             attributes: .concurrent,
                                             autoreleaseFrequency: .inherit,
                                             target: nil)
    /// 请求预置资源路径
    /// - Parameters:
    ///   - url: <#url description#>
    ///   - priority: <#priority description#>
    public func requestRemotePresetResources(jsonPath urls: Array<String>,
                                             priority: Int = 3)  {
        //请求网络对比文件
        self.delegate?.checkStart()
        
        //
        self.tasksCount = urls.count
        
        ///最大校验数
        let maxCurrentCount = 1
        
        self.waitingUrlTasks.append(contentsOf: urls)
        
        //执行
        self.executeQueue.async {
            for _ in 0 ..< maxCurrentCount {
                self.execute()
            }
        }
    }
    
    /// 通过URL的json获取离线包 ManifestModel-本地资源目录
    /// - Parameter url: <#url description#>
    /// - Returns: <#description#>
    func getSandboxPresetModel(url: String) -> GXWebOfflineManifestModel? {
        if let localPresetConfigPath = GXHybridCacheManager.share.getOfflineManifestPath(url:url) ,
           let localPresetConfigData = localPresetConfigPath.toFileUrl?.filejsonData{
            guard let localJsonDict = localPresetConfigData as? Dictionary<String, Any> else {
                print("JSON格式有问题")
                return nil
            }
            return GXWebOfflineManifestModel.deserialize(from: localJsonDict)
        }
        return nil
    }
    
    deinit {
        LogInfo("\(self)-deinit")
    }
}

extension GXHybridCheckManager {
    
    
    func execute()  {
        
        if let url = gainTask() {
            //获取之后立马删除
            self.removeTask()
//            LogInfo("任务校验：\(url)-:\(Thread.current)")
            if self.getSandboxPresetModel(url: url) != nil {
                LogInfo("\(url)无需更新")
                self.addFinishTaskCount()
                self.checkFinish()
            } else {
                GXManifestApiService.requestManifestJSON(url: url) { [weak self] configModel in
                    guard let self else {
                        //解决类释放
                        self?.addFinishTaskCount()
                        self?.checkFinish()
                        return
                    }
                    if let configModel , let assets = configModel.noAlikeAssets {
                        for asset in assets {
                            if let urlPath = asset.src {
                                let diskFile = GXTaskDiskFile()
                                let folderPath =                            GXHybridCacheManager.share.resourceCachePath + (urlPath.toPath.stringByDeletingLastPathComponent)
                                /// 下载的URL信息
                                if let remoteModel = GXDownloadURLModel.deserialize(from: asset.toDictionary()) {
                                    diskFile.remoteDownloadURLModel = remoteModel
                                }
                                diskFile.taskDownloadPath = folderPath
                                let isExist = diskFile.isExistDiskAndMD5Update(url: urlPath)
                                if isExist == false{
                                    canDownloadUrls.append(asset)
                                }
                            }
                        }
                        canUpdateManifestUrls.append(url)
                        addFinishTaskCount()
                        checkFinish()
                    }
                    else {
                        addFinishTaskCount()
                        checkFinish()
                        //                    self.delegate?.finishCheck(urls: canDownloadUrls, manifestUrls: canUpdateManifestUrls)
                    }
                }
            }
        } else {
            if self.finishTasksCount == self.tasksCount {
                //                print("没有任务可供校验")
                self.delegate?.finishCheck(urls: canDownloadUrls, manifestUrls: canUpdateManifestUrls)
            }
        }
    }
    
    func checkFinish() {
        if self.finishTasksCount == self.tasksCount {
            self.delegate?.finishCheck(urls: canDownloadUrls, manifestUrls: canUpdateManifestUrls)
        } else {
            self.execute()
        }
    }
    
    /// 获取可执行的第一个任务
    /// - Returns: <#description#>
    func gainTask() -> String? {
        guard self.waitingUrlTasks.count != 0 else {
            return nil
        }
        let downloader = waitingUrlTasks.first
        return downloader
    }
    
    /// 移除任务
    func removeTask() {
        guard self.waitingUrlTasks.count != 0 else {
            return
        }
        objc_sync_enter(self)
        self.waitingUrlTasks.removeFirst()
        objc_sync_exit(self)
    }
    
    func addFinishTaskCount() {
        objc_sync_enter(self)
        self.finishTasksCount += 1
        objc_sync_exit(self)
    }
}
