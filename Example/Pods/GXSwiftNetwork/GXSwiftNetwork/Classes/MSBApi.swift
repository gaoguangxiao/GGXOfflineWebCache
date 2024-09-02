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
 let api = CerCozeApi()
 let reponseResult = try await api.dataTask(with:CozeResponseModel.self)
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
    var requestUrl: String?
    var requestPath: String
    var requestHeaders: [String: String]?
    var requestMethod: Moya.Method
    var requestSampleData: String
    var requestParameters: [String: Any]
    var requestShowErrorMsg: Bool
    var requestShowHUD: Bool
    
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
        
        log("********request requestParameters=\(requestParameters)***********")
        log("********request sampleData=\(sampleData)***********")
    }
    
    public init(url: String?,
                path: String = "",
                method: Moya.Method = .get,
                headers:[String: String]? = nil,
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
        
        log("********request requestParameters=\(requestParameters)***********")
        log("********request sampleData=\(sampleData)***********")
    }
    
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
}

//MARK:
extension MSBApi {
    
    @available(iOS 13.0, *)
    public func request<T: SmartCodable>(_ Model: T.Type) async throws -> T where T: SmartCodable {
        if self.requestShowHUD {
            DispatchQueue.main.async {
                HUD.show(.label("加载中..."))
            }
        }
        return try await withCheckedThrowingContinuation{ continuation in
            self.provider.request(self) { result in
                DispatchQueue.main.async {
                    HUD.hide(animated: true)
                }
                switch result {
                case let .success(response):
                    do {
                        let response = try response.filter(statusCodes: 200...499)
                        let jsonObject = try response.mapString()
                        log("**************response data = \(jsonObject)**************")
                        let model = Model.deserialize(from: jsonObject, designatedPath: "")
                        guard let model else {
                            continuation.resume(throwing: NSError(domain: "network", code: response.statusCode,userInfo: ["msg": "数据解析失败"]))
                            return
                        }
                        continuation.resume(returning: model)
                    } catch let error {
                        // HTTP statuc code error or json parsing error.
                        if self.requestShowErrorMsg {
                            HUD.flash(.label(error.localizedDescription), delay: 1.5)
                        }
                        continuation.resume(throwing: error)
                    }
                case let .failure(error):
                    if self.requestShowErrorMsg {
                        HUD.flash(.label(error.localizedDescription), delay: 1.5)
                    }
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    @available(iOS 13.0, *)
    public func dataTask<T: SmartCodable>(with model: T.Type) async throws -> MSBBaseModel<T> where T: SmartCodable {
        do {
            let model = try await self.request(MSBBaseModel<T>.self)
            if self.requestShowErrorMsg, let msg = model.msg, msg.count > 0 {
                await MainActor.run { HUD.flash(.label(msg), delay: 2.5) }
            }
            return model
        } catch {
            if self.requestShowErrorMsg {
                await MainActor.run { HUD.flash(.label(error.localizedDescription), delay: 2.5) }
            }
            throw error
        }
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
            request.cachePolicy = .reloadRevalidatingCacheData //如果本地缓存有效时，则不下载。否则，从新下载数据。
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
    
    public var path: String { 
        requestPath
    }
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

protocol CachePolicyGettable {
    var cachePolicy: URLRequest.CachePolicy {get}
}

//extension MSBApi: CachePolicyGettable {
//    var cachePolicy: URLRequest.CachePolicy {
//        switch self {
//        case .:
//            
//        default:
//            <#code#>
//        }
//    }
//}

// MARK: =================== providers
extension MSBApi {
    
    static let providerLogPlugin = NetworkLoggerPlugin()
//    static let streamProvider = NetworkStreamProvider()
//    static let providerActivityPlugin = NetworkActivityPlugin(networkActivityClosure: T##NetworkActivityClosure)
    static let silenceProvider = MoyaProvider<MSBApi>(plugins: [])
    static let verboseProvider = MoyaProvider<MSBApi>(plugins: [providerLogPlugin])
    static let mockProvider = MoyaProvider<MSBApi>(stubClosure: MoyaProvider.immediatelyStub)
    // 扩展一个可以设置超时的请求
    fileprivate static let outTimeProvider = MoyaProvider<MSBApi>(requestClosure: MSBApi.requestClosure,plugins: [])
//    static let cachePlugin = CachePolicyPlugin()
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
    
    public class func showApiError(_ error: MSBApiError) {
        MSBApiConfig.shared.showHUDAbility?(error)
    }
    
    /// show toast and log error
    public class func handleError(_ err: MSBApiError) {
        MSBApi.defaultFailureHandle(err)
    }
    
    public func reportError(error: MSBApiError) -> Bool { true }
    
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
