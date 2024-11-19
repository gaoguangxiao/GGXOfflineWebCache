//
//  UILabel+ZK.swift
//  ZKNASProj
//
//  Created by 董建伟 on 2022/10/21.
//

import Foundation
import UIKit

/**
  链式语法
*/

public extension UILabel {
    
    @discardableResult
    func zkFont(_ aFont: UIFont) -> Self {
        font = aFont
        return self
    }
    
    @discardableResult
    func zkTextColor(_ color: UIColor?) -> Self {
        textColor = color
        return self
    }
    
    @discardableResult
    func zkNumberOfLines(_ num: Int) -> Self {
        numberOfLines = num
        return self
    }
    
    @discardableResult
    func zkTextAlignment(_ alignment: NSTextAlignment) -> Self {
        textAlignment = alignment
        return self
    }
    
    @discardableResult
    func zkText(_ t: String) -> Self {
        text = t
        return self
    }

   
}

