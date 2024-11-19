//
//  ZKTaskThreadTool.swift
//  ZKBaseSwiftProject
//
//  Created by 高广校 on 2023/11/16.
//

import Foundation


public func addTaskToMainThread(_ task: @escaping ()->()) {
    if Thread.isMainThread {
        task()
    } else {
        DispatchQueue.main.async {
            task()
        }
    }
}
