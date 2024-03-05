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
    
    public static func requestManifest(url: String,closure: @escaping ((GXWebOfflineManifestModel?) -> ())) {
        let api = ManiFestApi(url: url)
        api.request { (result: GXWebOfflineManifestModel?) in
            closure(result)
        } onFailure: { _ in
            closure(nil)
        }
    }
    
    public static func requestManifestApi(url: String,closure: @escaping ((GXWebOfflineManifestModel?) -> ())) {
        let api = ManiFestApi(url: url)
        api.request { (result: GXWebOfflineManifestBaseModel?) in
            closure(result?.data)
        } onFailure: { _ in
            closure(nil)
        }
    }
}
