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
        
    /// 配置开始
    func configWebStart()
    
    /// 配置文件进度
    func offlineConfigWebProgress(progress: Float)
    
    /// 解压以及配置完成
    func offlineUnzip(completedWithError: Bool)
}

public class GXHybridZipManager: NSObject {
    
    /// 代理
    public weak var unzipDelegate: GXHybridZipManagerDelegate?
    
    /// 预置压缩包名称
    public var presetZipName: String = "dist"
    
    /// src配置服务器路径
    public var webFolderName: String = "web/adventure"
    
    /// 离线包管理类
    lazy var webOfflineCache: GXHybridCacheManager = {
        let hybridCache = GXHybridCacheManager()
        hybridCache.presetName = presetZipName
        hybridCache.webFolderName = webFolderName
        hybridCache.delegate = self
        return hybridCache
    }()
    
    /// 加载本地工程离线资源
    public func unzipProjecToBox(zipName: String,block: @escaping ((_ isSuccess: Bool) -> Void)) {
        
        guard let path = Bundle.main.path(forResource: zipName, ofType: nil) else {
            print("本地不存在离线资源:\(zipName)")
            block(true)//不存在，略过解压-跳过
            self.unzipDelegate?.offlineUnzip(completedWithError: true)
            return
        }
        
//        保存版本号-记录是否解压至特定目录
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
                                                   unzipName: path.lastPathComponent.stringByDeletingPathExtension) { [weak self ]progress, isSuccess,isMoveSuccess in
                guard let `self` = self else { return }
                //print("解压进度:\(progress)")
                if !isSuccess {
                    DispatchQueue.main.async {
                        self.unzipDelegate?.offlineUnZipipWebProgress(progress: progress)
                    }
                }
                ///
                if isSuccess, isMoveSuccess {
//                    UserDefaults.presetDataNameKey = appVersion
//                    DispatchQueue.main.async {
//                        self.unzipDelegate?.offlineUnzip(completedWithError: true)
//                    }
                    block(isSuccess)
                } else {
                    if isSuccess , !isMoveSuccess{
                        DispatchQueue.main.async {
                            self.unzipDelegate?.offlineConfigWebProgress(progress: progress)
                        }
                    }
                }
            }
        }
    }
    
    deinit {
        LogInfo("\(self)-deinit")
    }
}

extension GXHybridZipManager: GXHybridCacheManagerDelegate {
    public func unzipFinish() {
        
    }
    
    public func configStart() {
        DispatchQueue.main.async {
            self.unzipDelegate?.configWebStart()
        }
    }
    
    public func configFinish() {
        let appVersion = kAppVersion ?? ""
        UserDefaults.presetDataNameKey = appVersion
        DispatchQueue.main.async {
            self.unzipDelegate?.offlineUnzip(completedWithError: true)
        }
    }
    
    
}
