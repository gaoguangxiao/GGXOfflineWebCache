//
//  UIDevice+CommonExtension.swift
//  DaDaClass
//
//  Created by problemchild on 2018/4/8.
//  Copyright © 2018年 dadaabc. All rights reserved.
//

import Foundation
import UIKit

//public let IS_55INCH_SCREEN = UIDevice.is55InchScreen
//public let IS_47INCH_SCREEN = UIDevice.is47InchScreen
//public let IS_40INCH_SCREEN = UIDevice.is40InchScreen
//public let IS_35INCH_SCREEN = UIDevice.is35InchScreen

/// navigationBar相关frame
/// https://www.jianshu.com/p/d7b8f831c1f1
public let NavigationBarHeight: CGFloat = {
    if !UIDevice.isIPad {
        return 44
    } else {
        if #available(iOS 12.0, *) {
            return 50
        } else {
            return 44
        }
    }
}()

public let StatusBarHeight: CGFloat = UIDevice.getStatusBarHeight
public let TopBarHeight   : CGFloat = StatusBarHeight + NavigationBarHeight

public let BOTTOM_MARGIN  : CGFloat = UIDevice.getTouchBarHeight
public let TabBarHeight: CGFloat = BOTTOM_MARGIN + 49

public let SCREEN_SCALE = UIScreen.main.scale


public let SCREEN_WIDTH = UIScreen.main.bounds.width
public let SCREEN_WIDTH_STATIC = UIScreen.main.bounds.width < UIScreen.main.bounds.height ? UIScreen.main.bounds.width : UIScreen.main.bounds.height
public let SCREEN_HEIGHT = UIScreen.main.bounds.height
public let SCREEN_HEIGHT_STATIC = UIScreen.main.bounds.width < UIScreen.main.bounds.height ? UIScreen.main.bounds.height : UIScreen.main.bounds.width

/* app版本 以及设备系统版本 */
public let infoDictionary            = Bundle.main.infoDictionary
public let kAppName: String?         = infoDictionary!["CFBundleDisplayName"] as? String                    /* App名称 */
public let kAppVersion: String?      = infoDictionary!["CFBundleShortVersionString"] as? String            /* App版本号 */
public let kAppBuildVersion: String? = infoDictionary!["CFBundleVersion"] as? String                       /* Appbuild版本号 */
public let kAppBundleId: String?     = infoDictionary!["CFBundleIdentifier"] as? String                    /* app bundleId */
public let platformName: String?     = infoDictionary!["DTPlatformName"] as? String                        //平台名称（iphonesimulator 、 iphone）

// MARK: - 数学计算
public let AngleWithDegrees: (CGFloat) -> CGFloat = { .pi * $0 / 180.0 }

/**
 *  基于当前设备的屏幕倍数，对传进来的 floatValue 进行像素取整。
 *
 *  注意如果在 Core Graphic 绘图里使用时，要注意当前画布的倍数是否和设备屏幕倍数一致，若不一致，不可使用 flat() 函数，而应该用 flatSpecificScale
 */
public func flat(_ value: CGFloat) -> CGFloat {
    return flatSpecificScale(value, 0)
}

/**
 *  基于指定的倍数，对传进来的 floatValue 进行像素取整。若指定倍数为0，则表示以当前设备的屏幕倍数为准。
 *
 *  例如传进来 “2.1”，在 2x 倍数下会返回 2.5（0.5pt 对应 1px），在 3x 倍数下会返回 2.333（0.333pt 对应 1px）。
 */
public func flatSpecificScale(_ value: CGFloat, _ scale: CGFloat) -> CGFloat {
    let s = scale == 0 ? SCREEN_SCALE : scale
    return ceil(value * s) / s
}

/*
 iPhone 型号：https://www.theiphonewiki.com/wiki/Models
 */
@objc public extension UIDevice {
    
