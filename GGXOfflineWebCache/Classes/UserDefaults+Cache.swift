//
//  UserDefaults+Cache.swift
//  RSBridgeNetCache
//
//  Created by 高广校 on 2024/1/3.
//

import Foundation
import GGXSwiftExtension

extension Keys {
    static let presetDataVersionKey: String = "presetDataVersionKey"
    static let presetDataNameKey: String = "presetDataNameKey"
}

extension UserDefaults {
    @UserDefaultWrapper(key: Keys.presetDataVersionKey, defaultValue: "0.0.0")
    static var presetDataVersionKey: String?
    
    @UserDefaultWrapper(key: Keys.presetDataNameKey, defaultValue: "")
    static var presetDataNameKey: String?
}
