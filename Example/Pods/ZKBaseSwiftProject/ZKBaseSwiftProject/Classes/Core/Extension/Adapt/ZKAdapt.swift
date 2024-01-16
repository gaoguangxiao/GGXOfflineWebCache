//
//  ZKAdapt.swift
//  ZKNASProj
//
//  Created by 董建伟 on 2022/11/3.
//

import Foundation
import UIKit
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
    static let factor: CGFloat = {
        return UIDevice.isIPad ? factorIpad : 0.551
    }()

    static let factorIpad: CGFloat = {
        let deviceHeight = UIScreen.main.bounds.width < UIScreen.main.bounds.height ? UIScreen.main.bounds.height : UIScreen.main.bounds.width
        let designedHeight = CGFloat(1024)
        return deviceHeight/designedHeight
    }()

    static let rate: CGFloat = {
        let deviceHeight = UIScreen.main.bounds.height
        let designedHeight = CGFloat(UIDevice.isIPad ? 768.0 : 414.0)
        return deviceHeight/designedHeight
    }()
}
