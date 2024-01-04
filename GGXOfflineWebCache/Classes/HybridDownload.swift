//
//  HybridDownload.swift
//  RSBridgeNetCache
//
//  Created by 高广校 on 2024/1/2.
//

import Foundation
import GXTaskDownload

class HybridDownload: NSObject {
    
    lazy var downloader: GXTaskDownloadDisk = {
        let task = GXTaskDownloadDisk()
        print("task.diskFile.downloadPath:\(task.diskFile.downloadPath)")
        return task
    }()
    
    //下载指定的URLs
    func downloadUrls(urls: String) {
        
    }
    
    func downloadUrl(url: String) {
        //开始下载
        downloader.start(forURL: url) { progress, state in

            switch state {
            case .completed:

                print("文件下载完毕")
                DispatchQueue.main.async {
                    //                    self.downloadBtn.isSelected = false
                    //                    self.下载状态.text = "已下载"
                }

            case .started:

                print("准备下载")
                DispatchQueue.main.async {
                    //                    self.下载状态.text = "下载中"
                }
                //                sender.isSelected = !sender.isSelected

            case .paused:
                print("paused")
            case .notStarted:
                print("notStarted")
            case .stopped:
                print("stopped")
            case .downloading:
                DispatchQueue.main.async {
                    //                    self.downloadPro.text = "下载进度:\(progress)"
                    //                    self.progress.progress = progress
                }
            }
        }
    }
}
