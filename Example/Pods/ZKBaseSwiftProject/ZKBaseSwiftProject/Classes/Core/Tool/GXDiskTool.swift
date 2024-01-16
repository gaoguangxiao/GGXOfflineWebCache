//
//  GXDiskTool.swift
//  ZKBaseSwiftProject
//
//  Created by 高广校 on 2024/1/3.
//

import Foundation

public class GXDiskTool: NSObject{
    //在Caches文件下创建指定文件夹
    public func createFolder(name: String) -> String? {
        guard let cache = FileManager.cachesPath else { return nil }
        let folderPath = cache + "/\(name)"
        let status = FileManager.createFolder(atPath: folderPath)
        return status ? folderPath : nil
    }
}