    /// 是否是 testflight包
    static var isTestFlight: Bool = {
        return isAppStoreReceiptSandbox && !hasEmbeddedMobileProvision
    }()
    
    /// 是否是 Appstore 包
    static var isAppStore: Bool = {
        if isAppStoreReceiptSandbox || hasEmbeddedMobileProvision {
            return false
        }
        return true
    }()
    
    fileprivate static var isAppStoreReceiptSandbox: Bool = {
        let b = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
        return b
    }()
    
    fileprivate static var hasEmbeddedMobileProvision: Bool = {
        let b = Bundle.main.path(forResource: "embedded", ofType: "mobileprovision") != nil
        return b
    }()
    
    
    
    @objc static var language: String {
        let preferredLang = appSysTemLanguages
        print("SDK获取设备语言：\(preferredLang)")
        if preferredLang.contains("en") {
            return "EN_US" //英文
        }
        return "ZH_CN" //中文
    }
    
    @objc static var areaType: String {
        let preferredLang = appSysTemLanguages
        print("SDK获取设备国家区域：\(preferredLang)")
        if preferredLang.contains("HK") || preferredLang.contains("MO") || preferredLang.contains("TW"){
            return "GAT_AREA" //港澳台地区
        }  else if preferredLang.contains("CN") {
            return "CN_AREA"  //国内地区
        } else if preferredLang.contains("MM") || preferredLang.contains("TH") || preferredLang.contains("KH") || preferredLang.contains("LA") || preferredLang.contains("VN") || preferredLang.contains("PH") || preferredLang.contains("MY") || preferredLang.contains("SG") || preferredLang.contains("BN") || preferredLang.contains("ID") || preferredLang.contains("TL") {
            return "FOREIGN_AREA"//东南亚地区
        } else {
            return ""
        }
    }
    
    @objc static var areaCountry: String {
        let preferredLang = appSysTemLanguages
        //        print("SDK获取设备国家：\(preferredLang)")
        if preferredLang.contains("HK") {
            return "HK" //香港
        } else if preferredLang.contains("MO") {
            return "MO" //澳门
        } else if preferredLang.contains("TW") {
            return "TW" //台湾
        } else if preferredLang.contains("SG") {
            return "SG" //新加坡
        } else if preferredLang.contains("MY") {
            return "MY" //马来西亚
        } else if preferredLang.contains("CN") {
            return "CN" //中国大陆
        } else if preferredLang.contains("TH") {
            return "TH" //泰国
        } else if preferredLang.contains("PH") {
            return "PH" //菲律宾
        } else if preferredLang.contains("ID") {
            return "ID" //印度尼西亚
        } else if preferredLang.contains("VN") {
            return "VN" //越南
        } else {
            return "" //海外其他
        }
    }
    
    static var appSysTemLanguages: String {
        let defaults = UserDefaults.standard
        let allLanguages = defaults.object(forKey: "AppleLanguages") as! Array<Any>
        return allLanguages.first as! String
    }
    
