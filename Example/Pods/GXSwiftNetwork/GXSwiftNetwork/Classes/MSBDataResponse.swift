//
//  MSBDataResponse.swift
//  GXSwiftNetwork
//
//  Created by 高广校 on 2024/7/24.
//

import Foundation

@available(iOS 13.0.0, *)
public protocol MSBDataResponse {
 
    //要解析的`Model`
    associatedtype Model
    
    //调用方对每个接口做出响应，抛出错误
    static func response() async throws -> Model?
    
    static func response(sampleData: String) async throws -> Model?
    
    static func response(parameters: [String: Any]) async throws -> Model?
}

@available(iOS 13.0.0, *)
extension MSBDataResponse {
    
    public static func response() async throws -> Model? {
        return nil
    }
    
    public static func response(sampleData: String) async throws -> Model? {
        return nil
    }
    
    public static func response(parameters: [String: Any]) async throws -> Model? {
        return nil
    }
}
