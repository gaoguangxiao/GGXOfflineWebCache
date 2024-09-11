//
//  GXDownloadURLModel.swift
//  GXTaskDownload
//
//  Created by 高广校 on 2024/1/23.
//

import Foundation
import SmartCodable

public class GXDownloadURLModel: NSObject ,SmartCodable {
    
    required public override init() {
        super.init()
//        fatalError("init() has not been implemented")
    }
    
    /// 如果不写域名，默认使用 {www_path}
    public var src: String? //
    
    /// 文件内容 md5 的前 8 位
    public var md5: String?
    
    /// URL的缓存策略
    public var policy: Int?
    
    /// URL下载优先级
    public var priority: Int = 3
    
    /// URL信息存储-名 默认src全路径的md5.json
    public var info: String?
    
    public var match: String?
    
    // 文件大小
    public var size: Double = 1.0
    
    /// 资源是否可用
    public var isUsable = false
}
