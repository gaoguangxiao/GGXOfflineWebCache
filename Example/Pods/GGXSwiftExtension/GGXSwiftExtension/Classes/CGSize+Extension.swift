//
//  CGSize+CommonExtension.swift
//  TestSwift
//
//  Created by han wp on 2018/4/8.
//  Copyright © 2018年 han. All rights reserved.
//

import UIKit

public extension CGSize {
    /// 返回一个x/y为0的CGRect
    var rect: CGRect {
        return CGRect(origin: .zero, size: self)
    }

    /// 返回中心点
    var center: CGPoint {
        return CGPoint(x: flat(width / 2.0), y: flat(height / 2.0))
    }

    /// 把size放到屏幕中间返回Rect
    var centerRect: CGRect {
        return CGRect(origin: CGPoint(x: (SCREEN_WIDTH_STATIC - self.width) / 2.0, y: (SCREEN_HEIGHT_STATIC - self.height) / 2.0), size: self)
    }
    /// 判断一个size是否为空（宽或高为0）
    var isEmpty: Bool {
        return width <= 0 || height <= 0
    }

    /// 将一个CGSize像素对齐
    var flatted: CGSize {
        return CGSize(width: flat(width), height: flat(height))
    }

    /// 将一个 CGSize 以 pt 为单位向上取整
    var sizeCeil: CGSize {
        return CGSize(width: ceil(width), height: ceil(height))
    }

    /// 将一个 CGSize 以 pt 为单位向下取整
    var sizeFloor: CGSize {
        return CGSize(width: floor(width), height: floor(height))
    }

    static var max: CGSize {
        return CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
    }

    // 和全局方法重名 flatSpecificScale
    func flatSpecific(scale s: CGFloat) -> CGSize {
        return CGSize(width: flatSpecificScale(width, s), height: flatSpecificScale(height, s))
    }
    
}
