//
//  MSBApiModel.swift
//  RSReading
//
//  Created by 高广校 on 2023/9/19.
//

import Foundation
import SmartCodable

open class MSBApiModel: SmartCodable {
    required public init() { }
    
    @SmartAny
    open var data: Any?
    
    open var success : Bool = false
    open var msg : String?
    open var code : Int = 0 //业务端代码
}
