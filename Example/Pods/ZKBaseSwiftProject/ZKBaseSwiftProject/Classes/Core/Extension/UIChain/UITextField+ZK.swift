//
//  UITextField+TD.swift
//  ZKNASProj
//
//  Created by 董建伟 on 2022/10/21.
//

import Foundation
import UIKit

public extension UITextField {
    
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
    func zkDelegate(_ aDelegate: UITextFieldDelegate?) -> Self {
        delegate = aDelegate
        return self
    }
    
    @discardableResult
    func zkPlaceHolder(_ aPlaceHolder: String?) -> Self {
        placeholder = aPlaceHolder
        return self
    }
    
    @discardableResult
    func zkPaddingLeft(_ padd: CGFloat?) -> Self {
        var frame = frame
        frame.size.width = padd ?? 0
        let view = UIView()
        view.frame = frame
        leftViewMode = .always
        leftView = view
        return self
    }
}


extension UITextField {
    
    @discardableResult
    func textColor(_ color: UIColor?) -> Self {
        textColor = color
        return self
    }
    
    @discardableResult
    func delegate(_ aDelegate: UITextFieldDelegate?) -> Self {
        delegate = aDelegate
        return self
    }
    
    @discardableResult
    func placeHolder(_ aPlaceHolder: String?) -> Self {
        placeholder = aPlaceHolder
        return self
    }
}
