//
//  MSBRespApiModel.swift
//  GXSwiftNetwork
//
//  Created by 高广校 on 2023/12/28.
//

import Foundation
import HandyJSON

open class MSBRespApiModel: NSObject , HandyJSON{
    open var response: HTTPURLResponse?
    open var respData: Data?
    
    open var code : Int = 0 //业务端代码
    open var msg: String?
    
    required public override init() {
        
    }
    
    init(respData: Data? = nil, code: Int, msg: String) {
        self.respData = respData
        self.code = code
        self.msg = msg
    }
}
