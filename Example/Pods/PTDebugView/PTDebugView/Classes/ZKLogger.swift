//
//  ZKLogger.swift
//  PTDebugView
//
//  Created by 高广校 on 2024/7/9.
//

import Foundation
import os.log

public class Logger {

    private var subsystem: String
    private var category: String
 
    public init(subsystem: String, category: String) {
        self.subsystem = subsystem
        self.category = category
    }
 
    public func debug(_ message: String) {
#if DEBUG
        os_log("%@", log: OSLog(subsystem: subsystem, category: category), type: .debug, message)
#endif
    }
 
    public func info(_ message: String) {
        os_log("%@", log: OSLog(subsystem: subsystem, category: category), type: .info, message)
    }
 
    public func error(_ message: String) {
        os_log("%@", log: OSLog(subsystem: subsystem, category: category), type: .error, message)
    }
    
    public func log(_ message: String, type: OSLogType = .default) {
        os_log("%@", log: OSLog(subsystem: subsystem, category: category), type: type, message)
    }
}
