//
//  UINavigationBar+Extension.swift
//  wisdomstudy
//
//  Created by ggx on 2017/8/15.
//  Copyright © 2017年 高广校. All rights reserved.
//

import UIKit

var k_UINavigationBarExtensionKeyWraper = "k_UINavigationBarExtensionKeyWraper"
extension UINavigationBar {
    /**
     * 导航栏背景颜色以及透明度
     **/
    func navBarBgAlpha(backgroundColor:UIColor,navBarBgAlpha:CGFloat)  {
        objc_setAssociatedObject(self, &k_UINavigationBarExtensionKeyWraper, navBarBgAlpha, .OBJC_ASSOCIATION_RETAIN)
        
        setNeedsNavigationBackgroundAlpha(backgroundColor: backgroundColor, alpha: navBarBgAlpha)
    }
    /**
     * 导航栏字体颜色
     **/
    func naviTitleColor(titleColor:UIColor) {
        //导航栏其他 字体颜色，返回啊，前进啊
        self.tintColor = titleColor
        //导航栏 标题颜色
        self.titleTextAttributes = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 18.0),NSAttributedString.Key.foregroundColor:titleColor]
    }
    /**
     * 状态栏样式 设置
     **/
    func naviBarStyle(barStyle:UIBarStyle)  {
        self.barStyle = barStyle
    }
    private func setNeedsNavigationBackgroundAlpha(backgroundColor:UIColor,alpha:CGFloat)  {
        let barBackgroundView = self.subviews[0]
        
        //设置
        self.barTintColor = backgroundColor;
//        let shadowView = barBackgroundView.value(forKey: "_shadowView")as!UIView
//        shadowView.alpha = alpha
        if self.isTranslucent {
            barBackgroundView.alpha = alpha
            return;
        }

        
        let IOS10 = NSString(string:UIDevice.current.systemVersion).floatValue >= 10

        if IOS10 {
            
            let backgroundEffectView = barBackgroundView.value(forKey: "_backgroundEffectView")as!UIView
//
//            for item in backgroundEffectView.subviews {
//                let effectView = NSClassFromString("_UIVisualEffectFilterView") as! UIView
//                if item == effectView {
//                    
//                }
//                print(effectView)
//            }
            
            //获取属性列表
//            var count : UInt32 = 0;
//            let ivars =  class_copyIvarList(backgroundEffectView.classForCoder, &count)
//            for item in 0..<count {
//                let ivar = ivars?[Int(item)]
//                let ivarName = String.init(cString: ivar_getName(ivar))
//                print(ivarName)
//            }
//            backgroundEffectView.backgroundColor = . red
            if self.backgroundImage(for: UIBarMetrics.default) == nil{
                backgroundEffectView.alpha = alpha
            }
        }
        else{
            let daptiveBackdrop = barBackgroundView.value(forKey: "_adaptiveBackdrop") as!UIView
            let backgroundEffectView = daptiveBackdrop.value(forKey: "_backgroundEffectView")as!UIView
                backgroundEffectView.alpha = alpha;
        }

        
    }
}
