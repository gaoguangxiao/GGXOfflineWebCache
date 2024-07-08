//
//
//  Created by 李响 on 2022/1/10.

//

import Foundation
import Moya
import Alamofire
//import SwiftyUserDefaults
import UIKit
import PKHUD
import SmartCodable
/* 使用方法：
 - 定义
 class exampleApi: BearShowApi {
 init(id: String) {
 super.init(path: "/xxx/xxx/xxxx", method: .post, parameters: ["worksId" : id])
 }
 
 struct resultModel: Codable {
 var checkResult: String
 }
 }
 
 - 调用
 exampleApi(id: "\(workID)").request(success: { (response: exampleApi.resultModel) in
 log("成功结果: \(response.checkResult)")
 })
 - 或
 exampleApi(id: "\(workID)").request(success: { (response: exampleApi.resultModel) in
 log("成功结果: \(response.checkResult)")
 }, failure: { error in
 // 自己处理Fail
 })
 
 */

open class MSBApi: TargetType {
    
    open var mock: Bool { false }
    open var verbose: Bool { false }
    public static var requestTimeoutInterval: Float?
    open var requestUrl: String?
    open var requestPath: String
    open var requestHeaders: [String: String]?
    open var requestMethod: Moya.Method
    open var requestSampleData: String
    open var requestParameters: [String: Any]
    open var requestShowErrorMsg: Bool
    open var requestShowHUD: Bool
    
    public init(path: String,
                method: Moya.Method = .get,
                parameters: [String: Any] = [:],
                sampleData: String = "",
                timeout: Float = MSBApiConfig.shared.timeoutInterval,
                showErrorMsg:Bool = false,
                showHud:Bool = true) {
//        requestUrl = url
        requestPath = path
        requestMethod = method
        requestParameters = parameters
//        requestHeaders    = headers
        MSBApi.requestTimeoutInterval = timeout
        requestSampleData = sampleData
        requestShowErrorMsg      = showErrorMsg
        requestShowHUD   = showHud
    }
    
    public init(url: String?,
                path: String,
                method: Moya.Method = .get,
                headers:[String: String]?,
                parameters: [String: Any] = [:],
                sampleData: String = "",
                showErrorMsg:Bool = false,
                showHud:Bool = false) {
        requestUrl = url
        requestPath = path
        requestMethod = method
        requestParameters = parameters
        requestHeaders    = headers
        requestSampleData = sampleData
        requestShowErrorMsg      = showErrorMsg
        requestShowHUD   = showHud
    }
    //    //获取自定义json Decodable数据
    //    open func request<T: Decodable>(success: @escaping ((T) -> Void),
    //                                    failure: @escaping ((MSBApiError) -> Void) = defaultFailureHandle,
    //                                    provider: MoyaProvider<MSBApi>? = nil,
    //                                    atKeyPath: String? = nil,
    //                                    fullResponse: ((Moya.Response) -> Void)? = nil) {
    //        var useProvider = self.provider
    //        if let paramProvider = provider {
    //            useProvider = paramProvider
    //        }
    //        let logPosition = requestPath
    //        useProvider.request(self, onFailure: { error in
    //            if self.reportError(error: error) {
    //                MSBApiConfig.shared.reportBuglyAbility?(error.status, ["网络错误":error.msg ?? "未知错误"])
    //                log("❌ 【API】status:\(error.status) msg:\(error.msg ?? "") path: \(logPosition)")
    //            }
    //            failure(error)
    //        }, onSuccess: { result in
    //            success(result)
    //        }, atKeyPath: atKeyPath, fullResponse: fullResponse)
    //    }
    
    /// 获取自定义json model数据
    open func request<T: MSBApiModel>(onSuccess: @escaping (T) -> Void,
                                      onFailure: @escaping (MSBRespApiModel) -> Void,
                                      provider: MoyaProvider<MSBApi>? = nil,
                                      fullResponse: ((Moya.Response) -> Void)? = nil) {
        var useProvider = self.provider
        if let paramProvider = provider {
            useProvider = paramProvider
        }
        
        useProvider.request(self, self, onFailure: onFailure, onSuccess: onSuccess)
    }
    
    open func request<T: SmartCodable>(onSuccess: @escaping (T) -> Void,
                                      onFailure: @escaping (MSBRespApiModel) -> Void,
                                      provider: MoyaProvider<MSBApi>? = nil,
                                      fullResponse: ((Moya.Response) -> Void)? = nil) {
        var useProvider = self.provider
        if let paramProvider = provider {
            useProvider = paramProvider
        }
        
        useProvider.request(self, self, onFailure: onFailure, onSuccess: onSuccess)
    }
    
