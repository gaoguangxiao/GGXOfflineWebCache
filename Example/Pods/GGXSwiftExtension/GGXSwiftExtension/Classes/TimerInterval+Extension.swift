//
//  TimerInterval+CommonExtension.swift
//  DaDaClass
//
//  Created by problemchild on 2018/4/12.
//  Copyright © 2018年 dadaabc. All rights reserved.
//

import Foundation

public extension TimeInterval {

    var normalDateString: String {
        let date = Date.init(timeIntervalSince1970: self)
        let formatStr = "MM-dd HH:mm"

        let df = DateFormatter()
        df.locale = Locale.current
        df.dateFormat = formatStr

        return df.string(from: date)
    }

    var dateString: String {
        let calander = NSCalendar.current
        let date = Date.init(timeIntervalSince1970: self)

        if calander.isDateInYesterday(date) {
            return "昨天"
        }

        var formatStr = "MM-dd HH:mm"

        if calander.isDateInToday(date) {
            formatStr = "HH:mm"
        }

        let df = DateFormatter()
        df.locale = Locale.current
        df.dateFormat = formatStr

        return df.string(from: date)
    }
}
