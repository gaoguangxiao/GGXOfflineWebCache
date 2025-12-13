//
//  GXWebOfflineAssetsModel.swift
//  RSBridgeNetCache
//
//  Created by 高广校 on 2024/1/5.
//

import Foundation
import SmartCodable

public class GXWebOfflineAssetsModel: SmartCodable {
    
    /// 如果不写域名，默认使用 {www_path}
    public var src: String? //
     
    /// 文件内容 md5 的前 8 位
    public var md5: String?

    /// 资源获取策略 支持 0、2、3 默认3。【20251213 修改，支持瑞思家配置离线json策略`policy`为空问题】
    /// 0：忽视本地缓存，从远端获取；
    /// 2：有限读取本地，异步更新本地
    /// 3：优先读取本地缓存，在没有创建缓存时使用网络，同时创建缓存
    /// 当匹配到请求之后直接从 Cache 缓存中取得结果，如果 Cache 缓存中没有结果，那就会发起网络请求，拿到网络请求结果并将结果更新至 Cache 缓存，并将结果返回给客户端。这种策略比较适合结果不怎么变动且对实时性要求不高的请求。
    public var policy = 3
    
    /// 这个代码块的意思是：从 src 获取资源，使用 md5 进行校验，资源获取策略是 1，当拦截的网络请求 match 正则时一律返回 src 的资源
    /// 需要先对正则中的 {www_path} 占位符做替换，替换规则参考：附1
    public var match: String?
    
    
    /// 本地全路径-通过本地查找得到
    public var localFullFilePath: String?
 
    /// 文件大小
    public var size: String?
    
    public var isUsable = false
    
    /// 初始化
    required public init(){}
}

extension GXWebOfflineAssetsModel {
    
    public static func mappingForKey() -> [SmartKeyTransformer]? {
        [CodingKeys.src <--- ["src", "url"]]
    }
}
