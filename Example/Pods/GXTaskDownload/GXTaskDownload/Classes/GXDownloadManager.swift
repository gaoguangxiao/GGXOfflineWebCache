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
    
    /// 已经完成的任务数量
    private var finishTasksCount: Float = 0
    
    private let executeQueue = DispatchQueue(label:"asyncQueue",
                                             qos: .default,
                                             attributes: .concurrent,
                                             autoreleaseFrequency: .inherit,
                                             target: nil)
    
    /// 最大下载数
    public var maxConcurrentCount = 9
    
    /// 需要下载的任务
    private var waitingUrlsTasks: Array<GXTaskDownloadDisk> = []
    
    /// 等待下载的任务
    private var waitingTasks: Array<GXTaskDownloadDisk> = []
    
    /// 正在下载的任务
    private var downloadingTasks: Array<GXTaskDownloadDisk> = []
        
    private var downloadTotalBlock: GXTaskDownloadTotalBlock?
        

    func stateCallBack(state: GXDownloadingState) {
//        print("等待任务数量:\(waitTaskcount)")
        let downCounted = self.finishTasksCount
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
    
    
    /// 以URL后缀存储某个文件，不拼接url的路径
    /// - Parameters:
    ///   - urlModel: <#urlModel description#>
    ///   - path: <#path description#>
    func enqueueByPath(path: String, urlModel: GXDownloadURLModel) {
        /// 创建一个任务
        let downloader = GXTaskDownloadDisk()
        //下载新配置 获取URL可匹配
        if let url = urlModel.src {
            let folderName = url.lastPathComponent.removeMD5.stringByDeletingPathExtension
            downloader.diskFile.taskDownloadPath = path.stringByAppendingPathComponent(path: folderName)
        } else {
            downloader.diskFile.taskDownloadPath = path
        }
        downloader.prepare(urlModel: urlModel)
        waitingTasks.append(downloader)
    }
    
    func execute() {
        if let downloader = gainTask() {
            self.removeTask()
            self.addDownloadTask(task: downloader)
            downloader.start(block: { [weak self] progress, state in
//                LogInfo("weakself开始下载")
                guard let `self` = self else { return }
                //单个文件的下载完成，抛出进度
                if state == .completed || state == .error {
                    self.removeDownloadTask(task: downloader)
                    self.addFinishTaskCount()                    
                }
            })
        }
    }
    
    
    /// 获取可执行的第一个任务
    /// - Returns: <#description#>
    func gainTask() -> GXTaskDownloadDisk? {
        guard self.waitingTasks.count != 0 else {
            return nil
        }
        let downloader = waitingTasks.first
        return downloader
    }

    func addFinishTaskCount() {
        objc_sync_enter(self)
        self.finishTasksCount += 1
        //判断是否存在未执行的任务
//        print("完成任务数量:\(self.finishTasksCount)")
//        print("总任务数量:\(self.tasksCount)")
//        print("等待任务数量:\(self.waitTaskcount)")
//        print("正在下载任务数量:\(self.downloadingTasks.count)")
//        
        if self.finishTasksCount == self.tasksCount {
            self.stateCallBack(state: .completed)
        } else {
            self.execute()
            //进度回调
            self.stateCallBack(state: .downloading)
        }
        objc_sync_exit(self)
    }
    
    /// 移除任务
    func removeTask() {
        objc_sync_enter(self)
        guard self.waitingTasks.count != 0 else {
            return
        }
        self.waitingTasks.removeFirst()
        objc_sync_exit(self)
    }
    
    /// 添加正在下载的任务
    /// - Returns: description
    func addDownloadTask(task: GXTaskDownloadDisk) {
        objc_sync_enter(self)
        self.downloadingTasks.append(task)
        objc_sync_exit(self)
        
    }
    
    /// 移除正在下载的任务
    func removeDownloadTask(task: GXTaskDownloadDisk) {
        guard self.downloadingTasks.count != 0 else {
            return
        }
        objc_sync_enter(self)
        self.downloadingTasks.removeAll { _task in
            return _task == task
        }
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
    
    /// 下载一组URLS
    /// - Parameters:
    ///   - urls: urls description
    ///   - path: <#path description#>
    ///   - block: <#block description#>
    public func startByURL(forURL urls: Array<GXDownloadURLModel>,
                      maxDownloadCount: Int = 9,
                      path: String,
                      block: @escaping GXTaskDownloadTotalBlock) {
    
        self.maxConcurrentCount = maxDownloadCount
        self.downloadTotalBlock = block
        LogInfo("startByURL开始下载")
        
        //入队
        for url in urls {
            enqueueByPath(path: path, urlModel: url)
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
