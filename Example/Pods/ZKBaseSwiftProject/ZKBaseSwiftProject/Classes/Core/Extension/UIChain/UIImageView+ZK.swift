//
//  UIImageView+ZK.swift
//  ZKNASProj
//
//  Created by 董建伟 on 2022/11/2.
//

import UIKit

public extension UIImageView {
    
    @discardableResult
    func zkImage(_ name: String) -> Self {
        image = UIImage(named: name)
        return self
    }
    
}
