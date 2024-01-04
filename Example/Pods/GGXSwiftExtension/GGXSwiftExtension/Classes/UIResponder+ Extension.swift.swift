//
//  UIResponder+Extension.swift
//  ZKNASProj
//
//  Created by gaoguangxiao on 2022/11/11.
//

import UIKit

@objc public extension UIResponder {

    func zkcellAction(indexPath:IndexPath) {
        next?.zkcellAction(indexPath: indexPath)
    }
}
