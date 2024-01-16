//
//  GXCheckTaskManager.swift
//  GXTaskDownload
//
//  Created by 高广校 on 2024/1/11.
//  获取多个URL文件大小

import Foundation

public class GXCheckTaskManager: NSObject {
    
    /// 当前校验数量 默认0
    var currentcheckCount: Float = 0.0
    
    /// 线程队列
    lazy var operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 10
        return queue
    }()
    
    public func checkUrls(urls: Array<String>, complete:@escaping GXTaskCheckProgressBlock) {
        
        var totalCount: Int64 = 0
        
        for url in urls {
            //            Operation
            let blockOpration = BlockOperation {
                if let uurl = url.toUrl {
                    let check = GXCheckTaskSize()
                    check.checkUrlTask(url: uurl) { fileSize in
                        objc_sync_enter(self)
//                        print("文件大小：\(fileSize)")
                        totalCount+=fileSize
                        self.currentcheckCount+=1
//                        print("校验文件条数/总条数:\(self.currentcheckCount)/\(urls.count)")
                        let progress = self.currentcheckCount/Float(urls.count)
                        complete(progress, totalCount)
//                        if self.currentcheckCount == urls.count {
//                            print("校验完毕:")
//                            complete(totalCount)
//                        }
                        objc_sync_exit(self)
                    }
                }
            }
            self.operationQueue.addOperation(blockOpration)
            //输入
        }
        
    }
}
