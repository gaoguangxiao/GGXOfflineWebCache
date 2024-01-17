//
//  ViewController.swift
//  GGXOfflineWebCache
//
//  Created by 小修 on 01/03/2024.
//  Copyright (c) 2024 小修. All rights reserved.
//  离线包的下载和设置版本

import UIKit
import GGXOfflineWebCache

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //1、配置本地资源包 将本地资源包 放于沙盒内部
        
        //1、读取最新离线包配置和离线包资源【本地或者网络获取】
//        let version = "0.1.1"
        //从本地获取
//        let mainFestData = Bundle.jsonfileTojson("manifest-code")
        
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
//        hyDownload.downloadUrls(urls: <#T##Array<String>#>, path: <#T##String#>)
        
        let hyDownload = GXHybridCacheManager()
        
//        hyDownload.getSandboxManifestModel(url: "http://localhost:8081/manifest/manifest-initial.json")
        
//        "https://test.audio.risekid.cn/web/adventure/7.2ae2f613.async.js".removeMD5
//        hyDownload.removeFileWith(URL: "https://test.audio.risekid.cn/web/adventure/7.2ae2f613.async.js")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

