//
//  String+OffLine.swift
//  GGXOfflineWebCache
//
//  Created by 高广校 on 2024/1/16.
//

import Foundation

public extension String {
    var removeMD5: String {
        let filepath = self
        let paths = filepath.components(separatedBy: ".")
        var newPath = ""
        if paths.count == 3 {
            newPath = "\(paths.first ?? "")" + ".\(paths.last ?? "")"
        }
        return newPath
    }
    
    //
    func isDownloadSuccess() -> Bool {
        let boxFileMd5 = self.toFileUrl?.toMD5()
        if let urlPathMd5 = self.downloadUrlMD5, urlPathMd5.count == 8 {//文件md5后缀必须是8位
            return ((boxFileMd5?.has(urlPathMd5,option: .caseInsensitive)) != nil)
        }
        return false
    }
    
    //获取URL包含的md5值-
    var downloadUrlMD5: String? {
        let filepath = self
        let components = filepath.components(separatedBy: ".")
        if components.count >= 3 {
            return components[components.count - 2]
        }
        return nil
    }

}
