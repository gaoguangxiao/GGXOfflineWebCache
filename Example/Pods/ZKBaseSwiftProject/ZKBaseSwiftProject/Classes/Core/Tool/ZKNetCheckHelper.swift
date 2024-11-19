//
//  ZKNetCheckHelper.swift
//  ZKBaseSwiftProject
//
//  Created by 高广校 on 2023/12/21.
//

import Foundation
import CoreTelephony
import Reachability

public class ZKNetCheckHelper {
    
    public static let share = ZKNetCheckHelper()
    
    var reachability: Reachability?
    
    var netStatusUpdate: ZKBoolClosure?
    
    public init() {
        self.registObserver()
    }
    
    //初次启动，网络受限状态下，如果有网络，返回true。非受限返回false
    public func checkNetworkRestricted(block: @escaping ZKBoolClosure) {
        self.netStatusUpdate = block
        let cellularData = CTCellularData()
        cellularData.cellularDataRestrictionDidUpdateNotifier = { state in
            switch state {
            case .restricted:
                //网络受限
                //仅无线、仅流量、以及未授权【需要存储是否弹出权限授权判断】、都是受限
                print("NetStatus:Restricted")
//                block(false)
            case .notRestricted:
                //网络授权弹框-授权无线和流量
                print("NetStatus:notRestricted")
                block(false)
            case .restrictedStateUnknown:
                //权限未授权
                print("NetStatus:restrictedStateUnknown")
            default:
                break
            }
        }
    }
    
    func registObserver() {
        
//        print("注册网络监听次数")
        
        do {
            reachability = try Reachability.init(hostname: "www.baidu.com")
            try reachability?.startNotifier()
        } catch {
            
        }

        NotificationCenter.default.addObserver( self, selector: #selector(reachabilityChanged(_:)), name: .reachabilityChanged, object: nil )
        
    }
    
    //网络状态变化时，调用
    @objc func reachabilityChanged(_ note: Notification) {
        print("网络改变调用次数--")
        if let reachability = self.reachability {
//            var status :PTReachabilityStatus = .none
            switch reachability.connection {
            case .unavailable:
                print("unavailable")
            case .none:
                print("none")
                self.netStatusUpdate?(false)
            case .wifi, .cellular:
                print("wifi或cellular")
                self.netStatusUpdate?(true)
                //得到网络变化回调之后，移除观察
                NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: nil)
                //停止
                reachability.stopNotifier()
            }
        }
    }
    
    deinit {
        print("\(self):deinit")
    }
}
