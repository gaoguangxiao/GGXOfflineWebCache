//
//  GXWebOfflineManifestModel.swift
//  GGXOfflineWebCache
//
//  Created by 高广校 on 2024/1/24.
//

import Foundation
import GXSwiftNetwork
import SmartCodable

public class GXWebOfflineManifestBaseModel: MSBApiModel {
    /// 具体的数据
//    public var data: GXWebOfflineManifestModel?
    ///
    var ydata: GXWebOfflineManifestModel? {
        return GXWebOfflineManifestModel.deserialize(from: data as? Dictionary<String, Any>)
    }
}

public class GXWebOfflineManifestModel: SmartCodable {
    
    /// manifest 格式的版本号
    public var version: String?
    
    /// 要加载的页面及资源
    public var assets: Array<GXWebOfflineAssetsModel>?
    
    /// 初始化
    required public init(){}
}

extension GXWebOfflineManifestModel {
    
    public var versionSize: Double {
        let newVersion = self.version?.replace(".", new: "")
        return newVersion?.toDouble() ?? 0
    }
    
}
