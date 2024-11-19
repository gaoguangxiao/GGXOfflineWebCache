//
//  ZKAdapt.swift
//  ZKNASProj
//
//  Created by 董建伟 on 2022/11/3.
//

import Foundation
import UIKit
import GGXSwiftExtension

public extension CGFloat {
    /// 返回对应设备匹配的尺寸
    func tdMatch() -> CGFloat{
        return self * ZKAdapt.factor
    }
}


public extension Double {
    /// 返回对应设备匹配的尺寸
    func tdMatch() -> CGFloat {
        return self * ZKAdapt.factor
    }
}

public extension Int {
    /// 返回对应设备匹配的尺寸
    func zkMatch() -> CGFloat {
        return CGFloat(self) * ZKAdapt.factor
    }
}

public struct ZKAdapt {
    
    public static let factor: CGFloat = {
        return UIDevice.isIPad ? factorIpad : rate * 0.87533
    }()

    public static let factor820: CGFloat = {
        let deviceHeight = SCREEN_WIDTH_STATIC
        let designedHeight =  UIDevice.isIPad ? 820.0 : 375.0
        let adpt = deviceHeight/designedHeight
        return UIDevice.isIPad ? adpt : adpt * 0.6
    }()
    
    public static let factorIpad: CGFloat = {
        let deviceHeight = UIScreen.main.bounds.height
        let designedHeight = CGFloat(768)
        let adpt = deviceHeight/designedHeight
        return adpt
    }()

    public static let rate: CGFloat = {
        let deviceHeight = SCREEN_WIDTH_STATIC
        let designedHeight = CGFloat(UIDevice.isIPad ? 768.0 : 414)
        return deviceHeight/designedHeight
    }()
    
    public static func deviceFactor(_ standardWidth: CGFloat = UIDevice.isIPad ? 768 : 414 ) -> CGFloat {
        let deviceHeight = SCREEN_WIDTH_STATIC
        return deviceHeight/standardWidth
    }
    
    public static func factor(_ ipadValue: CGFloat, _ iphoneValue: CGFloat) -> CGFloat {
        let adpt = (UIDevice.isIPad ? ipadValue : iphoneValue)
        return rate * adpt
    }
    
    public static func factor820(_ ipadValue: CGFloat, _ iphoneValue: CGFloat) -> CGFloat {
        let adpt = (UIDevice.isIPad ? ipadValue : iphoneValue)
        
        let deviceHeight = SCREEN_WIDTH_STATIC
        let designedHeight = CGFloat(UIDevice.isIPad ? 820.0 : 414)
        let rate = deviceHeight/designedHeight
        return rate * adpt
    }
}
