//
//  AVAudioSession+Extension.swift
//  GGXSwiftExtension
//
//  Created by 高广校 on 2024/6/27.
//

import AVFAudio

public extension AVAudioSession {
    
    static func setAVAudioSession(category: Category) throws {
        
        if AVAudioSession.sharedInstance().category != AVAudioSession.Category.playAndRecord  {
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, options: [.defaultToSpeaker, .allowBluetooth, .allowAirPlay, .allowBluetoothA2DP])
            } catch let e{
                throw e
            }
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let e {
            throw e
        }
    }
    
    //检查类别的条件不一定能反映完整的会话状态
    //        可能的错误原因
    //        资源冲突：某些设备或系统应用正在占用音频资源，导致无法激活会话
    //        选项冲突：选项配置可能不被设备或系统完全支持
    //        中断未恢复：中断而被停止
    static func configureAudioSessionForPlayAndRecord() throws {
        let audioSession = AVAudioSession.sharedInstance()

        do {
            // 检查当前类别并重新设置
//            if audioSession.category != .playAndRecord {
                try audioSession.setCategory(.playAndRecord, options: [
                    .defaultToSpeaker,
                    .allowBluetooth,
                    .allowAirPlay,
                    .allowBluetoothA2DP
                ])
//                print("AVAudioSession 类别已设置为 playAndRecord")
//            }
            // 激活音频会话
            try audioSession.setActive(true)
            print("AVAudioSession 已激活")
        } catch {
            // 捕获和打印错误信息
            print("设置 AVAudioSession 失败: \(error.localizedDescription)")
            throw error
        }
    }

    static func configureAudioSessionForPlayback() throws {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            // 设置音频会话为播放模式，不涉及录音
            try audioSession.setCategory(.playback, options: [
//                .allowBluetooth,     // 如果允许通过蓝牙播放
//                .allowAirPlay        // 如果允许通过 AirPlay 播放
            ])
            
            // 激活音频会话
            try audioSession.setActive(true)
//            print("AVAudioSession 已激活为 playback 模式")
        } catch {
            print("configureAudioSessionForPlayback 配置 AVAudioSession 失败: \(error.localizedDescription)")
            throw error
        }
    }
}
