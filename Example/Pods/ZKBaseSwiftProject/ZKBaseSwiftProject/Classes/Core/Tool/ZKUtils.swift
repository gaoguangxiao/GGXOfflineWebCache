//
//  ZKUtils.swift
//  ZKBaseSwiftProject
//
//  Created by 高广校 on 2023/12/28.
//

import Foundation
import GGXSwiftExtension
import WebKit

public struct ZKUtils {
    
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
        let newUA = "Mozilla/5.0 (\(UIDevice.current.model); CPU \(systemName) \(systemVersion) like Mac OS X; \(UIDevice.modelName)) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148"
        return newUA
    }
    
    static func removeWebsiteDataStore() {
//        WKWebsiteDataStore.removeWebsiteDataStore()
    }
}
