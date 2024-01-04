//
//  DateFormatter+Extension.swift
//  wisdomstudy
//
//  Created by ggx on 2017/9/6.
//  Copyright © 2017年 高广校. All rights reserved.
//

import Foundation

extension DateFormatter{
    convenience init(dateFormat:String) {
        self.init()
        self.dateFormat = dateFormat
    }
}
