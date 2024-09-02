//
//  GXHybridPresetManager.swift
//  RSBridgeOfflineWeb
//
//  Created by 高广校 on 2024/1/30.
//

import Foundation
import GXTaskDownload
import GGXSwiftExtension

/// 预置文件代理
public protocol GXHybridPresetManagerDelegate: NSObjectProtocol {
    /// 开始比对文件
    func offlineWebComparison()
    
    /// 下载进度
    func offlineWebProgress(progress: Float)
    
    /// 下载进度和速度
    func offlineWebSpeed(speed: Double)
    
    /// 加载完毕
    func offlineWeb(completedWithError error: Error?)
    
}


public class GXHybridPresetManager: NSObject {
    
    public weak var delegate: GXHybridPresetManagerDelegate?
    
    ///web资源比对
    lazy var webPkgCheckManager: GXHybridCheckManager = {
        let offline = GXHybridCheckManager()
        offline.delegate = self
        return offline
    }()
    
    /// 离线下载
    lazy var oflineDownload: GXDownloadManager = {
        let download = GXDownloadManager()
        download.isOpenDownloadSpeed = true
        download.downloadSpeedBlock = { [weak self] speed in
            guard let self else { return }
            delegate?.offlineWebSpeed(speed: speed)
        }
        return download
    }()
    
    /// 离线包管理类
    lazy var webOfflineCache: GXHybridCacheManager = {
        let hybridCache = GXHybridCacheManager()
        return hybridCache
    }()
    
    /// 配置文件保存
    /// - Parameters:
    ///   - url: <#url description#>
    ///   - priority: <#priority description#>
    public func requestRemotePresetResources(jsonPath urls: Array<String>,
                                             priority: Int = 3)  {
        //请求网络对比文件
        webPkgCheckManager.requestRemotePresetResources(jsonPath: urls,priority: priority)
    }
    
    
    /// 下载预置文件
    /// - Parameters:
    ///   - priority: <#priority description#>
    ///   - assets: <#assets description#>
    ///   - block: <#block description#>
    func downloadPreset(assets: Array<GXWebOfflineAssetsModel>, manifestUrls: Array<String>)  {

        var downloadUrls: Array<GXDownloadURLModel> = []
        for url in assets {
            let downloadModel = GXDownloadURLModel()
            downloadModel.src    = url.src
            downloadModel.policy = url.policy
            downloadModel.md5    = url.md5
            downloadModel.match  = url.match
            //            downloadModel.priority = priority
            downloadUrls.append(downloadModel)
        }
        self.oflineDownload.start(forURL: downloadUrls, path: "WebResource") { [weak self] total, loaded, state in
            guard let self else { return }
            if state == .completed || state == .error {
               updatePresetManifest(manifestUrls: manifestUrls)
            } else {
               delegate?.offlineWebProgress(progress: loaded/total)
            }
        }
        
    }
    
    func updatePresetManifest(manifestUrls: Array<String>) {
        //保存预置
        self.webOfflineCache.updateCurrentManifest(manifestJSONs: manifestUrls) {  [weak self] b in
            
            guard let `self` = self else { return }
            
            self.delegate?.offlineWeb(completedWithError: nil)
        }
    }
    
    deinit {
        LogInfo("\(self)-deinit")
    }
}

extension GXHybridPresetManager: GXHybridCheckManagerDelegate {
    
    public func checkStart() {
        self.delegate?.offlineWebComparison()
    }
    
    public func finishCheck(urls: Array<GGXOfflineWebCache.GXWebOfflineAssetsModel>, manifestUrls: Array<String>) {
        if urls.count == 0 {
            self.delegate?.offlineWeb(completedWithError: nil)
        } else {
            self.downloadPreset(assets: urls, manifestUrls: manifestUrls)
        }
    }
    
}
