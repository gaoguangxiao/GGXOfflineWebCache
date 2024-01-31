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
}
