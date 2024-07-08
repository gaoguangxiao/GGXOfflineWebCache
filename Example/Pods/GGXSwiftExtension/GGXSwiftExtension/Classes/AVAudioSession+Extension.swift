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
}