    /// 获取设备等级 1高级
    @objc static var deviceLevelModel: Int {
        let lowDeviceArr = ["iPad mini 2","iPad mini 3","iPad Air","iPhone 6","iPhone 6 Plus"]
        let deviceModel = modelName;
        for tmpDevice in lowDeviceArr {
            if deviceModel.caseInsensitiveCompare(tmpDevice) == .orderedSame {
                return 0
            }
        }
        return 1;
    }
    ///设备型号的名称
    @objc static var modelName: String {
        
        let identifier = systemModelName
        
        switch identifier {
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                return "iPhone X"
        case "iPhone11,2":                              return "iPhone XS"
        case "iPhone11,8":                              return "iPhone XR"
        case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
        case "iPhone12,1":                              return "iPhone 11"
        case "iPhone12,3":                              return "iPhone 11 Pro"
        case "iPhone12,5":                              return "iPhone 11 Pro Max"
        case "iPhone12,8":                              return "iPhone SE 2"
        case "iPhone13,1":                              return "iPhone 12 mini"
        case "iPhone13,2":                              return "iPhone 12"
        case "iPhone13,3":                              return "iPhone 12 Pro"
        case "iPhone13,4":                              return "iPhone 12 Pro Max"
        case "iPhone14,2":                              return "iPhone 13 Pro"
        case "iPhone14,3":                              return "iPhone 13 Pro Max"
        case "iPhone14,4":                              return "iPhone 13 mini"
        case "iPhone14,5":                              return "iPhone 13"
            
        case "iPhone14,6":                              return "iPhone SE 3"
        case "iPhone14,7":                              return "iPhone 14"
        case "iPhone14,8":                              return "iPhone 14 Plus"
        case "iPhone15,2":                              return "iPhone 14 Pro"
        case "iPhone15,3":                              return "iPhone 14 Pro Max"
            
        case "iPhone15,4":                              return "iPhone 15"
        case "iPhone15,5":                              return "iPhone 15 Plus"
        case "iPhone16,1":                              return "iPhone 15 Pro"
        case "iPhone16,2":                              return "iPhone 15 Pro Max"
            
        case "iPhone17,3":                              return "iPhone 16"
        case "iPhone17,4":                              return "iPhone 16 Plus"
        case "iPhone17,1":                              return "iPhone 16 Pro"
        case "iPhone17,2":                              return "iPhone 16 Pro Max"
            
            // iPod
        case "iPod1,1":                                 return "iPod Touch 1"
        case "iPod2,1":                                 return "iPod Touch 2"
        case "iPod3,1":                                 return "iPod Touch 3"
        case "iPod4,1":                                 return "iPod Touch 4"
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPod9,1":                                 return "iPod Touch 7"
            
            // iPad
        case "iPad1,1":                                 return "iPad 1 (2010)"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2 (2011)"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3 (2012)"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4 (2012)"
        case "iPad6,11", "iPad6,12":                    return "iPad 5 (2017)"
        case "iPad7,5", "iPad7,6":                      return "iPad 6 (2018)"
        case "iPad7,11", "iPad7,12":                    return "iPad 7 (2019)"
        case "iPad11,6", "iPad11,7":                    return "iPad 8 (2020)"
        case "iPad12,1", "iPad12,2":                    return "iPad 9 (2021)"
        case "iPad13,18", "iPad13,19":                  return "iPad 10 (2022)"
            
            //iPad Mini
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad mini 1 (2012)"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad mini 4 (2015)"
        case "iPad11,1","iPad11,2":                     return "iPad mini 5 (2019)"
        case "iPad14,1","iPad14,2":                     return "iPad Mini 6 (2022)"
            
            //iPad Air
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2 (2014)"
        case "iPad11,3", "iPad11,4":                    return "iPad Air 3 (2019)"
        case "iPad13,1", "iPad13,2":                    return "iPad Air 4 (2020)"
        case "iPad13,16", "iPad13,17":                  return "iPad Air 5 (2022)"
        case "iPad14,8", "iPad14,9":                    return "iPad Air 11-inch (M2) (2024)"
        case "iPad14,10", "iPad14,11":                  return "iPad Air 13-inch (M2) (2024)"
            
            //iPad Pro
        case "iPad6,3", "iPad6,4":                       return "iPad Pro (9.7-inch) (2016)"
        case "iPad7,3", "iPad7,4":                       return "iPad Pro (10.5-inch) (2017)"
        case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4": return "iPad Pro (11-inch) (2018)"
        case "iPad8,9", "iPad8,10":                      return "iPad Pro (11-inch) 2 (2020)"
        case "iPad13,4","iPad13,5","iPad13,6","iPad13,7":return "iPad Pro (11-inch) 3 (2021)"
        case "iPad14,3","iPad14,4":                      return "iPad Pro (11-inch) 4 (2022)"
        case "iPad16,3","iPad16,4":                      return "iPad Pro 11-inch (M4) (2024)"
            
        case "iPad6,7", "iPad6,8":                          return "iPad Pro (12.9-inch) (2016)"
        case "iPad7,1", "iPad7,2":                          return "iPad Pro (12.9-inch) 2 (2017)"
        case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":    return "iPad Pro (12.9-inch) 3 (2018)"
        case "iPad8,11", "iPad8,12":                        return "iPad Pro (12.9-inch) 4 (2020)"
        case "iPad13,8","iPad13,9","iPad13,10","iPad13,11": return "iPad Pro (12.9-inch) 5（2021）"
        case "iPad14,5","iPad14,6"                        : return "iPad Pro (12.9-inch) 6（2022）"
        case "iPad16,5","iPad16,6"                        : return "iPad Pro 13.0-inch (M4)（2024）"
            
        case "i386", "x86_64","arm64":                      return UIDevice.simulatorIdentiferViaSize()
        default:                                        return identifier
        }
    }
    
