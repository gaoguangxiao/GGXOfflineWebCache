//
//  ZKUtils.swift
//  ZKBaseSwiftProject
//
//  Created by 高广校 on 2023/12/28.
//

import Foundation
import GGXSwiftExtension
import WebKit
import KeychainAccess

public struct ZKUtils {
    
    /// 屏幕启动是scene的方向
    public static var launchOrientationMask: UIInterfaceOrientation?
    
    /// 屏幕初始方向
    public static var supportOrientationMask: UIInterfaceOrientationMask?
    
    /// 默认横屏
    public static var orientationMask: UIInterfaceOrientationMask {
        get {
            if let supportOrientationMask {
                return supportOrientationMask
            }
            if #available(iOS 16.0, *) {
                
            } else {
                //iOS16之前 需要保存启动设备方向，解决当设备竖屏锁定时，启动图方向和主控制器不一致问题。而iOS16之后，系统内部解决了此问题
                if let launchOrientationMask {
                    if launchOrientationMask == .landscapeLeft {
                        return .landscapeLeft
                    } else if launchOrientationMask == .landscapeRight {
                        return .landscapeRight
                    }
                }
            }
            // final
            return .landscape
        }
        set {
            supportOrientationMask = newValue
        }
    }
    
    public static var deviceIdentifier: String = {
        return ZKUtils.getDeviceIdentifier()
    }()
 
    /// 获取设备的UUID
    /// - Returns: UUID的字符串
    static func getUUID() -> String {
        return UUID().uuidString
    }
    
    /// 获取设备的UUID ，此UUID与BundleID绑定，为设备的唯一ID
    /// - Returns: 返回设备唯一标识符
    static func getDeviceIdentifier() -> String{
//        let bundleID : String = Bundle.main.infoDictionary?[(kCFBundleIdentifierKey as NSString) as String] as! String
        let bundleID = kAppBundleId ?? "rs.com"
        let service = bundleID + "\(#function)"
        let keychainItems = Keychain(service :service).allItems()
        var deviceID : String = ""
        if keychainItems.count > 0 {
            deviceID = keychainItems[0]["value"] as! String
        }
        if  deviceID.isEmpty {
            deviceID = getUUID()
            Keychain(service:service)["bundleID"] = deviceID
        }
        return deviceID
    }
    
    public static func getbaseUA(name: String) -> String {
        let appVersion = kAppVersion ?? ""
        let appBuildVersion = kAppBuildVersion ?? ""
        return deviceUserAgent + " \(name)/" + appVersion + " Build/" + appBuildVersion +  " Factory/apple"
    }
    
    public static var deviceUserAgent: String {
        let systemVersion = UIDevice.current.systemVersion.replacingOccurrences(of: ".", with: "_")
        var systemName = ""
        if UIDevice.isIPad {
            systemName = "OS"
        } else {
            systemName = "iPhone OS"
        }
        let newUA = "Mozilla/5.0 (\(UIDevice.current.model); CPU \(systemName) \(systemVersion) like Mac OS X; \(UIDevice.modelName)) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/\(UIDevice.modelName) UUID/\(deviceIdentifier)"
        return newUA
    }
    
    //事件上报属性必带
    public static var baseDeviceInfo: String {
        let appVersion = kAppVersion ?? ""
        let sysVersion = UIDevice.currentSystemVersion
        let deviceModel = UIDevice.modelName
//        let date = Date.getCurrentDateStr("yyyy/MM/dd HH:mm:ss")
        let baseInfo = "\(deviceModel)-\(sysVersion)-V\(appVersion)-udid:\(ZKUtils.deviceIdentifier)"
        return baseInfo
    }
    
    static func removeWebsiteDataStore() {
//        WKWebsiteDataStore.removeWebsiteDataStore()
    }
}

public typealias DispatchTask = (_ cancel: Bool) -> Void
@discardableResult
public func delay(time: TimeInterval, task: @escaping ()->(), queue: DispatchQueue = DispatchQueue.main) -> DispatchTask? {
    func dispatch_later(block: @escaping ()->()) {
        queue.asyncAfter(deadline: DispatchTime.now() + time, execute: block)
    }
    var closure: (()->Void)? = task
    var result: DispatchTask?
    let delayedClosure: DispatchTask = { cancel in
        if let internalClosure = closure {
            if !cancel {
                queue.async {internalClosure()}
            }
        }
        closure = nil
        result = nil
    }
    result = delayedClosure
    dispatch_later {
        if let delayedClosure = result {
            delayedClosure(false)
        }
    }
    return result
}

public func cancel(task: DispatchTask?) {
    task?(true)
}
