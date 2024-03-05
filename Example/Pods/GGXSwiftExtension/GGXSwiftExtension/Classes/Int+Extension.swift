//
//  Int+extension.swift
//  Exx
//
//  Created by mqt on 2017/8/11.
//  Copyright © 2017年 mqt. All rights reserved.
//

import UIKit

public extension Int {
    
    /**
     转化为字符串格式
     - returns:
     */
    func toString() -> String {
        return String(self)
    }
    
    /**
     把布尔变量转化为Int
     - returns:
     */
    init(_ value: Bool) {
        if value {
            self.init(1)
        } else {
            self.init(0)
        }
    }
    
    
    /// 转为bool型
    ///
    /// - Returns:
    func toBool() -> Bool {
        if self > 0 {
            return true
        } else {
            return false
        }
    }
}


public extension Int {
    
    /// 60 * 68 *60 24小时转换为 00:00:00 系那是
    var bshmmDown: String {
        
//        if
        let timeout = self
            
            let days = self/(3600*24)
            
            let hours = (timeout-days*24*3600)/3600
            
            let minute = (timeout-days*24*3600-hours*3600)/60
            
            let second = timeout-days*24*3600-hours*3600-minute*60
            
        
            return "\(String(format: "%.2d", hours)):\(String(format: "%.2d", minute)):\(String(format: "%.2d", second))"
//        }
        
//        return "00:00:00"
        
    }
}
