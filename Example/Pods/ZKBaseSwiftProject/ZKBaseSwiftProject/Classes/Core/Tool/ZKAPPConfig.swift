//
//  ZKAPPConfig.swift
//  ZKBaseSwiftProject
//
//  Created by 高广校 on 2024/1/8.
//

import Foundation

class ZKAPPConfig {
    
}


public enum DistributeChannel {
    case dev  //开发
    case test //测试
    case alpha   //
    case online  //上线：服务器环境为正式，开启审核
}

public enum DevelopmentMode {
    //调试模式
    public static var isTest: Bool {
#if DEBUG
        return true
#else
        return false
#endif
    }
}
