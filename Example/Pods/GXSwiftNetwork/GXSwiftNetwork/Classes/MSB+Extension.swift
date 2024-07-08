////
////  MSB+Extension.swift
////  MSBAlamofire
////
////  Created by 李响 on 2022/1/11.
////
//
//import UIKit
//import Alamofire
//import Moya
////import SwiftyUserDefaults
//
///// 两个字典相加 +
internal func + (left: [String: String], right: [String: String]) -> [String: String] {
    var dic = left
    for (k, v) in right { dic[k] = v }
    return dic
}
//
///// 打印日志
internal func log(_ msg: Any, _ file: String = #file, _ fn: String = #function, _ line: Int = #line) {
    #if DEBUG
    print("「 DEBUG模式下打印日志： 」****** \((file as NSString).lastPathComponent) >> \(line) >> \(fn) >> \(msg) ******")
    #endif
}
//
//public protocol MSBRelativeModel {
//   
//    @available(*, deprecated, message: "注意⚠️ 将要废弃")
//    func updateToRelativeModel(_ comp: @escaping () -> Void)
//  
//    @available(*, deprecated, message: "注意⚠️ 将要废弃")
//    func updateArray(_ arr: [MSBRelativeModel], _ comp: @escaping () -> Void)
//}
//
//extension MSBRelativeModel {
//  
//    @available(*, deprecated, message: "注意⚠️ 将要废弃")
//    public func updateArray(_ arr: [MSBRelativeModel], _ comp: @escaping () -> Void) {
//        
//        func getModelByIndex(_ index: Int) {
//            guard index < arr.count else {
//                comp()
//                return
//            }
//            arr[index].updateToRelativeModel({
//                getModelByIndex(index + 1)
//            })
//        }
//        getModelByIndex(0)
//    }
//}
//
//extension Array: MSBRelativeModel where Element: MSBRelativeModel {
//   
//    @available(*, deprecated, message: "注意⚠️ 将要废弃")
//    public func updateToRelativeModel(_ comp: @escaping () -> Void) {
//        guard self.count > 0 else {
//            comp()
//            return
//        }
//        self.first?.updateArray(self, comp)
//    }
//}
//
////public extension DefaultsKeys {
////   
////    static let token = DefaultsKey<String?> ("msb_token")
////    static let tmpToken = DefaultsKey<String?> ("msb_tmp_token")
////    static let tokenTime = DefaultsKey<String?>("msb_token_time")
////    /// 用于防止退出登录后，其它还未返回的接口，返回时携带token
////    static let tryToLoginTime = DefaultsKey<Int?> ("msb_tmp_try_login_time")
////}
//
