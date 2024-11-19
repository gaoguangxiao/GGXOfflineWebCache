//
//  ViewController.swift
//  GGXOfflineWebCache
//
//  Created by 小修 on 01/03/2024.
//  Copyright (c) 2024 小修. All rights reserved.
//  离线包的下载和设置版本

import UIKit
import GGXOfflineWebCache
import ZKBaseSwiftProject

class ViewController: ZKBaseWKWebViewController{
    
    /// web解压类
    lazy var webOfflineUnzip: GXHybridZipManager = {
        let webOffline = GXHybridZipManager()
        webOffline.unzipDelegate = self
        webOffline.webFolderName = "web/app"
        return webOffline
    }()
    
    /// web资源下载
    lazy var hybridPresetManager: GXHybridPresetManager = {
        let offline = GXHybridPresetManager()
        offline.delegate = self
        return offline
    }()
    
    open override var schemeHandler: Any? {
        get {
            return RSURLSchemeHander.share
        }
        set{}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        设置离线包开关
//        RSURLSchemeHander.share.enable_cache = true
        
        webOfflineUnzip.unzipProjecToBox(zipName: "dist.zip") { isSuccess in
            
        }
    }

    func finishUnzip() {
        //业务服务器拉取匹配的.json。其中数据格式要和dist中mainfest中一致。
        self.hybridPresetManager.requestRemotePresetResources(jsonPath: ["https://test.audio.risekid.cn/web/app/manifest/manifest-initial.ad1eb7fa.json"])
    }
    
    func enterWeb() {
        self.urlString = "https://app.risekid.cn"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: GXHybridZipManagerDelegate {
    func offlineUnZipipWebProgress(progress: Float) {
        print("离线包解压进度：\(progress)")
    }
    
    func configWebStart() {
        
    }
    
    func offlineConfigWebProgress(progress: Float) {
        print("离线包配置移动进度：\(progress)")
    }
    
    func offlineUnzip(completedWithError: Bool) {
        print("离线包解压完毕")
        
        //离线版本检测
        self.finishUnzip()
    }
}

extension ViewController: GXHybridPresetManagerDelegate {
    
    func offlineWebComparison() {
        print("开始请求下载文件")
    }
    
    func offlineWebProgress(progress: Float) {
        print("下载文件:\(progress)")
    }
    
    func offlineWebSpeed(speed: Double, loaded: Double, total: Double) {
        print("下载文件:\(loaded/total)，速度：\(speed)")
    }
    
    func offlineWeb(completedWithError error: (any Error)?) {
        print("下载完毕")
        
        //进入web
        self.enterWeb()
    }
}
