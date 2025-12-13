//
//  GXTaskDownTimer.swift
//  RSBridgeCore
//
//  Created by 高广校 on 2024/2/4.
//

import Foundation

public class GXTaskDownTimer: NSObject {
    
    /// 息屏倒计时
    var idleRetainCount = 0.0
    
    /// 息屏定时器
    var idleTime: Timer?
    
    /// 息屏完成回调
    var idleTimerComplete: ZKDoubleClosure?
    
    public var isDownTimer: Bool {
        return idleRetainCount > 0
    }
    
    public func initIdleTimer(retaminCount: Double,block: @escaping ZKDoubleClosure) {
        initIdleTimer(retaminCount: retaminCount, timeInterval: 1.0, block: block)
    }
    
    public func initIdleTimer(retaminCount: Double,timeInterval: Double = 1.0,block: @escaping ZKDoubleClosure) {
        
        if idleTime == nil {
            //定时器初始化
            idleTime = Timer.scheduledTimer(withTimeInterval: TimeInterval(timeInterval), repeats: true) { [weak self] t in
                guard let self else {
                    return
                }
                updateIdleTime(t)
            }
            //定时器需要在运行循环（Run Loop）的线程上才能正常工作。主线程自动开启运行循环，但子线程需要手动启动。
            self.idleTimerComplete = block
            if !Thread.isMainThread {
                idleRetainCount = retaminCount + timeInterval
                if let idleTime {
                    RunLoop.current.add(idleTime, forMode: .common)
                    RunLoop.current.run()
                }
            } else {
                idleRetainCount = retaminCount
            }
        }
    }
    
    @objc func updateIdleTime(_ timer: Timer) {
        idleRetainCount -= 1
        //        ZKLog("进入系统倒计时：\(idleRetainCount)")
        if idleRetainCount <= 0 {
            idleTime?.invalidate()
            idleTime = nil
        }
        self.idleTimerComplete?(idleRetainCount)
    }
    
    public func removeInvalidate() {
        idleTime?.invalidate()
        idleTime = nil
    }
    
    deinit {

    }
}
