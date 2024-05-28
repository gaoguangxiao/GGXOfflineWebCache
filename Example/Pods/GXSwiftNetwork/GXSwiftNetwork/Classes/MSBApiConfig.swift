//
//  MSBApiConfig.swift
//
//  Created by 李响 on 2022/1/10.
//

import Foundation
//import SwiftyUserDefaults

public let TokenUnable_Notification = "TokenUnable_Notification"
public let ReportBuglyAbility_Notification = "ReportBuglyAbility_Notification"

/// 配置信息和回调信息
@objcMembers open class MSBApiConfig: NSObject {
    public static let shared = MSBApiConfig()
    private override init() { }
    
    public var getIsDebug: (() -> Bool)?
    public var getApiHost: (() -> String)?
    public var showHUDAbility: ((MSBApiError) -> Void)?
    public var dismissHUDAbility: (() -> Void)?
    public var reportBuglyAbility: ((Int, [String: Any]?) -> Void)?
    public var tokenInvalidateCallBack: (() -> Void)?

    public var timeoutInterval: Float = 30
    
    internal var headers: [String: String]?
    internal var apiHost: String!

    /// 配置信息
    public func setApiConfig(apiHost: String!, commonHeaders: [String: String], isAddDefaultHeaders: Bool) {
        
        MSBApiConfig.shared.headers = commonHeaders
        if isAddDefaultHeaders {
            MSBApiConfig.shared.headers = MSBApiConfig.shared.commonHeaders + commonHeaders
        }
        MSBApiConfig.shared.apiHost = apiHost
        MSBApiConfig.shared.getIsDebug = { true }
        MSBApiConfig.shared.getApiHost = { apiHost }
        MSBApiConfig.shared.showHUDAbility = { error in
            // 根据业务需要展示API错误信息
            var showErr = error
//            if showErr.code == 6 {
//                showErr.msg = "网络连接不畅，请检查网络"
//            }
        }
        
        MSBApiConfig.shared.dismissHUDAbility = {
            
        }
        
        MSBApiConfig.shared.reportBuglyAbility = { (code, info) in
            DispatchQueue.main.async(execute: {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: ReportBuglyAbility_Notification), object: nil)
            })
        }
        
        MSBApiConfig.shared.tokenInvalidateCallBack = {
            // token失效处理
            DispatchQueue.main.async(execute: {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: TokenUnable_Notification), object: nil)
            })
        }
    }
    
    //apihost
    public func updateApiHost(_ host: String) {
        MSBApiConfig.shared.apiHost = host
        MSBApiConfig.shared.getApiHost = { host }
    }
    
//  MARK: 请求头
    ///add
    public func appendHeader(_ header:[String: String]) {
        if let requestHeaders = self.headers {
            MSBApiConfig.shared.headers = requestHeaders + header
        }
//        MSBApiConfig.shared.headers = MSBApiConfig.shared.commonHeaders + header
    }
    ///remove
    public func removeHeader(_ forKey:String) {
        MSBApiConfig.shared.headers?.removeValue(forKey: forKey)
    }

    private var commonHeaders: [String: String] {
//        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
//        let versionNumber = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        
        var header : [String: String] = [:]
//        header["token"] = MSBApi.getToken().token
//        header["tmpToken"] = Defaults[.tmpToken]
//        header["subject"] = "MUSIC_APP"
//        header["device"] = "app"
//        header["os-type"] = "ios"
        header["Content-Type"] = "application/json"
//        header["version"] = versionNumber//1.6.3
//        header["version-code"] = buildNumber //43
//        header["buildcode"] = buildNumber
//        header["devicemodel"] = UIDevice.modelName
//        if (UIDevice.isIPad) {
//            header["devicetype"] = "iPad"
//        }else {
//            header["devicetype"] = "iPhone"
//        }
        return header
    }

}

