//
//  Array+extension.swift
//  wisdomstudy
//
//  Created by ggx on 2017/8/9.
//  Copyright © 2017年 高广校. All rights reserved.
//

import Foundation

extension Array {
    /// Removes elements from an array that meet a specific condition
     public func removeElement<T: Equatable>(item: T, from array: inout [T]) {
        array.removeAll { $0 == item }
    }
}

extension Array  {
    
    /// Serializes into a JSON string
    /// - Parameter prettyPrint: Whether to format print (adds line breaks in the JSON)
    /// - Returns: JSON string
    public func toJSONString(prettyPrint: Bool = false) -> String? {
        if JSONSerialization.isValidJSONObject(self) {
            do {
                let options: JSONSerialization.WritingOptions = prettyPrint ? [.prettyPrinted] : []
                let jsonData = try JSONSerialization.data(withJSONObject: self, options: options)
                return String(data: jsonData, encoding: .utf8)
            } catch {
                return nil
            }
        } else {
            return nil
        }
    }
}
