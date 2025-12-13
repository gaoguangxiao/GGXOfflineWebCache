//
//  GXWebOfflineManifestModel.swift
//  GGXOfflineWebCache
//
//  Created by 高广校 on 2024/1/24.
//

import Foundation
import GXSwiftNetwork
import SmartCodable
import GXTaskDownload
import GGXSwiftExtension

public class GXWebOfflineManifestBaseModel: MSBApiModel {
    /// 具体的数据
//    public var data: GXWebOfflineManifestModel?
    ///
    var ydata: GXWebOfflineManifestModel? {
        return GXWebOfflineManifestModel.deserialize(from: data as? Dictionary<String, Any>)
    }
}

public class GXWebOfflineManifestModel: SmartCodable {
    
    /// manifest 格式的版本号
    public var version: String?
    
    /// 要加载的页面及资源
    public var assets: Array<GXWebOfflineAssetsModel>?
    
    /// 初始化
    required public init(){}
}

extension GXWebOfflineManifestModel {
    
    public var versionSize: Double {
        let newVersion = self.version?.replace(".", new: "")
        return newVersion?.toDouble() ?? 0
    }
    
    
    //仅去重`assets`
    public var noAlikeAssets: [GXWebOfflineAssetsModel]? {
        var models: [GXWebOfflineAssetsModel] = []
        var seenSrc: Set<String> = [] // 用于记录已经处理过的 src
        
        guard let assets = self.assets else {
            return nil
        }
        LogInfo("predict total count: \(assets.count)")
        for url in assets {
            guard let src = url.src, !seenSrc.contains(src) else {
                let strMsg = "alike src: \(url.src ?? "nil"), md5 is \(url.md5 ?? "nil")"
                LogInfo(strMsg)
                continue // 如果 src 已存在于集合中，跳过
            }
            seenSrc.insert(src) // 添加当前 src 到集合中
            models.append(url)
        }
        LogInfo("actual total count: \(models.count)")
        return models
    }
    
    //扩展对assets的去重,针对src -> [GXDownloadURLModel] 可下载数据
    public func getNoAlikeAssets(priority: Int) -> [GXDownloadURLModel] {
        var models: [GXDownloadURLModel] = []
        var seenSrc: Set<String> = [] // 用于记录已经处理过的 src
        
        guard let assets = self.assets else {
            return models
        }
        LogInfo("predict total count: \(assets.count)")
        for url in assets {
            guard let src = url.src, !seenSrc.contains(src) else {
                let strMsg = "alike src: \(url.src ?? ""), md5 is \(url.md5 ?? "")"
                LogInfo(strMsg)
                continue // 如果 src 已存在于集合中，跳过
            }
            seenSrc.insert(src) // 添加当前 src 到集合中
            let downloadModel = GXDownloadURLModel()
            downloadModel.src    = src
            downloadModel.policy = url.policy
            downloadModel.md5    = url.md5
            downloadModel.match  = url.match
            downloadModel.priority = priority
            if let size = url.size {
                downloadModel.size = size.toDiskSize()
            }
            models.append(downloadModel)
        }
        LogInfo("actual total count: \(models.count)")
        return models
    }
}

//        LogInfo("predict total count: \(urls.count)")
//        var downloadUrls: Array<GXDownloadURLModel> = []
//        for url in urls {
//            if !downloadUrls.contains(where: { $0.src == url.src
//            }) {
//                let downloadModel = GXDownloadURLModel()
//                downloadModel.src    = url.src
//                downloadModel.policy = url.policy
//                downloadModel.md5    = url.md5
//                downloadModel.match  = url.match
//                downloadModel.priority = priority
//                downloadUrls.append(downloadModel)
//            } else {
//                //重复的src
//                let strMsg = "alike src: \(url.src ?? ""), md5 is \(url.md5 ?? "")"
//                LogInfo(strMsg)
//            }
//        }
//        LogInfo("actual total count: \(downloadUrls.count)")