    open func requestStream<T: SmartCodable>(onSuccess: @escaping (T) -> Void,
                                      onFailure: @escaping (MSBRespApiModel) -> Void,
                                      provider: MoyaProvider<MSBApi>? = nil,
                                      fullResponse: ((Moya.Response) -> Void)? = nil) {
        var useProvider = self.provider
        if let paramProvider = provider {
            useProvider = paramProvider
        }
//        useProvider.s
        useProvider.requestStream(self, self, onFailure: onFailure, onSuccess: onSuccess)
    }
    
}

// MARK: ==== Closure
extension MSBApi {
    
    private static let requestClosure = { (endpoint: Endpoint, 
                                           done: MoyaProvider.RequestResultClosure) in
        do {
            var request = try endpoint.urlRequest()
            /// 设置超时时间
            if let outTimer = MSBApi.requestTimeoutInterval {
                request.timeoutInterval = TimeInterval(outTimer)
            } else {
                request.timeoutInterval =  TimeInterval(MSBApiConfig.shared.timeoutInterval)
            }
            done(.success(request))
            
        } catch  {
            done(.failure(MoyaError.underlying(error, nil)))
        }
    }
}

// MARK: =================== TargetType
extension MSBApi {
    public var baseURL: URL {
        var apiHost: String?
        if let requestUrl = requestUrl {
            apiHost = requestUrl
        } else if let requestUrl = MSBApiConfig.shared.getApiHost?() {
            apiHost = requestUrl
        }
        guard let apiHost = apiHost, let url = URL(string: apiHost) else {
            fatalError("BaseURL could not be configured.")
        }
        return url
    }
    
    public var headers: [String: String]? {
        var _headers: [String: String]?
        if let requestHeaders = requestHeaders {
            _headers = requestHeaders
        } else if let requestHeaders = MSBApiConfig.shared.headers {
            _headers = requestHeaders
        }
        if let _headers = _headers {
            print("********request headers=\(_headers)***********")
            return _headers
        }
        return [:]
    }
    
    public var path: String { requestPath }
    public var method: Moya.Method { requestMethod }
    public var sampleData: Data { requestSampleData.data(using: String.Encoding.utf8) ?? Data() }
    //    public var showErrorMsg: Bool { requestShowErrorMsg }
    public var task: Task {
    
        if !requestParameters.keys.isEmpty {
            
            return .requestParameters(parameters: requestParameters, encoding: URLEncoding.default)
            //
        } else if !sampleData.isEmpty{
            return .requestData(sampleData)
        } else {
            return .requestPlain
        }
    }
}

// MARK: =================== providers
extension MSBApi {
    
    static let providerLogPlugin = NetworkLoggerPlugin()
//    static let streamProvider = NetworkStreamProvider()
//    static let providerActivityPlugin = NetworkActivityPlugin(networkActivityClosure: <#T##NetworkActivityClosure#>)
    static let silenceProvider = MoyaProvider<MSBApi>(plugins: [])
    static let verboseProvider = MoyaProvider<MSBApi>(plugins: [providerLogPlugin])
    static let mockProvider = MoyaProvider<MSBApi>(stubClosure: MoyaProvider.immediatelyStub)
    // 扩展一个可以设置超时的请求
    fileprivate static let outTimeProvider = MoyaProvider<MSBApi>(requestClosure: MSBApi.requestClosure,plugins: [])
    
    var provider: MoyaProvider<MSBApi> {
        if MSBApiConfig.shared.getIsDebug?() != true {
            return MSBApi.silenceProvider
        } else if mock {
            return MSBApi.mockProvider
        } else if verbose {
            return MSBApi.verboseProvider
        } else {
            return MSBApi.outTimeProvider
        }
    }
}

// MARK: =================== 内部函数调用
extension MSBApi {
    
    public static let defaultFailureHandle: ((MSBApiError) -> Void) = { err in
        MSBApiConfig.shared.dismissHUDAbility?()
        showApiError(err)
    }
    
    open class func showApiError(_ error: MSBApiError) {
        MSBApiConfig.shared.showHUDAbility?(error)
    }
    
    /// show toast and log error
    public class func handleError(_ err: MSBApiError) {
        MSBApi.defaultFailureHandle(err)
    }
    
    open func reportError(error: MSBApiError) -> Bool { true }
    
}

/// 扩展moya 支持 array参数
struct JSONArrayEncoding: ParameterEncoding {
    static let `default` = JSONArrayEncoding()
    
    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        
        var request = try urlRequest.asURLRequest()
        guard let json = parameters else { return request }
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        if request.value(forHTTPHeaderField: "Content-Type") == nil {
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        }
        request.httpBody = data
        return request
    }
}
