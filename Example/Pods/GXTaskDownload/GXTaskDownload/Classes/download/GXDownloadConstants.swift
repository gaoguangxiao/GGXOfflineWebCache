//
//  GXConstants.swift
//  GXTaskDownload
//
//  Created by 高广校 on 2024/1/10.
//

import Foundation

public let gxdownloadService = "http://121.199.164.220:8080"

public typealias GXTaskDownloadBlock = (_ progress: Float ,_ state: GXDownloadingState)->Void

public typealias GXTaskDownloadSpeedBlock = (_ speed: Double,
                                             _ loaded: Double,
                                             _ total: Double)->Void

public typealias GXTaskDownloadTotalBlock = (_ total: Float,
                                             _ loaded: Float,
                                             _ state: GXDownloadingState)->Void

public typealias GXTaskCheckBlock = (Int64) -> Void

/// 校验文件
public typealias GXProgressStateBlock = (_ progress: Float,Bool) -> Void

/// 校验文件
public typealias GXTaskCheckProgressBlock = (_ progress: Float, _ totalLenth: Int64) -> Void

/// 下载完毕
public typealias GXTaskCompleteBlock = (_ progress: Float, _ str: String?,_ state: GXDownloadingState)->Void

/// 下载完毕
public typealias GXTaskCompleteV2Block = (_ progress: Float, _ str: String?)->Void