    /// 系统给的型号
    @objc static var systemModelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else {
                return identifier
            }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
    /// 根据当前屏幕尺寸得到所有相符的型号如"iPhone 6, iPhone 6s, iPhone 7, iPhone 8"
    @objc static func simulatorIdentiferViaSize() -> String {
        
        // iPhone & iPod
        if ((width == 414 && height == 896) || (width == 896 && height == 414)) && UIScreen.main.scale == 3 {
            return "Simulator iPhone XS Max"
        } else if ((width == 414 && height == 896) || (width == 896 && height == 414)) && UIScreen.main.scale == 2 {
            return "Simulator iPhone XR"
        } else  if (width == 375 && height == 812) || (width == 812 && height == 375) {
            return "Simulator iPhone X/XS/12 Mini/13 Mini"
        } else if (width == 414 && height == 736) || (width == 736 && height == 414) {
            return "Simulator iPhone 6 Plus, iPhone 6s Plus, iPhone 7 Plus, iPhone 8 Plus"
        } else if (width == 375 && height == 667) || (width == 667 && height == 375) {
            return "Simulator iPhone 6, iPhone 6s, iPhone 7, iPhone 8"
        } else if (width == 320 && height == 568) || (width == 568 && height == 320) {
            return "Simulator iPhone 5, iPhone 5s, iPhone 5c, iPhone SE, iPod Touch"
        } else if (width == 320 && height == 480) || (width == 480 && height == 320) {
            return "Simulator iPhone 4, iPhone 4s, iPhone 2G, iPhone 3G, iPhone 3GS"
        } else if (width == 390 && height == 844) || (width == 844 && height == 390) {
            return "Simulator iPhone 12/12 Pro/13/13 Pro/14"
        } else if (width == 428 && height == 926) || (width == 926 && height == 428) {
            return "Simulator iPhone 12 Pro Max/13 Pro Max/14 Plus"
        } else if (width == 393 && height == 852) || (width == 852 && height == 393){
            return "Simulator iPhone 14 Pro/15/15 Pro/16"
        } else if (width == 402 && height == 874) || (width == 874 && height == 402){
            return "Simulator iPhone 16 Pro"
        } else if (width == 430 && height == 932) || (width == 932 && height == 430){
            return "Simulator iPhone 14 Pro Max/15 Plus/16 Plus/15 Pro Max"
        } else if (width == 440 && height == 956) || (width == 956 && height == 440){
            return "Simulator iPhone 16 Pro Max"
        }
        
        // iPad
        else if (width == 768 && height == 1024) || (width == 1024 && height == 768) {
            return "Simulator iPad mini 1, iPad mini 2, iPad mini 3, iPad mini 4, iPad 2, iPad 3, iPad 4, iPad 5, iPad Air 1, iPad Air 2, iPad Pro(9.7-inch)"
        } else if (width == 834 && height == 1112) || (width == 1112 && height == 834) {
            return "Simulator iPad Pro(10.5-inch)"
        } else if (width == 1024 && height == 1366) || (width == 1366 && height == 1024) {
            return "Simulator iPad Pro(12.9-inch)"
        } else if (width == 810 && height == 1080) || (width == 1080 && height == 810) {
            return "Simulator iPad 8"
        } else if (width == 820 && height == 1180) || (width == 1180 && height == 820) {
            return "Simulator iPad Air 4"
        }
        
        return "Simulator unknown"
    }
    
