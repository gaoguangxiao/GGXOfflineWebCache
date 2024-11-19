//
//  ZKClosureType.swift
//  ZKNASProj
//
//  Created by 董建伟 on 2022/10/21.
//

import Foundation

/// Void闭包类型
public typealias ZKVoidClosure = () -> Void
/// Int闭包类型
public typealias ZKIntClosure = (Int) -> Void
/// bool闭包类型
public typealias ZKBoolClosure = (Bool) -> Void
/// Double闭包类型
public typealias ZKDoubleClosure = (Double) -> Void
/// CGFloat闭包类型
public typealias ZKCGFloatClosure = (CGFloat) -> Void
/// String闭包类型
public typealias ZKStringClosure = (String) -> Void
/// Array闭包类型
public typealias ZKArrayClosure = (Array<Any>) -> Void
/// Data闭包类型
public typealias ZKDataClosure = (Data?) -> Void

/// Int_String闭包类型
public typealias ZKIntStringClosure = (Int, String) -> Void
