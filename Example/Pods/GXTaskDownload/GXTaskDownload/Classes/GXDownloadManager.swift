//
//  GXDownloadManager.swift
//  GXTaskDownload
//
//  Created by 高广校 on 2024/1/11.
//

import Foundation
import GGXSwiftExtension

public class GXDownloadManager: NSObject {
    /// URLS总数量
    private var tasksCount: Float = 0
    
    private let executeQueue = DispatchQueue(label:"asyncQueue",
                                             qos: .default,
                                             attributes: .concurrent,
                                             autoreleaseFrequency: .inherit,
                                             target: nil)
    
    /// 最大下载数
    public var maxConcurrentCount = 9
    
    /// 等待的任务
    private var waitingTasks: Array<GXTaskDownloadDisk> = []
        
    private var downloadTotalBlock: GXTaskDownloadTotalBlock?
    
    var isFinish = false
    
    func progressCallBack() {
//        print("等待任务数量:\(waitTaskcount)")
        let downCounted = self.tasksCount - Float(waitTaskcount)
//        print("进度:\(progress)")
        objc_sync_enter(self)
        if let pro = self.downloadTotalBlock {
            pro(self.tasksCount,downCounted,.downloading)
        }
        objc_sync_exit(self)
        //        回调进度还需要优化--
        //        objc_sync_enter(self)
        //        if let pro = self.downloadBlock {
        //            pro(progress, .downloading)
        //        }
        //        objc_sync_exit(self)
    }
    
    func stateCallBack(state: GXDownloadingState) {
//        print("等待任务数量:\(waitTaskcount)")
        let downCounted = self.tasksCount - Float(waitTaskcount)
//        print("进度:\(progress)")
        objc_sync_enter(self)
//        if let pro = self.downloadBlock {
//            pro(progress, state)
//        }
        if let pro = self.downloadTotalBlock {
            pro(self.tasksCount,downCounted,state)
        }
        objc_sync_exit(self)
    }
    
    deinit {
//        print("\(self)-deinit")
    }
}

//MARK: 调度任务
extension GXDownloadManager {
    
    /// 多线程下载任务数判断，每个任务下载完毕都会校验任务数
    /// 加锁处理
    /// - Returns: 当前未执行的任务数量
    var waitTaskcount: Int {
        var taskCount = 0
        objc_sync_enter(self)
        taskCount = self.waitingTasks.count
        objc_sync_exit(self)
        return taskCount
    }
    
    func enqueue(urlModel: GXDownloadURLModel, path: String) {
        /// 创建一个任务
        let downloader = GXTaskDownloadDisk()
        downloader.diskFile.taskDownloadPath = path + (urlModel.src?.toPath.stringByDeletingLastPathComponent ?? "")
        downloader.prepare(urlModel: urlModel)
        waitingTasks.append(downloader)
    }
    
    func execute()  {
        let downloader = gainTask()
        downloader?.start(block: { [weak self] progress, state in
            guard let `self` = self else { return }
            //单个文件的下载完成，抛出进度
            if state == .completed || state == .error {
                self.removeTask()
                //判断是否存在未执行的任务
                if self.waitTaskcount == 0 {
                    print("没有任务可供下载")
                    if !self.isFinish { //仅回调一次
                        self.isFinish = true
                        
                        self.stateCallBack(state: .completed)
                    }
                } else {
                    self.execute()
                    //进度回调
                    self.stateCallBack(state: .downloading)
                }
            }
        })
    }
    
    
    /// 获取可执行的第一个任务
    /// - Returns: <#description#>
    func gainTask() -> GXTaskDownloadDisk? {
        let downloader = waitingTasks.first
        return downloader
    }
    
    /// 移除任务
    func removeTask() {
        guard self.waitingTasks.count != 0 else {
            return
        }
        objc_sync_enter(self)
        self.waitingTasks.removeFirst()
        objc_sync_exit(self)
    }
}

//MARK: 下载一组URL
extension GXDownloadManager {
    
    /// 下载一组URLS
    /// - Parameters:
    ///   - urls: urls description
    ///   - path: <#path description#>
    ///   - block: <#block description#>
    public func start(forURL urls: Array<GXDownloadURLModel>, 
                      maxDownloadCount: Int = 9,
                      path: String, 
                      block: @escaping GXTaskDownloadTotalBlock) {
    
        self.maxConcurrentCount = maxDownloadCount
        self.downloadTotalBlock = block
        LogInfo("开始下载")
        
        //入队
        for url in urls {
            self.enqueue(urlModel: url, path: path)
        }
        
        tasksCount = Float(urls.count)
        
        //执行
        self.executeQueue.async {
            for _ in 0 ..< self.maxConcurrentCount {
                //                print("下载次数：\(1)")
                self.execute()
            }
        }
    }
}
