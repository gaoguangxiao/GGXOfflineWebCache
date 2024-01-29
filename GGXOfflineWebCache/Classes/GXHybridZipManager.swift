//
//  GXHybridZipManager.swift
//  RSBridgeOfflineWeb
//
//  Created by 高广校 on 2024/1/25.
//

import Foundation
import GGXSwiftExtension

public protocol GXHybridZipManagerDelegate: NSObjectProtocol {
    /// 解压进度
    func offlineUnZipipWebProgress(progress: Float)
    
    /// 解压完成
    func offlineUnzip(completedWithError: Bool)
}

public class GXHybridZipManager: NSObject {
    
    /// 代理
    public weak var unzipDelegate: GXHybridZipManagerDelegate?
    
    /// 离线包管理类
    lazy var webOfflineCache: GXHybridCacheManager = {
        let hybridCache = GXHybridCacheManager()
        hybridCache.presetName = "dist"
        return hybridCache
    }()
    
    /// 加载本地工程离线资源
    public func unzipProjecToBox(zipName: String,block: @escaping ((_ isSuccess: Bool) -> Void)) {
        
        guard let path = Bundle.main.path(forResource: zipName, ofType: nil) else {
            print("本地不存在离线资源:\(zipName)")
            block(true)//不存在，略过解压
            return
        }
        
        //保存版本号-记录是否解压至特定目录
        let appVersion = kAppVersion ?? ""
        if let presetVersion = UserDefaults.presetDataNameKey {
            guard presetVersion != appVersion else {
                //解压成功
                DispatchQueue.main.async {
                    self.unzipDelegate?.offlineUnzip(completedWithError: true)
                }
                return
            }
        }
        
        //开启线程
        DispatchQueue.global().async {
            self.webOfflineCache.moveOfflineWebZip(path: path,
                                                   unzipName: path.lastPathComponent.stringByDeletingPathExtension) { progress, isSuccess in
                //print("解压进度:\(progress)")
                DispatchQueue.main.async {
                    self.unzipDelegate?.offlineUnZipipWebProgress(progress: progress)
                }
                
                if isSuccess {
                    UserDefaults.presetDataNameKey = appVersion
                    DispatchQueue.main.async {
                        self.unzipDelegate?.offlineUnzip(completedWithError: true)
                    }
                }
                block(isSuccess)
            }
        }
    }
    
    deinit {
        LogInfo("\(self)-deinit")
    }
}
