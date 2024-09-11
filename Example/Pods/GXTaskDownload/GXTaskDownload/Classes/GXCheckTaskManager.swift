//
//  GXCheckTaskManager.swift
//  GXTaskDownload
//
//  Created by 高广校 on 2024/1/11.
//  获取多个URL文件大小

import Foundation
import GGXSwiftExtension

public class GXCheckTaskManager: NSObject {
    
    /// 当前校验数量 默认0
    var currentcheckCount: Int = 0
    
    //任务校验
    var checkDownloadDict: Dictionary<String, GXCheckTaskSize> = [:]
    
    /// 线程队列
    lazy var operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 10
        return queue
    }()
    
    public func checkUrls(urls: Array<GXDownloadURLModel>, complete:@escaping GXTaskCheckProgressBlock) {
        
        var totalCount: Int64 = 0
        
        for url in urls {
            //            Operation
//            let blockOpration = BlockOperation {
                if let uurl = url.src?.toUrl {
                    let check = GXCheckTaskSize()
                    self.checkDownloadDict[uurl.absoluteString.md5Value] = check
                    check.checkUrlTask(url: uurl) { fileSize in
                        objc_sync_enter(self)
//                        print("文件大小：\(fileSize)")
                        totalCount += fileSize
                        self.currentcheckCount += 1
                        LogInfo("校验文件条数/总条数:\(self.currentcheckCount)/\(urls.count)")
                        let progress = Float(self.currentcheckCount)/Float(urls.count)
                        complete(progress, totalCount)
                        if self.currentcheckCount == urls.count {
                            LogInfo("校验完毕:")
                            self.checkDownloadDict.removeAll()
                            complete(progress, totalCount)
                        }
                        objc_sync_exit(self)
                    }
                    
                }
//            }
//            self.operationQueue.addOperation(blockOpration)
            //输入
        }
        
    }
}
