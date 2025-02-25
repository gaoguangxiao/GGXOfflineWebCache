//
//  URL+CommonExtension.swift
//  DaDaClass
//
//  Created by problemchild on 2018/4/8.
//  Copyright © 2018年 dadaabc. All rights reserved.
//

import Foundation
import CommonCrypto

public enum WebMIMEType: String {
    case html
    case js
    case css
    case png
    case jpeg
    case json
    case xml
    case pdf
    case webp
    case gif
    case mpeg
    case mp3
    case mp4
    case wav
    case ico
    case svg
    case ttf
    case woff
    case woff2
    case atlas //Content-Type application/octet-stream
}

public extension URL {
    /// 取出Get请求中的参数，结果是一个大字典
    func getParameters() -> [String: String] {
        let components = NSURLComponents(url: self, resolvingAgainstBaseURL: false)
        // 取出items，如果為nil就改為預設值 空陣列
        let queryItems = components?.queryItems ?? []
        return queryItems.reduce([String: String]()) {
            var dict = $0
            dict[$1.name] = $1.value ?? ""
            return dict
        }
    }
    
    
    var base64FileData: String? {
        do {
            let data = try Data(contentsOf: self)
            let base64 = data.base64EncodedString()
            return base64.length > 0 ? base64 : nil
        } catch {
            print("解析音频数据失败")
            return nil
        }
    }

    var contentFileData: Data? {
        do {
            return try Data(contentsOf: self)
        } catch let e {
            print("报错信息：\(e)")
            return nil
        }
    }
    
    var filejsonData: Any? {
        do {
            guard let data = self.contentFileData else { return nil }
            return try JSONSerialization.jsonObject(with: data)
        } catch let e{
            print("报错信息：\(e)")
            return nil
        }
    }
    
    ///  按照原顺序 取出Get请求中的参数，结果是一个大字典
    /// - Returns:结果是一个数组，每个元素是一个字典，（可以有序）
    func getParametersWithOrder() -> [[String: String]] {
        var queries = [[String: String]]()
        guard let query = query else { return queries }
        
        let andChar = CharacterSet(charactersIn: "&")
        let queryComponents = query.components(separatedBy: andChar)
        
        let equalChar = CharacterSet(charactersIn: "=")
        for component in queryComponents {
            let items = component.components(separatedBy: equalChar)
            guard items.count == 2 else { continue }
            guard let firstItem = items.first, let lastItem = items.last else { continue }
            let queryPair = [firstItem: lastItem]
            queries.append(queryPair)
        }
        
        return queries
    }
    
    func toMD5() -> String? {
            
            let bufferSize = 1024 * 1024
            
            do {
                //打开文件
                let file = try FileHandle(forReadingFrom: self)
                defer {
                    file.closeFile()
                }
                
                //初始化内容
                var context = CC_MD5_CTX()
                CC_MD5_Init(&context)
                
                //读取文件信息
                while case let data = file.readData(ofLength: bufferSize), data.count > 0 {
                    data.withUnsafeBytes {
                        _ = CC_MD5_Update(&context, $0, CC_LONG(data.count))
                    }
                }
                
                //计算Md5摘要
                var digest = Data(count: Int(CC_MD5_DIGEST_LENGTH))
                digest.withUnsafeMutableBytes {
                    _ = CC_MD5_Final($0, &context)
                }
                
                return digest.map { String(format: "%02hhx", $0) }.joined()
                
            } catch {
                print("Cannot open file:", error.localizedDescription)
                return nil
            }
        }
}
