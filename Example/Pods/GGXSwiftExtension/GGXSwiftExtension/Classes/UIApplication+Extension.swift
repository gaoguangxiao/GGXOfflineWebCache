//
//  UIApplication+Extension.swift
//  DaDaClass
//
//  Created by problemchild on 2018/4/4.
//  Copyright © 2018年 dadaabc. All rights reserved.
//

import UIKit

@objc public extension UIApplication {
    @objc class var visibleViewController: UIViewController? {
        if let rootWindow {
            return UIApplication.getVisibleViewController(from: rootWindow.rootViewController)
        }
        return nil
    }

    @objc class func getVisibleViewController(from vc: UIViewController?) -> UIViewController? {
        if let nav = vc as? UINavigationController {
            return getVisibleViewController(from: nav.visibleViewController)
        } else if let tab = vc as? UITabBarController {
            return getVisibleViewController(from: tab.selectedViewController)
        } else if let pvc = vc?.presentedViewController {
            return getVisibleViewController(from: pvc)
        }
        return vc
    }

    static var appIcon: UIImage? {
        guard let iconsDictionary = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
            let primaryIconsDictionary = iconsDictionary["CFBundlePrimaryIcon"] as? [String: Any],
            let iconFiles = primaryIconsDictionary["CFBundleIconFiles"] as? [String],
            let lastIcon = iconFiles.last else { return nil }
        return UIImage(named: lastIcon)
    }
    
    @available(iOS 13.0, *)
    static var windowScenes: [UIWindowScene] {
        UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene}).compactMap({$0})
    }
    
    @available(iOS 13.0, *)
    static var windowScene: UIWindowScene? {
        let _windowScene = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive}).first as? UIWindowScene
        return _windowScene
    }
    
    /// 获取跟root窗口
    static var rootWindow: UIWindow? {
        var window: UIWindow?
        if #available(iOS 13.0, *) {
            outer: for s in windowScenes {
                for w in s.windows where (w.isMember(of: UIWindow.self) && w.isKeyWindow) {
                    window = w
                    break outer
                }
            }
        }
        return window ?? UIApplication.shared.windows.first
    }
}
