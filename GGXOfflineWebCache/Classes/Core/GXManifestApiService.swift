//
//  GXManifestApiService.swift
//  RSBridgeOfflineWeb
//
//  Created by 高广校 on 2024/1/2.
//

import Foundation
import GXSwiftNetwork

class ManiFestApi: MSBApi {
    
    init(url: String) {
        //
        super.init(url: url, path: "", headers: nil)
    }
}

public class GXManifestApiService: NSObject {
    
    
    /// 读取JSON文件
    /// - Parameters:
    ///   - url: json地址
    ///   - closure: json数据结构 {"version":"1.0.0","assets":[]}
    public static func requestManifestJSON(url: String,closure: @escaping ((GXWebOfflineManifestModel?) -> ())) {
        let api = GXHybridRequest()
        guard let uurl = url.toUrl else {
            closure(nil)
            return
        }
        api.sendHyUrl(url: uurl) { data, res, errro in
            if let result = GXWebOfflineManifestModel.deserialize(from: data) {
                closure(result)
            } else {
                closure(nil)
            }
        }
    }
    
    public static func requestManifestApi(url: String,closure: @escaping ((GXWebOfflineManifestModel?) -> ())) {
        let api = ManiFestApi(url: url)
        api.request { (result: GXWebOfflineManifestBaseModel?) in
            closure(result?.ydata)
        } onFailure: { _ in
            closure(nil)
        }
    }
}
