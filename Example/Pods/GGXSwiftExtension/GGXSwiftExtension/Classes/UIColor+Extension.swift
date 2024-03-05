//
//  UIColor+Extension.swift
//  wisdomstudy
//
//  Created by ggx on 2017/8/17.
//  Copyright © 2017年 高广校. All rights reserved.
//

import UIKit

@objc public extension UIColor {
    static func RGBA(_ red:CGFloat,green:CGFloat,blue:CGFloat,alpha:CGFloat) -> UIColor {
        return UIColor.init(_colorLiteralRed: Float(red)/255.0, green: Float(green)/255.0, blue: Float(blue)/255.0, alpha: Float(alpha));
    }
    
    static func RGB(_ red:CGFloat,green:CGFloat,blue:CGFloat,alpha:CGFloat) -> UIColor {
        return UIColor.init(red: red, green: green, blue: blue, alpha: alpha);
    }
    
    /// 16进制颜色
    convenience init(hex: Int, alpha: CGFloat = 1) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255
        let green = CGFloat((hex & 0xFF00) >> 8) / 255
        let blue = CGFloat(hex & 0xFF) / 255
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /// 16进制颜色
    convenience init(hex: String,_ alpha: CGFloat = 1) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: alpha
        )
    }
    
    // for oc
    static func hex(_ color: Int) -> UIColor {
        return UIColor(hex: color, alpha: 1)
    }
    
    /// 随机颜色
    static var random: UIColor {
        let hue = CGFloat(arc4random() % 256) / 256 // use 256 to get full range from 0.0 to 1.0
        let saturation = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from white
        let brightness = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from black
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }
    
    /**
     *  将自身变化到某个目标颜色，可通过参数progress控制变化的程度，最终得到一个纯色
     *  @param color 目标颜色
     *  @param progress 变化程度，取值范围0.0f~1.0f
     */
    func transition(to color: UIColor, progress: CGFloat) -> UIColor {
        return UIColor.color(from: self, to: color, progress: progress)
    }
    
    /**
     *  将颜色A变化到颜色B，可通过progress控制变化的程度
     *  @param fromColor 起始颜色
     *  @param toColor 目标颜色
     *  @param progress 变化程度，取值范围0.0f~1.0f
     */
    static func color(from fromColor: UIColor, to toColor: UIColor, progress: CGFloat) -> UIColor {
        let progress = min(progress, 1.0)
        let fromRed = fromColor.redValue
        let fromGreen = fromColor.greenValue
        let fromBlue = fromColor.blueValue
        let fromAlpha = fromColor.alphaValue
        
        let toRed = toColor.redValue
        let toGreen = toColor.greenValue
        let toBlue = toColor.blueValue
        let toAlpha = toColor.alphaValue
        
        let finalRed = fromRed + (toRed - fromRed) * progress
        let finalGreen = fromGreen + (toGreen - fromGreen) * progress
        let finalBlue = fromBlue + (toBlue - fromBlue) * progress
        let finalAlpha = fromAlpha + (toAlpha - fromAlpha) * progress
        
        return UIColor(red: finalRed, green: finalGreen, blue: finalBlue, alpha: finalAlpha)
    }
    
    /**
     *  获取当前UIColor对象里的红色色值
     *
     *  @return 红色通道的色值，值范围为0.0-1.0
     */
    var redValue: CGFloat {
        var r: CGFloat = 0
        if getRed(&r, green: nil, blue: nil, alpha: nil) {
            return r
        }
        return 0
    }
    
    /**
     *  获取当前UIColor对象里的绿色色值
     *
     *  @return 绿色通道的色值，值范围为0.0-1.0
     */
    var greenValue: CGFloat {
        var g: CGFloat = 0
        if getRed(nil, green: &g, blue: nil, alpha: nil) {
            return g
        }
        return 0
    }
    
    /**
     *  获取当前UIColor对象里的蓝色色值
     *
     *  @return 蓝色通道的色值，值范围为0.0-1.0
     */
    var blueValue: CGFloat {
        var b: CGFloat = 0
        if getRed(nil, green: nil, blue: &b, alpha: nil) {
            return b
        }
        return 0
    }
    
    /**
     *  获取当前UIColor对象里的透明色值
     *
     *  @return 透明通道的色值，值范围为0.0-1.0
     */
    var alphaValue: CGFloat {
        var a: CGFloat = 0
        if getRed(nil, green: nil, blue: nil, alpha: &a) {
            return a
        }
        return 0
    }
    
    static func color(from hexString: String, alpha: CGFloat = 0) -> UIColor {
        
        var cString: String = hexString.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        
        if cString.hasPrefix("0X") {
            cString = cString.substring(from: 2)
        }
        if cString.hasPrefix("#") {
            cString = cString.substring(from: 1)
        }
        if cString.count > 6 || cString.isEmpty {
            return UIColor.hex(0x00cdaf)
        }
        
        var color: UInt32 = 0x0
        
        Scanner.init(string: cString).scanHexInt32(&color)
        
        return UIColor(hex: Int(color), alpha: 1)
    }
    
    class var lt3179E5: UIColor {
        get { return .hex(0x1E83F5)}
    }
    
}
