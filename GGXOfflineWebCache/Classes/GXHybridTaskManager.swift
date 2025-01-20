//
//  GXHybridTaskManager.swift
//  RSBridgeOfflineWeb
//
//  Created by 高广校 on 2024/1/30.
//  比对所有预置资源待更新的URL

import Foundation
import GXTaskDownload
import GGXSwiftExtension

public class GXHybridTaskManager: NSObject {
        
    public static let share = GXHybridTaskManager()
    
    private var waitingUrlTasks: Array<String> = []
    
    // 待下载的任务
    private var waitingDownloadTasks: Dictionary<String,GXDownloadManager> = [:]
    
    /// 任务总量
    private var tasksCount: Int = 0
    
    /// 已经完成的任务数量
    private var finishTasksCount: Int = 0
    
    /// 待更新的URLS
//    var canDownloadUrls: Array<GXWebOfflineAssetsModel> = []
    
    /// 待更新的配置
//    var canUpdateManifestUrls: Array<String> = []
    
    var foderPath = "preset"
    
    /// 队列
    private let executeQueue = DispatchQueue(label:"asyncBackgroundQueue",
                                             qos: .default,
                                             attributes: .concurrent,
                                             autoreleaseFrequency: .inherit,
                                             target: nil)
    /// 离线包管理类
    lazy var webOfflineCache: GXHybridCacheManager = {
        let hybridCache = GXHybridCacheManager()
        return hybridCache
    }()
    
    /// 请求预置资源路径
    /// - Parameters:
    ///   - url: <#url description#>
    ///   - priority: <#priority description#>
    public func requestForBackgroundResource(urls: Array<String>,
                                             priority: Int = 3)  {
        
        self.tasksCount = urls.count
        
        ///最大校验数
        let maxCurrentCount = 2
        
        for url in urls {
            let download = GXDownloadManager()
//            download.hyDownPath = "WebResource"
            waitingDownloadTasks[url.md5Value] = download
        }
        
        self.waitingUrlTasks.append(contentsOf: urls)

        //执行
        self.executeQueue.async {
            for _ in 0 ..< maxCurrentCount {
                self.execute()
            }
        }
    }
    
    deinit {
        print("\(self)-deinit")
    }
}

extension GXHybridTaskManager {
    
    
    func execute()  {
        
        if let url = gainTask() {
            //获取之后立马删除
            self.removeTask()
            //执行下载
            GXManifestApiService.requestManifestApi(url: url) { configModel in
                if let configModel {
                    //2、获取本地配置信息
                    if let manimodel = self.webOfflineCache.getOfflineManifestModel(url: url, extendPath: self.foderPath), manimodel.versionSize >= configModel.versionSize {
                        self.addFinishTaskCount(url: url)
                        self.checkFinish()
                        return
                    }
                    self.updatePkg(url: url, configModel: configModel)
                } 
                else {
                    self.addFinishTaskCount(url: url)
                    self.checkFinish()
                }
            }
        }
    }

    func updatePkg(url: String, configModel: GXWebOfflineManifestModel)  {
        guard let assets = configModel.assets else {
            return
        }
        
        let urls = configModel.getNoAlikeAssets(priority: 5)
        guard !urls.isEmpty else {
            return
        }
        
        let downloadManager = self.waitingDownloadTasks[url.md5Value]
        
        downloadManager?.start(forURL: urls, maxDownloadCount: 9, path: "WebResource" + "/\(self.foderPath)", block: { [weak self ] total, loaded, state in
            guard let `self` = self else {return}
            if state == .completed || state == .error {
                let manifestPath = "\(self.foderPath)" + "/" + url.lastPathComponent
                self.webOfflineCache.updatePkgManifest(maniModel: configModel, maniPath: manifestPath) { b in
                    self.addFinishTaskCount(url: url)
                    self.checkFinish()
                }
            } else {
                LogInfo("\(url)的下载进度:\(loaded/total)")
            }
        })
    }
    
    func checkFinish() {
        if self.finishTasksCount == self.tasksCount {
//            print("所有任务下载完毕")
//            print("\(self.waitingDownloadTasks)")
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
    
    func addFinishTaskCount(url: String) {
        objc_sync_enter(self)
        self.waitingDownloadTasks.removeValue(forKey: url.md5Value)
        self.finishTasksCount += 1
        objc_sync_exit(self)
    }
    
    /// 通过URL的json获取离线包ManifestModel-本地资源目录
    /// - Parameter url: url description
    /// - Returns: description
    func getSandboxPkgModel(url: String, extendPath: String) -> GXWebOfflineManifestModel? {
        if let manifestPath = self.webOfflineCache.getOfflineLastPathComponent(url,extendPath: extendPath),
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
}
