//
//  PTReachabilityManger.swift
//  KidReading
//
//  Created by 葡萄科技 on 2019/5/10.
//  Copyright © 2019 putao. All rights reserved.
//

import UIKit
import Reachability

public enum GXReachabilityStatus {
    case none
    case wifi
    case cellular
}

typealias StatusChangeCallback = (_ status : GXReachabilityStatus)->()
typealias PendingTask = ()->Void

public class ZKReachabilityManger {
    
    public static let share = ZKReachabilityManger.init()
    
    private var listeners : [Int : StatusChangeCallback] = [:]
    
    private var pendingTasks: [PendingTask] = []

    var didAlertForAuthority = false

    var reachability: Reachability?
   
    init() {
        self.registObserver()
    }
    
    /// 注册监听者
    private func registObserver() {
    
        do {
            reachability = try Reachability.init(hostname: "www.baidu.com")
            try reachability?.startNotifier()
        } catch {
//            Bugly.report(NSException.init(name: NSExceptionName(rawValue: "Reachability_init_error"), reason: error.localizedDescription, userInfo: nil))
//            NBSAppAgent.trackEvent("Reachability_init_error")
        }
        NotificationCenter.default.addObserver( self, selector: #selector(reachabilityChanged(_:)), name: .reachabilityChanged, object: nil )

    }
    
    /// 移除监听者
    func removeObserver()  {
        reachability?.stopNotifier()
    }
    
    deinit {
        self.removeObserver()
    }
    
    ///网络状态发生改变
    @objc func reachabilityChanged(_ note: Notification) {
        if let reachability = self.reachability {
            var status :GXReachabilityStatus = .none
            switch reachability.connection {
            case .unavailable , .none:
                status = .none
            case .wifi:
                status = .wifi
            case .cellular:
                status = .cellular
            }
            for (_ , callback) in listeners {
                callback(status)
            }
            if status != .none  , self.pendingTasks.count > 0 {
                let tasks = self.pendingTasks
                self.pendingTasks = []
                for item in tasks {
                    item()
                }
            }
        }
    }
    
    func isReachable() -> Bool {
        if reachability?.connection == Reachability.Connection.unavailable {
            return false
        }
        return true
    }
    
    func addListener(id : Int , _ listener : @escaping StatusChangeCallback) {
        self.listeners[id] = listener
    }
    
    public func readReachabilityStatus() -> GXReachabilityStatus {
        if self.reachability == nil {
            reachability = try? Reachability.init(hostname: "www.apple.com")
            try? reachability?.startNotifier()
        }
        var status :GXReachabilityStatus = .none
        if let reachability = self.reachability {
           switch reachability.connection {
           case .unavailable , .none:
               status = .none
           case .wifi:
               status = .wifi
           case .cellular:
               status = .cellular
            }
        }
        return status
    }
    
    func removeListener(_ id : Int)  {
        self.listeners.removeValue(forKey: id)
    }
    
    func exeTaskOnceNetworkReachable(_ block: @escaping PendingTask) {
        if self.isReachable() {
             block()
         } else {
             self.pendingTasks.append(block)
         }
     }
    
    func checkAuthority() {
        if !self.isReachable() && !didAlertForAuthority {
            didAlertForAuthority = true
//            PTPermissions.authorizeCellularDataWith { (auth) in
//                if !auth {
//                    PTPermissions.alertForJumpToSystemPrivacySetting(message: "网络访问受限")
//                }
//            }
        }
    }
    
}
