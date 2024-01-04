//
//  NSDate+CommonExtension.swift
//  DaDaClass
//
//  Created by problemchild on 2018/4/12.
//  Copyright © 2018年 dadaabc. All rights reserved.
//

import Foundation

// 时间格式
public let DAY_FORMAT = "yyyy-MM-dd"
public let SECOND_FORMAT = "yyyy-MM-dd HH:mm:ss"

public extension Date {

    /// 当前时间戳
    static var currentTimestamp: String {
        let date = Date()
        return "\(Int(date.timeIntervalSince1970))"
    }

    /// 当前时间戳  秒级 时间戳 - 13位
    ///
    /// - Returns: 时间戳字符串
    static var milliStamp : Int64 {
        let timeInterval: TimeInterval = NSDate.init().timeIntervalSince1970
        let millisecond = Int64(round(timeInterval*1000))
        return millisecond
    }
    
    /// 以“yyyyMMdd”的格式得到日期字符串
    static var currentDateStr: String {
        let date = Date()
        let formatStr = "yyyyMMdd"

        let df = DateFormatter()
        df.locale = Locale.current
        df.dateFormat = formatStr
        return df.string(from: date)
    }

    static var currentDateMinStr: String {
        let date = Date()
        let formatStr = "yyyyMMddHHmmss"

        let df = DateFormatter()
        df.locale = Locale.current
        df.dateFormat = formatStr
        return df.string(from: date)
    }

    /// 得到时间字符串
    ///
    /// - Parameter formatStr: 格式，默认"yyyyMMdd"
    /// - Returns: 结果
    static func getCurrentDateStr(_ formatStr: String = "yyyyMMdd") -> String {
        let date = Date()
        let df = DateFormatter()
        df.locale = Locale.current
        df.dateFormat = formatStr
        return df.string(from: date)
    }

    /// 把时间戳转换为用户格式时间
    ///
    /// - Parameter timestamp     时间戳
    /// - Parameter format        格式
    /// - Returns: 结果
    static func getTimeByStamp(timestamp: Int, format: String) -> String {
        var time = ""
        if (timestamp == 0) {
            return ""
        }
        let confromTimesp = NSDate(timeIntervalSince1970: TimeInterval(timestamp / 1000))
        let formatter = DateFormatter()
        formatter.dateFormat = format
        time = formatter.string(from: confromTimesp as Date)
        return time;
    }
    
    var year: Int {
        return Calendar.current.component(.year, from: self)
    }
    
    var month: Int {
        return Calendar.current.component(.month, from: self)
    }
    
    var day: Int {
        return Calendar.current.component(.day, from: self)
    }
    
    var hour: Int {
        return Calendar.current.component(.hour, from: self)
    }
    
    var minute: Int {
        return Calendar.current.component(.minute, from: self)
    }
    
    var second: Int {
        return Calendar.current.component(.second, from: self)
    }
    
    var noHourDate: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: "\(self.year)-\(self.month)-\(self.day)") ?? self
    }
    
    var bsDescription: String {
        /**
         60秒内：刚刚
         1-60分钟 ：5分钟前
         60以上 - 今天0点之后：几小时以前，
         昨天：昨天22：00
         前1-7日前，在今年内：X天前
         7日前-今年1.1：XX-XX
         去年及以前：20XX-XX-XX
         */
        let now = Date()
        //            let now = dateNow!
        let secDiff = now.timeIntervalSince1970 - self.timeIntervalSince1970
        let dayDiffSec = now.noHourDate.timeIntervalSince1970 -
                        self.noHourDate.timeIntervalSince1970
        let dayDiff = Int(dayDiffSec / (24.0 * 60 * 60))
        
        if secDiff < 60 {
            return "刚刚"
        } else if secDiff < 60 * 60 {
            return "\(Int(secDiff / 60))分钟前"
        } else if self.timeIntervalSince1970 - now.noHourDate.timeIntervalSince1970 > 0 {
            let min = Int(secDiff / 60)
            let hour = min / 60
            return "\(hour)小时前"
        } else if dayDiff <= 1 {
            let hour = NSString(format: "%02d", self.hour)
            let minute = NSString(format: "%02d", self.minute)
            return "昨天\(hour):\(minute)"
        } else if now.year != self.year {
            let year = NSString(format: "%02d", self.year)
            let month = NSString(format: "%02d", self.month)
            let day = NSString(format: "%02d", self.day)
            return "\(year)-\(month)-\(day)"
        } else if dayDiff <= 7 {
            return "\(dayDiff)天前"
        } else {
            let month = NSString(format: "%02d", self.month)
            let day = NSString(format: "%02d", self.day)
            return "\(month)-\(day)"
        }
    }
}
