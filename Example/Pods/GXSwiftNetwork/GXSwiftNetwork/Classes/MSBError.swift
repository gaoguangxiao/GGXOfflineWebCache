//
//  MSBError.swift
//  MSBAlamofire
//
//  Created by 李响 on 2022/1/12.
//

import UIKit
import Alamofire
import Moya

public class MSBApiError: MSBRespApiModel {
//    public var code: Int = 0
//    public var msg: String?
//    public var alreadyDecoedObj: Any?
//    public init(status: Int, alreadyDecoedObj: Any? = nil) {
//        self.status = status
////        super.msg = msg ?? ""
//        self.alreadyDecoedObj = alreadyDecoedObj
//    }
    
//    public override var description: String {
//        return "[MSBApiError] \(status): \(msg ?? "")"
//    }
}

extension AFError {
   
    public var originalError: String? {
        switch self {
        case let .sessionTaskFailed(error):
            return error.localizedDescription
        default:
            return nil
        }
    }
}

extension MoyaError {
 
    public var msbDes: String? {
        switch self {
        case .underlying(let error, _):
            return (error as? AFError)?.originalError
        default:
            return nil
        }
    }
}