    /// 用户界面当前是否横屏,用户界面横屏了才会返回true
    @objc class func isInterfaceLandscape() -> Bool {
        if #available(iOS 13.0, *) {
            if let tmpOrientation = UIApplication.windowScenes.first?.interfaceOrientation {
                return tmpOrientation.isLandscape
            }
            return false
        } else {
            // Fallback on earlier versions
            let orientation = UIApplication.shared.statusBarOrientation
            return orientation == .landscapeLeft || orientation == .landscapeRight
        }
    }
    
    /// 设备当前是否横屏无论支不支持横屏，只要设备横屏了，就会返回YES
    @objc class func isDeviceLandscape() -> Bool {
        let orientation = UIDevice.current.orientation
        return orientation == .landscapeLeft || orientation == .landscapeRight
    }
    
    @objc static var isOld: Bool {
        let oldDevices = [
            "iPhone 4", "iPhone 5", "iPhone 6", "iPhone 7",
            "2010", "2011", "2012", "2013", "2014",
            "iPod Touch"
        ]
        for old in oldDevices {
            if UIDevice.modelName.contains(old) {
                return true
            }
        }
        return false
        
        //        return UIDevice.modelName.contains("iPhone 5") ||
        //            UIDevice.modelName.contains("iPhone SE") ||
        //            UIDevice.modelName.contains("iPhone 6")
    }
    
    /*
     https://developer.apple.com/library/archive/documentation/DeviceInformation/Reference/iOSDeviceCompatibility/DeviceCompatibilityMatrix/DeviceCompatibilityMatrix.html
     */
    @objc static var supportARKit: Bool {
        if modelName == "iPhone 4" || modelName == "iPhone 4s" || modelName == "iPhone 5" ||
            modelName == "iPhone 5s" || modelName == "iPhone 5c" || modelName == "iPhone 6" ||
            modelName.contains("2015") || modelName.contains("2014") || modelName.contains("2013") ||
            modelName.contains("2012") || modelName.contains("2011") || modelName.contains("2010") ||
            modelName.contains("iPod") {
            return false
        }
        return true
    }
    
//    @objc static var isIPhoneX: Bool {
//        return UIDevice.modelName.contains("iPhone X") ||
//        UIDevice.modelName.contains("iPhone 11") ||
//        UIDevice.modelName.contains("iPhone 12") ||
//        UIDevice.modelName.contains("iPhone 13")
//    }
    
    @available(iOS 11.0, *)
    @objc static var isNotch: Bool {
        guard let window = UIApplication.rootWindow else {
            return false
        }
        
        let safeArea = window.safeAreaInsets
        return safeArea.top > 20
    }
    
    @objc static var isIPad: Bool {
        return UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
    }
    
//    @objc static var isNoHomeIpad: Bool {
//        return systemModelName.contains("iPad8,") || systemModelName.contains("iPad13,")
//    }
    
    //    @objc static var isIPadPro: Bool {
    //        return isIPad && (width == 1024 && height == 1366)
    //    }
    
    @objc static var isIPod: Bool {
        return UIDevice.current.model.contains("iPod touch")
    }
    
    @objc static var isIPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    @objc static var isSimulator: Bool {
        let isSim = systemModelName
        if isSim.contains("i386") ||  isSim.contains("x86_64") ||  isSim.contains("arm64"){
            return true
        }
        return false
    }
    
