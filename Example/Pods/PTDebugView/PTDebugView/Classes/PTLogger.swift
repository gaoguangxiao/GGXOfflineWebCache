//
//  PTLogger.swift
//  PTDebugView
//
//  Created by 高广校 on 2024/7/9.
//

import Foundation
import GGXSwiftExtension

@propertyWrapper
public struct PTLogger {
    
    let logger: Logger
    
    //subsystem 一般为`Bundle indentifier`，以便从众多日志辨别出那些是应用的日志
    //category：一般表示应用的某模块，这里标注 类名
    //@available(iOS 14.0, *)
    //let logger = Logger(subsystem: "app.synthesis.ggx", category: "synthesisSpeech")
    public init(subsystem: String = kAppBundleId ?? "", category: String = "defaultCategory") {
        self.logger = Logger(subsystem: subsystem, category: category)
    }
    
    public var wrappedValue: Logger {
        return logger
    }
    
}

