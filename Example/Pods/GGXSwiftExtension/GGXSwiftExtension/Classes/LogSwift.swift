//
//  LogSwift.swift
//  RSReading
//
//  Created by 高广校 on 2023/9/12.
//

import Foundation

public class LogSwift: NSObject {

    static var logPath = ""

    @discardableResult
    public override init() {
        if let cachesPath = FileManager.cachesPath {
            LogSwift.logPath = cachesPath + "/" + "app.log"
            LogInfo("log文件：" + LogSwift.logPath)
            if !FileManager.isFileExists(atPath: LogSwift.logPath) {
                //创建.log文件
               let result = FileManager.createFile(atPath: LogSwift.logPath)
            } else {
               
            }
        }
    }
    
    static var read: String {
        var content:String?
        if logPath.length > 0 ,let _logPath = logPath.toFileUrl {
            let fh = try? FileHandle.init(forReadingFrom: _logPath)
            var data : Data?
            
//            if #available(iOS 13.4, *) {
//                data = try? fh?.readToEnd()
//            } else {
                // Fallback on earlier versions
                data = fh?.readDataToEndOfFile()
//            }
             
            if let _data = data {
                content = String(data: _data, encoding: .utf8)
            }
            
        }
        return content ?? ""
    }
    
    public static func clear() {
        FileManager.removefile(atPath: logPath)
        //重新创建log文件
        let result = FileManager.createFile(atPath: LogSwift.logPath)
        LogInfo(result)
    }
                  
    @objc static func Log( _ message: String){
        LogInfo(message)
        if logPath.length > 0 ,let _logPath = logPath.toFileUrl {
            let fh = try? FileHandle.init(forWritingTo: _logPath)
            fh?.seekToEndOfFile()
            let msg = message  + "\n"
            if let wData = msg.data(using: .utf8) {
                fh?.write(wData)
            }
            if #available(iOS 13.0, *) {
                do {
                    try fh?.close()
                } catch {
                    
                }
            } else {
                fh?.closeFile()
            }
        }
    }
    
}

public func LogInfo<T>( _ message: T, file: String = #file, method: String = #function, line: Int = #line){
    #if DEBUG
    print("\n日期：\(Date.getCurrentDateStr("yyyy-MM-dd HH:mm:ss SSS"))\n信息：\(message)")
    #endif
}

public func LogInfoSave( _ message: String, file: String = #file, method: String = #function, line: Int = #line){
    #if DEBUG
    LogSwift.Log(message)
//    print("\((file as NSString).lastPathComponent)[\(line)], \(method): \(message)")
    #endif
}