//    @objc static var is55InchScreen: Bool {
//        return CGSize(width: width, height: height) == screenSizeFor55Inch
//    }
//    
//    @objc static var is47InchScreen: Bool {
//        return CGSize(width: width, height: height) == screenSizeFor47Inch
//    }
//    
//    @objc static var is40InchScreen: Bool {
//        return CGSize(width: width, height: height) == screenSizeFor40Inch
//    }
//    
//    @objc static var is35InchScreen: Bool {
//        return CGSize(width: width, height: height) == screenSizeFor35Inch
//    }
    
    static let like4to3Screen = UIScreen.main.bounds.size.height / UIScreen.main.bounds.size.width <= 1.5
    static let isNarrowScreen = UIScreen.main.bounds.size.width < 375 ? true : false
    
//    @objc static var isPlus: Bool {
//        return width == 414 || width == 428
//    }
    
//    @objc static var screenSizeFor55Inch: CGSize {
//        return CGSize(width: 414, height: 736)
//    }
//    
//    @objc static var screenSizeFor47Inch: CGSize {
//        return CGSize(width: 375, height: 667)
//    }
//    
//    @objc static var screenSizeFor40Inch: CGSize {
//        return CGSize(width: 320, height: 568)
//    }
//    
//    @objc static var screenSizeFor35Inch: CGSize {
//        return CGSize(width: 320, height: 480)
//    }
    
    static var width: Int {
        return Int(UIScreen.main.bounds.width)
    }
    
    static var widthf: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    static var height: Int {
        return Int(UIScreen.main.bounds.size.height)
    }
    
    static var heightf: CGFloat { UIScreen.main.bounds.size.height }
    
    @objc static var currentSystemVersion: String {
        return UIDevice.current.systemVersion
    }
    
    /// 获取状态栏高度
    @objc static var getStatusBarHeight: CGFloat {
        var statusH = UIApplication.shared.statusBarFrame.height
        
        guard let window = UIApplication.rootWindow else { return 0 }
        var isLandscape = UIDevice.current.orientation.isLandscape
        if #available(iOS 13.0, *) {
            if let windowScene = window.windowScene {
                isLandscape = windowScene.interfaceOrientation.isLandscape
            }
        }
        if #available(iOS 11.0, *) {
            statusH = if isLandscape {
                window.safeAreaInsets.left
            } else {
                window.safeAreaInsets.top
            }
        }
        
        //状态栏最小高度为20
        if statusH == 0 { statusH = 20 }
        return statusH
    }
    
    /// 获取window安全域左边间距
    static var getSafeAreaLeft: CGFloat {
        guard let window = UIApplication.rootWindow else { return 0 }
        if #available(iOS 11.0, *) {
            return window.safeAreaInsets.left
        } else {
            return 0
        }
    }
    
    /// 获取window安全域左边间距
    static var getSafeAreaRight: CGFloat {
        guard let window = UIApplication.rootWindow else { return 0 }
        if #available(iOS 11.0, *) {
            return window.safeAreaInsets.right
        } else {
            return 0
        }
    }
    
    //底部安全域
    @objc static var getTouchBarHeight: CGFloat {
        var touchBarH: CGFloat = 0
        if #available(iOS 11.0, *) {
            touchBarH =
            UIApplication.rootWindow?.safeAreaInsets.bottom ?? 0
        }
        return touchBarH
    }
}


//设备适配
public extension UIDevice {
    
    static func deviceFactor(_ standardHeight: CGFloat = UIDevice.isIPad ? 768 : 414 ) -> CGFloat {
        return SCREEN_WIDTH_STATIC/standardHeight
    }
    
    /// 兼容横屏和竖屏 横屏只有44
    static func TopBarHeighttRelative() -> CGFloat {
        if UIDevice.isInterfaceLandscape() {
            return NavigationBarHeight + 20
        }
        return StatusBarHeight + NavigationBarHeight
    }
}
