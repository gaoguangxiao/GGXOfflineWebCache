//
//  ZKBaseViewModel.swift
//  ZKBaseSwiftProject
//
//  Created by 高广校 on 2025/10/31.
//

import Foundation

open class ZKBaseViewModel<T>: NSObject {
    
    required public override init() { }
    
    public var bindModel: T?
}
