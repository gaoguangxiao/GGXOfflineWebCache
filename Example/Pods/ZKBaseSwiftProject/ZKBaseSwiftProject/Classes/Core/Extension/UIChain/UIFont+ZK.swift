//
//  UIFont+ZK.swift
//  ZKNASProj
//
//  Created by 董建伟 on 2022/10/21.
//


import UIKit

//MARK: Medium
@objc public extension UIFont {
    
    class func medium(_ size:CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .medium)
    }
    
    class var medium12: UIFont {
        get {
            return UIFont.systemFont(ofSize: 12, weight: .medium)
        }
    }
    
    class var medium13: UIFont {
        get {
            return UIFont.systemFont(ofSize: 12, weight: .medium)
        }
    }
    
    class var medium14: UIFont {
        get {
            return UIFont.systemFont(ofSize: 14, weight: .medium)
        }
    }
    
    class var medium15: UIFont {
        get {
            return UIFont.systemFont(ofSize: 15, weight: .medium)
        }
    }
    
    class var medium16: UIFont {
        get {
            return UIFont.systemFont(ofSize: 16, weight: .medium)
        }
    }
    
    
}

//MARK: semibold
public extension UIFont {
    
    class func semibold(_ size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .semibold)
    }
    
    class var semibold15: UIFont {
        get {
            return UIFont.systemFont(ofSize: 15, weight: .semibold)
        }
    }
    
}

//MARK: Regular
@objc public extension UIFont {
    class func regular(_ size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .regular)
    }
    
    class var regular12: UIFont {
        get {
            UIFont.systemFont(ofSize: 12, weight: .regular)
        }
    }
    
    class var regular14: UIFont {
        get {
            UIFont.systemFont(ofSize: 14, weight: .regular)
        }
    }
    
    class var regular16: UIFont {
        get {
            UIFont.systemFont(ofSize: 16, weight: .regular)
        }
    }
    
    class var regular20: UIFont {
        get {
            UIFont.systemFont(ofSize: 20, weight: .regular)
        }
    }
    
    class var regular24: UIFont {
        get {
            UIFont.systemFont(ofSize: 24, weight: .regular)
        }
    }
}

//MARK: Light
public extension UIFont {
    
    class func light(_ size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .light)
    }
    
    class var light16: UIFont {
        get {
            UIFont.systemFont(ofSize: 16, weight: .light)
        }
    }
    
    class var light14: UIFont {
        get {
            UIFont.systemFont(ofSize: 14, weight: .light)
        }
    }
    
}



