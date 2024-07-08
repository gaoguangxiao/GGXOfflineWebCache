//
//  Array+extension.swift
//  wisdomstudy
//
//  Created by ggx on 2017/8/9.
//  Copyright © 2017年 高广校. All rights reserved.
//

import Foundation

public extension Array {
    
    /// Removes elements from an array that meet a specific condition
    func removeElement<T: Equatable>(item: T, from array: inout [T]) {
        array.removeAll { $0 == item }
    }
    
}
