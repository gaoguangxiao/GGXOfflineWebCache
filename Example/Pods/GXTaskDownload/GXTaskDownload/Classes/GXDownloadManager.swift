//
//  GXDownloadManager.swift
//  GXTaskDownload
//
//  Created by 高广校 on 2024/1/11.
//

import Foundation
import GGXSwiftExtension

@objcMembers
public class GXDownloadManager: NSObject {
    /// URLS总数量
    private var tasksCount: Double = 0
    
    /// 已经完成的任务数量
    private var finishTasksCount: Double = 0
    
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
        
    // 下载进度
    private var downloadTotalBlock: GXTaskDownloadTotalBlock?
    // 下载进度+速度
//    private var downloadProgressAndSpeedBlock: GXTaskDownloadProgressAndSpeedBlock?
    
    // Whether to enable the download speed
    public var isOpenDownloadSpeed = false
    
    /// File size update interval
    public var speedUpdateIntervalTime = 1.0
    
    // 下载速度
    public var downloadSpeedBlock: GXTaskDownloadSpeedBlock?
    
    // 定时读取文件下载速度
    private var speedTime: Timer?
    
    //文件总大小
    private var fileTotalLength: Double = 0
    //已下载
    private var finishBytesReceived: Double = 0
    
    /// 上次接受的大小
    private var totalBytesReceived: Double = 0
        
    /// 单文件下载
    let oneTaskDownload = GXTaskDownloadDisk()
    
    /// 多文件校验
    lazy var checkTask: GXCheckTaskManager = {
        let ctM = GXCheckTaskManager()
        return ctM
    }()
    
    func stateCallBack(state: GXDownloadingState) {
//        print("等待任务数量:\(waitTaskcount)")
        let downCounted = self.finishTasksCount
//        print("进度:\(progress)")
        objc_sync_enter(self)
        if let pro = self.downloadTotalBlock {
            pro(self.tasksCount,downCounted,state)
        }
        objc_sync_exit(self)
    }
    
    deinit {
        LogInfo("\(self)-deinit")
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
        downloader.downloader.estimatedTotalBytesCount = urlModel.size
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
        if self.finishTasksCount == self.tasksCount {
            //最后一个下载完毕时，进行`finishBytesReceived`完毕回调，否则已下载大小会小于`fileTotalLength`
            let speed = Double(finishBytesReceived - totalBytesReceived)/Double(speedUpdateIntervalTime)
            if let proSpeed = self.downloadSpeedBlock {
                proSpeed(speed,finishBytesReceived,fileTotalLength,tasksCount)
            }
            self.stateCallBack(state: .completed)
            self.destroySpeedTime()
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
        //已下载文件的下载量和预估下载量
        finishBytesReceived += bytesReceivedByDownloaderFinish(task.downloader)
        self.downloadingTasks.removeAll { _task in
            return _task == task
        }
        objc_sync_exit(self)
    }
    
    
    func initSpeedTimer(_ timeInterval: Double = 1.0) {
        if speedTime == nil {
            //定时器初始化
            speedTime = Timer.scheduledTimer(withTimeInterval: TimeInterval(timeInterval), repeats: true) { [weak self] t in
                guard let self else {
                    return
                }
                updateSpeedTime()
            }
            speedTime?.fire()
        }
    }
    
    public func destroySpeedTime() {
        LogInfo("下载大小:\(finishBytesReceived)")
        speedTime?.invalidate()
        speedTime = nil
    }
    
    @objc func updateSpeedTime() {
        var deltaLength: Double = 0
        for task in self.downloadingTasks {
            deltaLength += bytesReceivedByDownloader(task.downloader)
        }
        //已下载字节
        deltaLength += finishBytesReceived
        //本次下载量：已下载+下载中
        //本次下载量-上次下载量/间隔时间
        let speed = Double(deltaLength - totalBytesReceived)/Double(speedUpdateIntervalTime)
        if let proSpeed = self.downloadSpeedBlock {
            proSpeed(speed,deltaLength,fileTotalLength,tasksCount)
        }
        totalBytesReceived = deltaLength
    }
    
    //获取下载器的下载量，当下载量大于预估时，则取两者最小值
    private func bytesReceivedByDownloader(_ downloader: GXDownloader) -> Double{
        var bytesReceived = Double(downloader.totalBytesReceived)
        if downloader.estimatedTotalBytesCount > 0 {
            bytesReceived = min(downloader.estimatedTotalBytesCount, Double(downloader.totalBytesReceived))
        }
        return bytesReceived
    }
    
    //获取下载器的下载量，当下载完毕，但有预估大小时，返回预估大小
    private func bytesReceivedByDownloaderFinish(_ downloader: GXDownloader) -> Double{
        var bytesReceived = Double(downloader.totalBytesReceived)
        if downloader.estimatedTotalBytesCount > 0 {
            bytesReceived = Double(downloader.estimatedTotalBytesCount)
        }
        return bytesReceived
    }
}

//MARK: 下载一组URL
extension GXDownloadManager {
    
    /// 下载URL
    /// - Parameters:
    ///   - url: <#url description#>
    ///   - path: <#path description#>
    ///   - block: <#block description#>
    public func download(url: String,
                  path: String = "gxdownload",
                  priority: Int = 3,
                  block: @escaping GXTaskCompleteBlock) {
        oneTaskDownload.diskFile.taskDownloadPath = "/\(path)"
        oneTaskDownload.taskPriority = priority
        let isExist = oneTaskDownload.diskFile.checkUrlTask(url: url)
        if isExist == true {
            oneTaskDownload.diskFile.clearFile(forUrl: url)
        }
        let path = oneTaskDownload.diskFile.getFilePath(url: url)
        //开始下载
        oneTaskDownload.start(forURL: url) { progress, state in
            if state == .completed {
                block(progress,path,state)
            } else {
                block(progress,nil,state)
            }
        }
    }
    
    public func downloadV2(url: String,
                  path: String = "gxdownload",
                  priority: Int = 3,
                  clearOld: Bool = false,
                  block: @escaping GXTaskCompleteV2Block) {
        oneTaskDownload.diskFile.taskDownloadPath = "/\(path)"
        oneTaskDownload.taskPriority = priority
        let isExist = oneTaskDownload.diskFile.checkUrlTask(url: url)
        if isExist == true && clearOld {
            oneTaskDownload.diskFile.clearFile(forUrl: url)
        }
        let path = oneTaskDownload.diskFile.getFilePath(url: url)
        //开始下载
        oneTaskDownload.start(forURL: url) { progress, state in
            if state == .completed {
                block(progress,path)
            } else {
                block(progress,nil)
            }
        }
    }
    
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
        self.tasksCount = Double(urls.count)
        finishTasksCount = 0
        fileTotalLength = 0
        
        LogInfo("开始下载")
        if isOpenDownloadSpeed {
            DispatchQueue.main.async {
                self.initSpeedTimer(self.speedUpdateIntervalTime)
            }
        }
    
        //入队
        for url in urls {
            fileTotalLength += url.size
            self.enqueue(urlModel: url, path: path)
        }
    
        //执行
        self.executeQueue.async {
            for _ in 0 ..< self.maxConcurrentCount {
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
        
        tasksCount = Double(urls.count)
        finishTasksCount = 0
        fileTotalLength = 0
        //入队
        for url in urls {
            fileTotalLength += url.size
            enqueueByPath(path: path, urlModel: url)
        }
        
        //执行
        self.executeQueue.async {
            for _ in 0 ..< self.maxConcurrentCount {
                //                print("下载次数：\(1)")
                self.execute()
            }
        }
    }
}
