//
//  ZKOperator.swift
//  ZKNASProj
//
//  Created by 董建伟 on 2022/10/24.
//

import Foundation
import UIKit

//MARK: 自定义的优先级组
// 最低优先级
precedencegroup LowestPrecedence {
    // 结合方向：从左到右
    associativity: left
    // 比加法操作符优先级更高
//    higherThan: AdditionPrecedence
}

// 低优先级
precedencegroup LowPrecedence {
    // 结合方向：从左到右
    associativity: left
    // 比上面操作符优先级更高
    higherThan: LowestPrecedence
}

// 正常优先级
precedencegroup NormalPrecedence {
    // 结合方向：从左到右
    associativity: left
    // 比上面操作符优先级更高
    higherThan: LowPrecedence
}

// 高优先级
precedencegroup HighPrecedence {
    // 结合方向：从左到右
    associativity: left
    // 比上面操作符优先级更高
    higherThan: NormalPrecedence
}

// 最高优先级
precedencegroup HighestPrecedence {
    // 结合方向：从左到右
    associativity: left
    // 比上面操作符优先级更高
    higherThan: HighPrecedence
}

/// 自定义前缀操作符
prefix operator -->

// 自定义操作符：用于返回tableview的回调
infix operator >>> : AdditionPrecedence

// 自定义操作符：用于设置tableview的数据
infix operator +++ : MultiplicationPrecedence

//warning: 视图层级不要超过4层
// 自定义操作符：用于添加子视图
infix operator => : LowestPrecedence

// 自定义操作符：用于添加子视图
infix operator ==> : LowPrecedence

// 自定义操作符：用于添加子视图
infix operator ===> : HighPrecedence

// 自定义操作符：用于添加子视图
infix operator ====> : HighestPrecedence
