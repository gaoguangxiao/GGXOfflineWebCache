//
//  ZKAudioTool.swift
//  RSReading
//
//  Created by 高广校 on 2023/9/18.
//

import UIKit
import AVFoundation
import GGXSwiftExtension

public class ZKAudioTool: NSObject {

    public static func audioDurationFromUrl(url:String) -> Float64 {
        _ = [AVURLAssetPreferPreciseDurationAndTimingKey:true]
        var audioAsset : AVURLAsset?
        if url.contains("http"){
            guard let uurl = url.toUrl else { return 0}
            audioAsset = AVURLAsset(url:uurl)
        } else if let uurl = url.toFileUrl {
            audioAsset = AVURLAsset(url: uurl)
        }
        if let duration = audioAsset?.duration {
            return CMTimeGetSeconds(duration)
        }
        return 0
    }
}
