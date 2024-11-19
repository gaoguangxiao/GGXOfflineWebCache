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
    
    /// 开始下载离线资源的数量，仅有离线包更新时才具备
    func offlineWebStartDownload(urls: Array<GXWebOfflineAssetsModel>)
    
    /// 下载进度
    func offlineWebProgress(progress: Float)
    
    /// 下载速度，下载量
    func offlineWebSpeed(speed: Double, loaded: Double, total: Double)
    
    /// 加载完毕
    func offlineWeb(completedWithError error: Error?)
    
    //离线包加载完毕
    //error：错误
    //isUpdateOffline 本地资源是否更新
    func offlineWeb(completedWithError error: Error?, isUpdateOffline: Bool)
}

public extension GXHybridPresetManagerDelegate {
    
    func offlineWebStartDownload(urls: Array<GXWebOfflineAssetsModel>) {
        
    }
    
    func offlineWeb(completedWithError error: Error?, isUpdateOffline: Bool){
        
    }
}

public class GXHybridPresetManager: NSObject {
    
    public weak var delegate: GXHybridPresetManagerDelegate?
    
    // The maximum number of downloads in downloadable groups in a resource package is preset，defaul：9
    public var maxDownloadCount: Int = 9
    
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
        download.downloadSpeedBlock = { [weak self] speed ,loaded,total in
            guard let self else { return }
            delegate?.offlineWebSpeed(speed: speed,loaded: loaded,total: total)
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
        for urlAssets in assets {
            if let url = urlAssets.src,
                url.contains("http") {
                let downloadModel = GXDownloadURLModel()
                downloadModel.src    = urlAssets.src
                downloadModel.policy = urlAssets.policy
                downloadModel.md5    = urlAssets.md5
                downloadModel.match  = urlAssets.match
                if let size = urlAssets.size {
                    downloadModel.size = size.toDiskSize()
                }
                downloadUrls.append(downloadModel)
            } else {
                //LogInfo("\(urlAssets.src ?? "") not contains http")
            }
        }
        self.oflineDownload.start(forURL: downloadUrls, 
                                  maxDownloadCount: maxDownloadCount,
                                  path: "WebResource") { [weak self] total, loaded, state in
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
            
            delegate?.offlineWeb(completedWithError: nil, isUpdateOffline: true)
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
            delegate?.offlineWeb(completedWithError: nil, isUpdateOffline: false)
        } else {
            self.downloadPreset(assets: urls, manifestUrls: manifestUrls)
        }
        delegate?.offlineWebStartDownload(urls: urls)
    }
    
}
