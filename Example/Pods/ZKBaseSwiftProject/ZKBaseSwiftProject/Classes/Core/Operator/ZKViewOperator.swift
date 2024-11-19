//
//  ZKViewOperator.swift
//  ZKNASProj
//
//  Created by 董建伟 on 2022/10/24.
//

import Foundation
import UIKit

//MARK: 视图操作符
/// 添加子视图
@discardableResult
public func => (left: UIView, right: UIView) -> UIView {
    left.addSubview(right)
    return left
}

/// 添加二级子视图
@discardableResult
public func ==> (left: UIView, right: UIView) -> UIView {
    left.addSubview(right)
    return left
}

/// 添加三级子视图
@discardableResult
public func ===> (left: UIView, right: UIView) -> UIView {
    left.addSubview(right)
    return left
}

/// 添加四级子视图
@discardableResult
public func ====> (left: UIView, right: UIView) -> UIView {
    left.addSubview(right)
    return left
}
