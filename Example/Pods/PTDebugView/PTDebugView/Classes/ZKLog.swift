//
//  ZKLog.swift
//  RSReading
//
//  Created by 高广校 on 2023/9/12.
//

import Foundation
import GGXSwiftExtension

public class ZKWLog: NSObject {

    static var logPath = ""

    @discardableResult
    public override init() {
        if let documentPath = FileManager.documentPath {
            ZKWLog.logPath = documentPath + "/" + "app.log"
            ZKLog("log文件：" + ZKWLog.logPath)
            if !FileManager.isFileExists(atPath: ZKWLog.logPath) {
                //创建.log文件
               let result = FileManager.createFile(atPath: ZKWLog.logPath)
            } else {
               
            }
        } else {
            print("documentPath is empty")
        }
    }
    
    public static var read: String {
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
        let result = FileManager.createFile(atPath: ZKWLog.logPath)
        ZKLog(result)
    }
                  
    @objc public static func Log( _ message: String){
        let wStr = "\n-------\(Date.getCurrentDateStr("yyyy-MM-dd HH:mm:ss SSS"))日志-------\n" + message
        ZKLog(wStr)
        if logPath.length > 0 ,let _logPath = logPath.toFileUrl {
            let fh = try? FileHandle.init(forWritingTo: _logPath)
            fh?.seekToEndOfFile()
            let msg = wStr  + "\n"
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

public func ZKTLog<T>( _ message: T, file: String = #file, method: String = #function, line: Int = #line){
    #if DEBUG
    print("\(Date.getCurrentDateStr("yyyy-MM-dd HH:mm:ss SSS"))、\((file as NSString).lastPathComponent)[\(line)], \(method): \(message)")
    #endif
}

public func ZKLog<T>( _ message: T, file: String = #file, method: String = #function, line: Int = #line){
    #if DEBUG
    print("\((file as NSString).lastPathComponent)[\(line)], \(method): \(message)")
    #endif
}

public func ZKSLog( _ message: String, file: String = #file, method: String = #function, line: Int = #line){
    #if DEBUG
    ZKWLog.Log(message)
//    print("\((file as NSString).lastPathComponent)[\(line)], \(method): \(message)")
    #endif
}
