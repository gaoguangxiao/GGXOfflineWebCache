//
//  ViewController.swift
//  GGXOfflineWebCache
//
//  Created by 小修 on 01/03/2024.
//  Copyright (c) 2024 小修. All rights reserved.
//  离线包的下载和设置版本

import UIKit
import GGXOfflineWebCache

class ViewController: UIViewController, GXHybridZipManagerDelegate {
    
    func offlineUnZipipWebProgress(progress: Float) {
        
    }
    
    func offlineUnzip(completedWithError: Bool) {
    
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        //1、配置本地资源包 将本地资源包 放于沙盒内部
//        let zip = GXHybridZipManager()
//        zip.unzipDelegate = self
//        zip.unzipProjecToBox(zipName: "dist.zip") { b in
//            
//        }
// 
        //2、
//      资源包版本和资源包 下载路径
//        GXHybridCacheManager.share.initLocalWebResource(name: "WebPreset",
//                                                 type: "zip",
//                                                 version: version) { b in
//            print("离线包配置:\(b ? "成功" : "失败")")
//            //加载离线配置
////            GXHybridCache.share.loadPresetConfig()
//        }
        
        ///下载json里面所有资源，并返回进度
//        let hyDownload = GXHybridDownload()
//        hyDownload.download(urls: [], path: "pkg") { total, loaded, state in
//            
//        }
        
//        let hyDownload = GXHybridCacheManager()
        
//        hyDownload.getSandboxManifestModel(url: "http://localhost:8081/manifest/manifest-initial.json")
        
//        "https://test.audio.risekid.cn/web/adventure/7.2ae2f613.async.js".removeMD5
//        hyDownload.removeFileWith(URL: "https://test.audio.risekid.cn/web/adventure/7.2ae2f613.async.js")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

