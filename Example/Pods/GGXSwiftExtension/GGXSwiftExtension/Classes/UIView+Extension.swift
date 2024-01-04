//
//  UIView+CommonExtension.swift
//  DaDaClass
//
//  Created by problemchild on 2018/4/9.
//  Copyright © 2018年 dadaabc. All rights reserved.
//

import UIKit
import Foundation

public extension UIView {
    
    @objc var x: CGFloat {
        set(num) { frame = CGRect(x: flat(num), y: y, width: width, height: height) }
        get { return frame.origin.x }
    }
    @objc var y: CGFloat {
        set(num) { frame = CGRect(x: x, y: flat(num), width: width, height: height) }
        get { return frame.origin.y }
    }
    @objc var width: CGFloat {
        set(num) { frame = CGRect(x: x, y: y, width: flat(num), height: height) }
        get { return frame.size.width }
    }
    @objc var height: CGFloat {
        set(num) { frame = CGRect(x: x, y: y, width: width, height: flat(num)) }
        get { return frame.size.height }
    }

    /// 中心点横坐标
    @objc var centerX: CGFloat {
        set(num) { frame = CGRect(x: flat(num - width / 2), y: y,
                                  width: width, height: height) }
        get { return x + flat(width / 2) }
    }
    /// 中心点纵坐标
    @objc var centerY: CGFloat {
        set(num) { frame = CGRect(x: x, y: flat(num - height / 2),
                                  width: width, height: height) }
        get { return y + flat(height / 2) }
    }

    /// 左边缘
    @objc var left: CGFloat {
        set(num) { x = flat(num) }
        get { return frame.origin.x }
    }

    /// 右边缘
    @objc var right: CGFloat {
        set(num) { x =  flat(num - width) }
        get { return x + width }
    }

    /// 上边缘
    @objc var top: CGFloat {
        set(num) { y = flat(num) }
        get { return y }
    }

    /// 下边缘
    @objc var bottom: CGFloat {
        set(num) { y = flat(num - height) }
        get { return y + height }
    }

    // MARK: VC
    // the VC myself belone to
    var viewController: UIViewController? {
        var responder: UIResponder? = self
        while !(responder is UIViewController) {
            responder = responder?.next
            if nil == responder {
                break
            }
        }
        return responder as? UIViewController
    }

    /// 对传进来的 `UIView` 截图，生成一个 `UIImage` 并返回
    ///
    /// - Parameter afterUpdates: 是否要在界面更新完成后才截图
    /// - Returns: `UIView` 的截图
    func getViewScreenShot(_ afterUpdates: Bool = false, scale: CGFloat = 0) -> UIImage? {
        var resultImage: UIImage?
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, scale)
        self.drawHierarchy(in: bounds.size.rect, afterScreenUpdates: afterUpdates)
        guard let currentCntext = UIGraphicsGetCurrentContext() else {
            return nil
        }
        self.layer.render(in: currentCntext)
        resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImage
    }
    
    /// 对传进来的 `UIView` 截图，生成一个 `UIImage` 并返回
    ///
    /// - Parameter afterUpdates: 是否要在界面更新完成后才截图
    /// - Returns: `UIView` 的截图
    func getViewScreenShot(_ afterUpdates: Bool = false, size: CGSize) -> UIImage? {
        var resultImage: UIImage?
        let scale = size.width / bounds.size.width
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, scale)
        //self.drawHierarchy(in: bounds.size.rect, afterScreenUpdates: afterUpdates)
        guard let currentCntext = UIGraphicsGetCurrentContext() else {
            return nil
        }
        self.layer.render(in: currentCntext)
        resultImage = UIGraphicsGetImageFromCurrentImageContext()
        self.layer.contents = nil
        UIGraphicsEndImageContext()
        return resultImage
    }
    
    

    // MARK: Animation
    /// zoom in animation (maybe for voice practice)
    @objc func zoomInDuration(_ duration: TimeInterval,
                              completion: @escaping (_: Bool) -> Void) {
        transform = CGAffineTransform.init(scaleX: 0, y: 0)
        UIView.animate(withDuration: duration,
                       animations: {
            self.transform = CGAffineTransform.init(scaleX: 0.8, y: 0.8)
        },
                       completion: completion)
    }

    /// zoom in animation (maybe for voice practice)
    @objc func zoomInDurationCompletion(_ completion: @escaping (_ : Bool) -> Void) {
        zoomInDuration(0.25, completion: completion)
    }

    /// bounces animation 弹簧动画
    @objc func bouncesAnimation() {
        let duration = 0.6
        let springAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        springAnimation.values = [0.85, 1.15, 0.9, 1.0]
        springAnimation.keyTimes = [
            0.0,
            0.15,
            0.3,
            0.45
            ].map { NSNumber(value: $0 / duration) }
        springAnimation.duration = duration
        layer.add(springAnimation, forKey: nil)
    }
    
    @objc func ai_setCorner(corner: CGFloat) {
        self.layer.cornerRadius = corner
        self.layer.masksToBounds = true
    }
    
    @objc func ai_setCorner(corner: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corner, cornerRadii: CGSize(width: radius, height: radius))
        let shape = CAShapeLayer()
        shape.path = path.cgPath
        self.layer.mask = shape
    }
    
    func createShadeLayer(startColor: UIColor, endColor: UIColor) {
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = bounds
        gradientLayer.colors = NSArray.init(array: [startColor.cgColor,
                                                    endColor.cgColor]) as? [Any]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.locations = [0,1]
        
        self.layer.insertSublayer(gradientLayer, at:0)
//        return gradientLayer
    }
}
