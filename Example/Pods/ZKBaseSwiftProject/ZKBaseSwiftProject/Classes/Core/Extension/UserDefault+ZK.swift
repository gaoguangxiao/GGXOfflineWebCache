//
//  UserDefault+ZK.swift
//  paipai
//
//  Created by 高广校 on 2023/11/15.
//  Copyright © 2023 瑞思. All rights reserved.
//

import Foundation
import GGXSwiftExtension

public extension Keys {
    static let token = "token"
    static let agreePrivacyPolicy = "agreePrivacyPolicy"
    static let versionUpdate = "versionUpdate"
}

public extension UserDefaults {
    @UserDefaultWrapper(key: Keys.token, defaultValue: "")
    static var token:String
    
    /// 隐私协议弹框
    @UserDefaultWrapper(key: Keys.agreePrivacyPolicy, defaultValue: false)
    static var agreePrivacyPolicy: Bool
    
    /// 版本更新
    @UserDefaultWrapper(key: Keys.versionUpdate, defaultValue: "1.0.0")
    static var versionUpdate: String
    
}



