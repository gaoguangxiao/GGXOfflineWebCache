//
//  UserDefault+ZK.swift
//  paipai
//
//  Created by 高广校 on 2023/11/15.
//  Copyright © 2023 瑞思. All rights reserved.
//

import Foundation

//定义属性包装器
@propertyWrapper
public struct UserDefaultWrapper<T> {
    private let key: String
    private let defaultValue: T
    
    public init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    public var wrappedValue: T {
        get {
            let value = UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
            return value
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
            UserDefaults.standard.synchronize()
        }
    }
}

public enum Keys {
    
}



