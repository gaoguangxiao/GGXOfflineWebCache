//
//  CGPoint+Extension.swift
//  GGXSwiftExtension
//
//  Created by 高广校 on 2024/11/15.
//

import Foundation

extension CGPoint {
    
}

//init point
extension CGPoint {
    
    public static var left: CGPoint {  CGPoint(x: -1, y: 0) }
    
    public static var right: CGPoint {  CGPoint(x: 1, y: 0) }
    
}


//funtion
extension CGPoint {
    
    public static func + (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }
    
    //  Overload the operator += for adding CGPoint to CGSize or CGPoint
    public static func += (left: inout CGPoint, right: CGPoint) {
        left.x += right.x
        left.y += right.y
    }
    
    public static func - (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x - right.x, y: left.y - right.y)
    }
    
    public static func -= (left: inout CGPoint, right: CGPoint) {
        left.x -= right.x
        left.y -= right.y
    }
    
    public static func * (left: CGPoint, right: CGFloat) -> CGPoint {
        return CGPoint(x: left.x * right, y: left.y * right)
    }
    
    public static func *= (left: inout CGPoint, right: CGPoint) {
        left.x *= right.x
        left.y *= right.y
    }
    
    public static func / (left: CGPoint, right: CGFloat) -> CGPoint {
        return CGPoint(x: left.x / right, y: left.y / right)
    }
    
    public static func /= (left: inout CGPoint, right: CGPoint) {
        left.x /= right.x
        left.y /= right.y
    }
}

