//
//  MoyaProvider.swift
//  Created by 李响 on 2022/1/10.

//

import Foundation
import Moya
//import SwiftyUserDefaults
import Alamofire
import PKHUD
import SmartCodable

// MARK: - request MoyaProvider
extension MoyaProvider {

    /// 解析成想要的model类
    internal func request<T: MSBApiModel>( _ target: Target,
                                         _ rTarget:MSBApi,
                                           onFailure: @escaping (MSBRespApiModel) -> Void,
                                           onSuccess: @escaping (T) -> Void,
                                        fullResponse: ((Moya.Response) -> Void)? = nil) {
//        let markedLoginTime = Defaults[.tryToLoginTime]
        
        func check401Fail(_ error: MSBRespApiModel) {
            if error.code == 401 || error.code == 1022 ||
                error.code == 40001 || error.code == 40003  {
                MSBApiConfig.shared.tokenInvalidateCallBack?()
            }
            onFailure(error)
        }
        
        if rTarget.requestShowHUD {
            HUD.show(.label("加载中..."))
        }
        self.request(target) { result in
            HUD.hide(animated: true)
            switch result {
            case let .success(response):
                fullResponse?(response)
                do {
                    let response = try response.filterSuccessfulStatusCodes()
                    let jsonObject = try response.mapJSON() as? [String: Any]
                    log("**************response data = \(jsonObject ?? [:])**************")
                    let model = T.deserialize(from: jsonObject, designatedPath: "")
                    
                    //解析具体数据
                    if let isSu = model?.success , isSu == false ,rTarget.requestShowErrorMsg{
                        let msg = model?.msg
                        HUD.flash(.label(msg), delay: 1.5)
                    }
                    guard let model else {
                        let apiError = MSBRespApiModel(code: response.statusCode, msg: "数据解析失败")
                        check401Fail(apiError)
                        return
                    }
//                    model.response = response.response
//                    model.respData = response.data
                    
                    onSuccess(model)
                } catch let error {
                    // HTTP statuc code error or json parsing error.
                    var errorMessage = ""
                    switch response.statusCode {
                    case 300...399:
                        errorMessage = "Redirection"
                    case 400...499:
                        errorMessage = "Client Errors"
                    case 500...599:
                        errorMessage = "Server Errors"
                    default:
                        errorMessage = error.localizedDescription
                    }
                    if rTarget.requestShowErrorMsg {
                        HUD.flash(.label(errorMessage), delay: 1.5)
                    }
                    let apiError = MSBRespApiModel(code: response.statusCode, msg: errorMessage)
                    check401Fail(apiError)
                }
            case let .failure(moyaError):
                // Moya request error, possibly due to unreachable network.
                let nsError = moyaError as NSError
                let msg = moyaError.msbDes != nil ? moyaError.msbDes : nsError.localizedDescription
                onFailure(MSBRespApiModel(code: nsError.code, msg: msg ?? ""))
            }
        }
    }
    
    /// 解析遵循`SmartCodable`的协议的结构体或者类
    internal func request<T: SmartCodable>( _ target: Target,
                                         _ rTarget:MSBApi,
                                           onFailure: @escaping (MSBRespApiModel) -> Void,
                                           onSuccess: @escaping (T) -> Void,
                                        fullResponse: ((Moya.Response) -> Void)? = nil) {
        if rTarget.requestShowHUD {
            DispatchQueue.main.async {
                HUD.show(.label("加载中..."))
            }
        }
        
        self.request(target) { result in
            DispatchQueue.main.async {
                HUD.hide(animated: true)
            }
            switch result {
            case let .success(response):
                fullResponse?(response)
                do {
                    let response = try response.filterSuccessfulStatusCodes()
                    let jsonObject = try response.mapJSON() as? [String: Any]
                    log("**************response data = \(jsonObject ?? [:])**************")
                    let model = T.deserialize(from: jsonObject, designatedPath: "")
                    guard let model else {
                        let apiError = MSBRespApiModel(code: response.statusCode, msg: "数据解析失败")
                        onFailure(apiError)
                        return
                    }
                    onSuccess(model)
                } catch let error {
                    // HTTP statuc code error or json parsing error.
                    var errorMessage = ""
                    switch response.statusCode {
                    case 300...399:
                        errorMessage = "Redirection"
                    case 400...499:
                        errorMessage = "Client Errors"
                    case 500...599:
                        errorMessage = "Server Errors"
                    default:
                        errorMessage = error.localizedDescription
                    }
                    if rTarget.requestShowErrorMsg {
                        HUD.flash(.label(errorMessage), delay: 1.5)
                    }
                    let apiError = MSBRespApiModel(code: response.statusCode, msg: errorMessage)
                    onFailure(apiError)
                }
            case let .failure(moyaError):
                // Moya request error, possibly due to unreachable network.
                let nsError = moyaError as NSError
                let msg = moyaError.msbDes != nil ? moyaError.msbDes : nsError.localizedDescription
                onFailure(MSBRespApiModel(code: nsError.code, msg: msg ?? ""))
            }
        }
    }
    
    //解析流式数据
    internal func requestStream<T: SmartCodable>( _ target: Target,
                                         _ rTarget:MSBApi,
                                           onFailure: @escaping (MSBRespApiModel) -> Void,
                                           onSuccess: @escaping (T) -> Void,
                                        fullResponse: ((Moya.Response) -> Void)? = nil) {
        if rTarget.requestShowHUD {
            DispatchQueue.main.async {
                HUD.show(.label("加载中..."))
            }
        }
        
        self.request(target) { result in
            DispatchQueue.main.async {
                HUD.hide(animated: true)
            }
            switch result {
            case let .success(response):
                fullResponse?(response)
                do {
                    let response = try response.filterSuccessfulStatusCodes()
                    let jsonObject = try response.mapString()
                    log("**************response data = \(jsonObject)**************")
                    let model = T.deserialize(from: jsonObject, designatedPath: "")
                    guard let model else {
                        let apiError = MSBRespApiModel(code: response.statusCode, msg: "数据解析失败")
                        onFailure(apiError)
                        return
                    }
                    onSuccess(model)
                } catch let error {
                    // HTTP statuc code error or json parsing error.
                    var errorMessage = ""
                    switch response.statusCode {
                    case 300...399:
                        errorMessage = "Redirection"
                    case 400...499:
                        errorMessage = "Client Errors"
                    case 500...599:
                        errorMessage = "Server Errors"
                    default:
                        errorMessage = error.localizedDescription
                    }
                    if rTarget.requestShowErrorMsg {
                        HUD.flash(.label(errorMessage), delay: 1.5)
                    }
                    let apiError = MSBRespApiModel(code: response.statusCode, msg: errorMessage)
                    onFailure(apiError)
                }
            case let .failure(moyaError):
                // Moya request error, possibly due to unreachable network.
                let nsError = moyaError as NSError
                let msg = moyaError.msbDes != nil ? moyaError.msbDes : nsError.localizedDescription
                onFailure(MSBRespApiModel(code: nsError.code, msg: msg ?? ""))
            }
        }
    }
}
