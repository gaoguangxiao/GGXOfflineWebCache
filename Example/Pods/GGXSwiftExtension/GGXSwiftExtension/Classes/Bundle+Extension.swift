//
//  Bundle+Extension.swift
//  GGXSwiftExtension
//
//  Created by 高广校 on 2023/9/22.
//

import Foundation

public extension Bundle {
    
    //待扩展 文件路径 一段数据
    static func jsonfileTojson(_ name:String) -> Any {
        //将JSON文件 读取并输出为字符串
        let filePath = Bundle.main.path(forResource: name, ofType: "json")
        guard let uurl = filePath?.toFileUrl else {
            print("URL为空")
            return ""
        }
        //将文件数据转化为Data
        let fileData = try? Data(contentsOf: uurl)
        guard let fData = fileData else {
            print("解析数据失败")
            return ""
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: fData)
            return json
        } catch {
            print("json报错")
            return ""
        }
    }
    
    static func jsonfileTojson(_ name:String, type: String?) -> Data? {
        //将JSON文件 读取并输出为字符串
        let filePath = Bundle.main.path(forResource: name, ofType: type)
        guard let uurl = filePath?.toFileUrl else {
            print("URL为空")
            return nil
        }
        //将文件数据转化为Data
        return try? Data(contentsOf: uurl)
    }
}
