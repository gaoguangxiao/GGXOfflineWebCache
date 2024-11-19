//
//  UITextView+ZK.swift
//  RSReading
//
//  Created by 高广校 on 2023/10/20.
//

import Foundation
import UIKit

public extension UITextView {
    
    @discardableResult
    func zkText(_ t: String) -> Self {
        text = t
        return self
    }
    
    @discardableResult
    func zkFont(_ aFont:UIFont) -> Self {
        font = aFont
        return self
    }
    
    @discardableResult
    func zkTextColor(_ color: UIColor?) -> Self {
        textColor = color
        return self
    }
    
    @discardableResult
    func zkSelectable(_ bool: Bool = true) -> Self {
        self.isSelectable = bool
        return self
    }
    
}
