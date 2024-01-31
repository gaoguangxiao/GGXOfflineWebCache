//
//  GXVersionUpdateTool.swift
//  KidReading
//
//  Created by zoe on 2019/8/12.
//  Copyright © 2019 putao. All rights reserved.
//

import Foundation
//import RSBridgeOfflineWeb
import GGXSwiftExtension

enum PTVersionCompare {
    case None
    case Equal
    case Descending
    case Ascending //升级
}

enum PTVersionUpdateStatus {
    case None
    case Optional
    case Force
}

let kVersionUpdateLayerTag = 1777
let kVersionIntervalTime: Int =  60 * 60;
let kCancelUpdateTime = "cancelUpdateTime"


public class GXVersionUpdateTool {
    
    static public var updateButtonEvent :((Bool)-> Void )? = nil
    
    static func compareVersion(v1 : String , v2 : String) -> PTVersionCompare {
        
        if v1.isEmpty || v2.isEmpty {
            return PTVersionCompare.None
        }
        
        let components1 = v1.components(separatedBy: ".")
        let components2 = v2.components(separatedBy: ".")

        let length = components1.count > components2.count ? components2.count : components1.count
        
        for index in 0 ..< length {
            let stringNumber1 = components1[index] as NSString
            let stringNumber2 = components2[index] as NSString
            if stringNumber1.intValue > stringNumber2.intValue {
                return  PTVersionCompare.Descending
            } else if stringNumber1.intValue < stringNumber2.intValue {
                return  PTVersionCompare.Ascending
            } else {
                continue
            }
        }

        let gap = components1.count - components2.count
        if gap != 0 {
            let components = gap > 0 ? components1 : components2
            let start = gap > 0 ? components2.count : components1.count
            for index in start ..< components.count {
                let stringNumber = components[index] as NSString
                if stringNumber.intValue > 0 {
                    return gap > 0 ? PTVersionCompare.Descending : PTVersionCompare.Ascending
                }
            }
        }
        return PTVersionCompare.Equal
    }
    
    
    public static func handleVersionUpdate (_ info: GXVersionUpdateModel?, vc: UIViewController,updateEvent: @escaping (Bool)->Void) {
        
        self.updateButtonEvent = updateEvent
//        guard UIApplication.shared.keyWindow != nil else {
//            delay(time: 2, task: {
//                self.handleVersionUpdate(info)
//            })
//            return
//        }
        
        guard let info = info  else { return }
        
        guard let minVersion = info.min ,
              let latestVersion =  info.latest,
              let release_note =  info.releaseNote,
              let download_url =  info.downloadUrl
        else { return }
        
        guard download_url.count > 0 , let url = download_url.toUrl  else { return }
        
        let currentVersion = kAppVersion ?? ""
       
        var result = compareVersion(v1: currentVersion, v2: latestVersion)
        
        
        if result != PTVersionCompare.Ascending  {
            self.updateButtonEvent?(false)
            return
        }
        result = compareVersion(v1: currentVersion, v2: minVersion)
        
        var needUpdate = PTVersionUpdateStatus.None

        if result == PTVersionCompare.Ascending  {
            needUpdate = PTVersionUpdateStatus.Force
        } else {
//            let cancelUpdateTimeStr: String = UserDefaults.standard.object(forKey: kCancelUpdateTime) as? String ?? ""
//            let cancelUpdateTime = cancelUpdateTimeStr.toInt64() ?? 0
//            if cancelUpdateTime == 0 || (Date.currentTimestamp.toInt64() ?? 0) - cancelUpdateTime > kVersionIntervalTime{
                needUpdate = PTVersionUpdateStatus.Optional
//            }
        }
        if needUpdate == PTVersionUpdateStatus.None {
            self.updateButtonEvent?(false)
            return
        }
        
        if let window = UIApplication.rootWindow {
            if let preUpdateVw =  window.viewWithTag(kVersionUpdateLayerTag) {
                window.bringSubviewToFront(preUpdateVw)
                return
            }
        }
        
        
        let title =  info.title ?? "阅读大冒险更新啦！"
        
        let alertView = GXVersionUpdateView.init(frame: CGRect.zero)
        alertView.tag = kVersionUpdateLayerTag
        alertView.showVersionUpdateView(vc: vc, title: title,info: release_note, forceUpdate: needUpdate == .Force) { isForceUpdate in
            UserDefaults.versionUpdate = ""
            if isForceUpdate {
//                UIApplication.shared.openURL(url)
                UIApplication.shared.open(url)
            } else {
                let cancelUpdateTime = Date.currentTimestamp
                UserDefaults.standard.set(cancelUpdateTime, forKey: kCancelUpdateTime)
                UserDefaults.standard.synchronize()
                //记录本次更新时间
                self.updateButtonEvent?(false)
            }
        }

       
    }
    
}
